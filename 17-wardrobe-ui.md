# Adding UI to the Customization Screens

**Read before adding anything to the wardrobe / character-customization screens.**

Learned building the Cat Form tab in [mods/PurrtasticPalette](mods/PurrtasticPalette/README.md). Adding
a tab and a panel to `WardrobeCustomizationScreen` took far more iterations than it should have,
almost all of them fighting Unity's UI rather than the game. These are the traps, in rough order
of how much time each cost.

---

## 1. The mirror flow, and where a tab goes

The mirror is a dialogue → Director graph → `OpenCustomizationNode`, which **switches to a
dedicated room** (`CharacterCustomizerRoom`) and then shows `WardrobeCustomizationScreen`. Nothing
runs in the room you were standing in.

- `WardrobeCustomizationScreen.OnShow` builds its tab strip from `uiConfigAsset.Tabs`, each tab a
  `BumperMenuWidget` item with `Text`/`Icon`/`OnSelect`. Adding a tab is a public `AddItem` call
  in an `OnShow` postfix, then `bumperMenu.Show()` again so the new item lays out.
- The game's own tabs run through `HandleTabSelected`; a custom tab's `OnSelect` does not. That
  asymmetry is useful: patch `HandleTabSelected` to undo your tab's state (a **prefix**, so it
  runs before the game repopulates), and you know it only fires for vanilla tabs.

## 2. The preview is not the player

`CharacterCustomizer.CharacterPreview` is a standalone rig, not the live player entity. It has its
own private `bodyView` field and is **not** driven by `EntityCustomization.SetBodyView`. To show a
form body, instantiate the body prefab into the rig by hand and copy the human body's local
transform; toggle the human body off. It renders correctly framed - the rig's camera/scale
happened to suit the cat, but do not assume that for every body.

Because the preview is a separate body instance, any material work (recolouring, etc.) must be
applied to it explicitly - the live-player path does not touch it.

## 3. Cloning a game widget instead of drawing one

Hand-drawing UI to match the game is a losing game: the swatch wings, the pink selection ring, the
applied checkmark, the hover click sound, and the title flourishes are all **assets**. Every
hand-rolled version was close-but-wrong, one missing feature at a time. Clone the real widget.

- **Find the right variant.** `CustomizationOptionListWidget` renders as either a square item icon
  or a colour-filled circle, from one class, switched by the serialized
  `displayAssetPreviewColorAsBackground` flag. Grabbing the first instance gave squares. Filter
  `Resources.FindObjectsOfTypeAll<T>()` by the flag (read it with `AccessTools.FieldRef`).
- **Strip the data-driven component, keep the art.** The widget is driven by an `ItemAsset` its
  `OnSetup`/`UpdateVisual` dereference. Clone the GameObject, reflect the child references you need
  (`colorSegmentView`, `selectionFrameWidget`, `selectionFrameColorable`, `appliedVisual`,
  `appliedStateColor`, `inventoryIcon`), then `Destroy` the component so its `ItemAsset` code never
  runs. The referenced child objects survive because they are separate components.
- **Drive the fill directly.** `ColorSegmentView.Show(color)` exists but writes into a gradient
  shader that visibly ignored a single colour. Setting the plate `Image`'s `material = null` and
  `color = fill` tints the circle sprite solid, which is what a colour swatch is.
- **The decorated header** is `CustomizationCategoryListWidget.headerText`'s parent bar (flourishes
  + rule). Clone it, remove the localisation component (matched by type name so no compile-time
  dependency, or it re-asserts its own text on enable), and set the `TextMeshProUGUI` directly.
- **Selection/hover** wire cleanly: `UIColorable.OverrideColor(guid, 0f)` with
  `AddressableLibrary<ColorLibrary>.Instance.SelectionColor` for hover and the widget's own
  `appliedStateColor` for the current selection; `AnimatedWidget.Show()/Hide()` on the frame.

## 4. Static template caches must re-search when destroyed

Caching a cloned template in a `static` with a one-time `searched` bool **regresses on the second
visit**: the screen that owned the template is torn down, the cached GameObject is destroyed, and
the cache hands back a dead reference - the clone fails and the code silently falls back. Gate the
cache on Unity's `== null` instead (`if (template != null) return template;`), which is true for a
destroyed object, so it re-searches on re-entry. This produced a "works the first time, reverts
after leaving and returning" bug that looked mysterious until traced to the cache.

## 5. The category rows you see are runtime clones, not the serialized field

To put a panel where the category rows are, you have to hide the rows. The serialized
`categoryListWidget` field is an **inactive template**; the rows actually on screen are runtime
clones of it (`CategoryListWidget(Clone)`) sitting beside it under `Content`. Disabling the field's
GameObject does nothing visible. Disable whatever is **currently active** under `Content` (and
remember exactly those to re-enable), which also covers the empty-state view.

Do **not** clear the rows with `SetContent(emptyList)` - that triggers the "You have no items
available in this tab" empty-state message. Hide the GameObjects.

## 6. Layout: the flags that silently break everything

- **`VerticalLayoutGroup.childControlHeight` must be `true`** to honour children's `LayoutElement`
  heights. False makes the group use each child's raw (near-zero) `RectTransform` height, and every
  row collapses onto the same spot. This produced an "all swatches stacked on top of each other"
  bug from one wrong flag.
- **`ContentSizeFitter` can resolve to zero**, and behind a `RectMask2D` a zero-height content
  clips every child out of existence - the panel renders completely blank with no error. Compute
  and set heights explicitly (`LayoutElement.preferredHeight`, `content.sizeDelta`) rather than
  trusting a fitter when a mask is involved.
- **A `RectMask2D` turns any layout mistake invisible.** Without a mask, a bad height is at least
  visible and debuggable. Add the mask only once the content height is provably correct.
- **`GridLayoutGroup.childAlignment = UpperCenter`** centres the block of cells; the default
  left-packs them.
- Reserve extra height at the bottom of a row for art that overflows its cell - the swatch
  selection frame (wings) and checkmark extend past the swatch bounds and will collide with the
  next row otherwise.

## 7. Scrolling: reuse the screen's own ScrollRect, don't build one

Two attempts at a fresh `ScrollRect` + `RectMask2D` both blanked the whole panel (the mask clipping,
per section 6). The fix was to stop building anything and **reuse the screen's own scroll
container**. The category rows live under a `Content` object that *is* `scrollRect.content` - a
`ScrollRect` (`Scroll View`) with a `Mask` viewport sits directly above it, and `Content` carries a
`VerticalLayoutGroup` + `ContentSizeFitter`. The vanilla rows scroll because each is a top-anchored
child with a **definite height**, so the fitter grows `Content` past the viewport and the ScrollRect
has something to scroll.

The panel wasn't scrolling because it **stretch-filled** `Content` (`anchorMax.y = 1`), pinning its
height to `Content` instead of driving it - `Content` never overflowed, and the Elastic ScrollRect
rubber-banded any nudge straight back (which read as "doesn't scroll", including over a swatch). The
cure is one anchoring change: give the panel a **definite height** (sum of the row heights), a
`LayoutElement.preferredHeight` to match, and top-anchor it (`anchorMin/Max.y = 1`) exactly like a
vanilla row; then `ForceRebuildLayoutImmediate` on `Content` so it's scrollable on the first frame.
No mask, no new ScrollRect. Diagnose the container first with a one-shot ancestor/component dump
(section 9) - guessing at whether `Content` is the scroll content is what burned the earlier tries.

**`EventTrigger` swallows the mouse wheel.** `UnityEngine.EventSystems.EventTrigger` implements
`IScrollHandler`, so any element that uses it for hover/click stops the wheel event from bubbling to
an ancestor `ScrollRect` - hover a swatch built that way and the panel won't wheel-scroll (drag
still works). Fix: a tiny `IScrollHandler` component alongside the `EventTrigger` that forwards
`OnScroll` to `GetComponentInParent<ScrollRect>()`. (Cloning the game's `AnimatedButton` instead of
using `EventTrigger` avoids this - a `Selectable`/`Button` does not implement `IScrollHandler`.)

**Keyboard/gamepad (WASD) navigation between swatches was attempted and shelved.** The cloned
swatches keep the game's `AnimatedButton` + its `AnimatedButtonMediator : Button`, so they *are*
navigable Selectables, and `UIExtensions.ScrollTo` scrolls a selected one into view. But this
screen's selection is built around `AnimatedButton.selectOnHover`, which deselects to `null` the
instant the pointer leaves the selected swatch. Keyboard selection and the hover model contend for
the same EventSystem selection, and the hover model keeps nulling it (confirmed by logging every
`currentSelectedGameObject` change) - so a keyboard cursor never survives. Mouse use (hover
highlight, click-to-apply) is unaffected. Making WASD robust needs a cursor decoupled from the
contested EventSystem selection, or replicating the game's own navigation model; left as a task.

## 8. Assemblies a UI mod pulls in

A materials-only mod references almost nothing. The moment it touches UI, each capability drags in
another assembly, one build failure at a time. For this screen the full set was:
`UnityEngine.UI`, `UnityEngine.UIModule`, `UnityEngine.TextRenderingModule`,
`UnityEngine.InputLegacyModule`, `Unity.TextMeshPro`, `UnityEngine.ParticleSystemModule`
(hiding preview VFX), `Unity.RenderPipelines.Core.Runtime` + `.Universal.Runtime` (bloom volume),
and `LittleChickenGameCompany.Chicken-UI.Runtime` (`UIScreen`/`ListWidget`/`AnimatedWidget`). Add
them up front if you know you are building UI.

## 9. Diagnose the hierarchy; do not guess at it

The single most useful move, repeatedly, was logging the actual runtime hierarchy - a renderer/
component dump, `HasPropertyBlock`, the children of `Content`, the chosen template name. Every time
a UI element was in the wrong place or the wrong thing was leaking, a one-line hierarchy log
answered it in one round where guessing had taken several. Wrap each diagnostic in its own
try/catch: one throwing diagnostic silently truncated the whole dump and looked like "it didn't
run."
