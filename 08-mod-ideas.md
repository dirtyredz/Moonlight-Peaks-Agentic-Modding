# First Mod Ideas

Drafted 2026-08-02, based on the Nexus listing in [01-mod-landscape.md](01-mod-landscape.md).

## Reality check first

**88 mods already exist and the obvious QoL slots are gone.** In roughly three weeks the
community covered: crafting from chests, remote storage, batch cooking, auto-pet, barn
automation, faster planting/growth/machines, save anywhere, walk-through crops, minimap,
enriched tooltips, quest tracking, item spawning, item duplication, in-game config menus,
camera zoom, portrait replacement, and four translations.

If an idea springs immediately to mind, assume it's taken and check first.

**Coverage:** all mods reviewed 2026-08-02 and again 2026-08-03.

⚠️ **Two lessons from getting this wrong twice.**

1. **Read the full mod page, not the one-line summary.** Catalog QoL's summary made its search
   sound narrow; its feature list is much broader. A summary can understate as easily as it
   overstates.
2. **Sort by date, not downloads, when checking what exists.** A downloads sort buries
   anything new at the bottom — this listing failed to surface a mod published three hours
   earlier. Filtering the results by keyword compounds it.

---

## The ladder

Your first mod should have an **unmistakable** effect. You are debugging a toolchain, not
game logic — subtle mods make it impossible to tell whether the failure is your patch or
your setup.

### ~~Rung 1 — Configurable Day Length~~ — TAKEN

Struck after a full sweep of all 88 mods. **TimeControl** already does slow/speed/stop.
**Clock Pause** stops the clock in decorate/inventory. **Serenas Day Walker** extends
daylight. Nothing left here.

### Rung 1 — Photo Mode

Hotkey to hide all UI; add free camera and time freeze.

- **Why it's a good first**: mostly toggling Canvas objects off. Teaches Unity object
  traversal with no Harmony subtlety. Instant visual verification.
- **Why it matters strategically**: cozy games spread through screenshots. A photo mode
  gets your mod posted on social media *by other people*. Best marketing-per-line-of-code
  in this list.
- **Gap check (full sweep)**: RPG Camera does perspective/rotation, Far Sight does zoom
  limits, Camera Zoom Mod does configurable distance. **None hide the UI.** Confirmed gap.
- **Teaches**: Unity scene traversal, input handling, coexisting with other camera mods.

### Rung 2 — Auto-Water / "Crop Butler"

Morning crop chores done automatically: water everything, optionally harvest.

- **Why this one is the strongest real idea**: [Barn Butler](https://www.nexusmods.com/moonlightpeaks/mods/48)
  took ~475 downloads and 12 endorsements in about a week — the strongest recent debut in
  the scene — by automating every *animal* chore each morning. Nobody has done the same for
  crops. Proven concept, unoccupied half of the farm.
- **Design note**: copy Barn Butler's framing — *"real fodder is consumed: comfort, not a
  cheat."* Consume actual water from the can/well. This keeps it out of cheat territory,
  which meaningfully widens the audience in a cozy-game community.
- **Risk**: writes to world state. Test save/load carefully.
- **Gap check (full sweep)**: **Never Ending Can** makes the watering can infinite, but
  nothing *waters for you*. Barn Butler covers animals only. Confirmed gap.
- **Teaches**: hooking a game event (day start), iterating game collections, calling the
  game's own methods rather than reimplementing them.

### ~~Rung 3 — Chest Labels~~ — 🚀 PUBLISHED

Live on Nexus as [mod 119](https://www.nexusmods.com/moonlightpeaks/mods/119), v0.6.0,
released 2026-08-03 — identified as a gap and shipped the same day. Source in
[mods/ChestLabels](mods/ChestLabels/README.md).

Original notes kept below, because the reasoning held up: the crux really was chest identity,
and the sidecar decision really did matter.

**What the build changed for everything else on this page** — reusable, and none of it
obvious up front:

- **World hover is solved.** `HoverLabel.cs` raycasts from the mouse onto its own overlay
  canvas. It is the hard part of Rung 4 (plant growth on hover), already working and worth
  copying rather than rewriting.
- **`Camera.main` is null in this game.** The gameplay camera is not tagged `MainCamera`.
  Scan `Camera.allCameras` for the highest-depth active one instead.
- **Gate world UI on `PlayerCursorInteractionScreen`.** It is showing exactly when the player
  can point at the world, and absent during cutscenes, menus, pause and full-screen windows.
  Much better than blocklisting screens one at a time.
- **Never gate on `UIScreen.ShowStack` being empty.** `EnergyScreen`, `ManaScreen` and the
  interaction prompts are in it permanently during normal play.
- **The game's UI screens can be extended safely** where the parent has no layout group.
  `ChestPatches.cs` shows the pattern: find the panel, cache original transforms, apply
  offsets computed from the cached values so repeated opens never compound.
- **Rewired ignores Unity's keyboard focus.** Any mod with a text field must suppress the
  screen's own hotkeys while typing, or letters trigger game actions.
- **⚠️ `KeyboardShortcut.IsPressed()`/`IsDown()` are false while any other key is held.** Both
  end in `_modifierBlockKeyCodes.All(c => !Input.GetKey(c) || allKeys.Contains(c))`, and that
  array is *every supported key except the mouse buttons*. Correct for a config-menu shortcut
  that must not fire mid-combo; wrong for anything used during play, because the player is
  holding a movement key. A hold-to-inspect binding simply never fires while walking. Check
  `Input.GetKey(shortcut.MainKey)` plus the declared `Modifiers` instead — see
  [mods/PlantPeek/src/PlantPeek/Hotkey.cs](mods/PlantPeek/src/PlantPeek/Hotkey.cs). Still worth
  binding the config as a `KeyboardShortcut` so Mod Menu renders a key picker.
- **Generate icons at runtime.** The game has no pencil/edit glyph among its 1,659 UI icons
  and its font has none either. `PencilIcon.cs` draws one procedurally — no art files to ship.

### Rung 3 (original notes) — Chest Labels

Name your chests; see the name without opening them.

- **Gap check (full sweep)**: **confirmed absent.** Six mods target storage — Craft from
  Chests, House Storage Anywhere, Stack to Storage, Catalog QoL, BiggerStacks, Mouse Tweaks
  — which proves storage is where players feel friction. None of them do naming.
- **Why it's Rung 3, not Rung 1**: hits custom UI *and* persistence simultaneously. Two new
  systems at once is exactly what you don't want on mod #1.
- **The crux — chest identity**: you need a stable per-chest key. If the game assigns
  chests a persistent GUID, this is easy. If you must key off world position, it breaks the
  moment a player moves a chest — and in a decorating-heavy game, they will.
  **Decompile and answer this question before writing any code.** It's the difference
  between a weekend and a slog.
- **Key design call — sidecar storage**: keep labels in your own JSON under
  `BepInEx/config/`, keyed by chest ID. Do **not** write into the game's save. The wiki has
  [Saving Custom Objects in Game Persistence](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Saving_Custom_Objects_in_Game_Persistence)
  if you need it, but touching the save means an uninstall can leave debris. A sidecar file
  lets you honestly claim **save-safe**, which this community reads for.

**Staged scope:**

| Version | Scope | New systems |
|---|---|---|
| v1 | Label in the chest's open UI header; rename via text field; sidecar JSON | UI + persistence |
| v2 | Floating world-space text above chests, config toggle, distance fade | world rendering |
| v3 | Search across labels — which becomes the item-locator idea below | search |

Each step adds one system instead of three, and v1 alone is immediately useful.

### Rung 4 — Plant Growth Info on Hover — 🔨 IN PROGRESS

Picked as mod #2 on 2026-08-03. Source in [mods/PlantPeek](mods/PlantPeek/README.md), v0.1.0
building and deploying. Gap re-verified the same day against the listing **sorted by date**
(88 mods, nothing newer than Chest Labels) and by reading the full pages of Extra Tooltip
(v1.1.4, 28 Jul, unchanged) and Farming QoL (v1.0.0, 29 Jul, unchanged). Both remain menu- and
icon-level; neither reports a world plant's stage.

**What the decompile settled** — full notes in
[mods/PlantPeek/research/01-growth-system.md](mods/PlantPeek/research/01-growth-system.md):

- **No Harmony patch needed at all.** `GrowableView` exposes `GridObjectPersistence`,
  `GrowablePersistence` and `ItemAsset` publicly, and `ItemAsset.GrowableAddon.GrowStageContainer`
  reaches the stage graph. The whole mod is a read. No reflection.
- **Each requirement can be evaluated on its own.** `IGrowStageRequirement.IsRequirementCompleted`
  is public on all twelve types, so per-requirement ✓/✗ is cheap. Calling the game's own check
  also means requirement-patching mods (Endless Harvest) are inherited correctly for free.
- **⚠️ `RandomChanceGrowStageRequirement.IsRequirementCompleted` calls `Random.value`.** It
  consumes Unity's global RNG, so a 12 Hz hover poll would churn the shared random stream.
  Never call `GrowPath.CheckIfRequirementsMet` or `GrowStageContainer.GetDesiredGrowPath` —
  both iterate it. Enumerate the requirements and type-switch instead. Nothing in the name
  hints that a read mutates; this is the decompile-first rule earning its keep twice over.
- **⚠️ `GrowStageContainer.GetFinalGrowStage()` can hang the game.** It walks `TargetGrowStage`
  in a `while` loop until a stage has no paths — and a regrowing crop's harvest stage links
  back to an earlier one. Ask "does this stage have any paths?" instead of "which stage is
  last?".

Original notes kept below.

### Rung 4 (original notes) — Plant Growth Info on Hover

Hover a planted crop in the world and see how far it is from harvest.

- **Gap check (full sweep + installed mods)**: **confirmed absent.** Extra Tooltip advertises
  "crop growth times", but decompiling the installed DLL shows *every* patch target is a menu
  widget — `NameplateScreen`, `InventoryListWidget`, `WorkbenchListWidget`, `ShopListWidget`,
  `CookingListWidget`, `BrewingListWidget`, resource converters, museum info. **Nothing
  touches world objects.** Its growth times are on seed/item tooltips in menus. Farming QoL
  adds dry-crop indicators (needs water), not time-to-harvest. Hovering an actual growing
  plant is unclaimed.
- **Read-only** — never writes to the save, so save-safe is trivially true. No persistence
  layer at all, which makes it simpler than Chest Labels in the dimension that usually bites.

#### The wrinkle: growth is not a timer

This is the thing to understand before designing the UI. `GrowablePersistence` stores:

```csharp
[DataContract]
public class GrowablePersistence : GuidPersistence {
    [DataMember] public string GrowStageGuid;
    [DataMember(EmitDefaultValue = false)] public int DayPlanted;
    [DataMember(EmitDefaultValue = false)] public int DayGrowStageChanged;
    [DataMember(EmitDefaultValue = false)] public int DayProcessed;
    [DataMember(EmitDefaultValue = false)] public int TimesHarvested;
    ...
}
```

Growth is a **graph of stages** (`GrowStage` → `GrowPaths` → `GrowStagePath`), and a stage
only advances when its requirements are satisfied. The requirement types in the assembly:

`WaterGrowStageRequirement`, `SeasonGrowStageRequirement`, `NearWaterGrowStageRequirement`,
`PlantDrankGrowStageRequirement`, `PlantFedGrowStageRequirement`,
`PlantPettedGrowStageRequirement`, `CropsNearGrowStageRequirement`,
`FootprintGrowStageRequirement`, `RandomChanceGrowStageRequirement`,
`AutoGrowStageRequirement`, `WildTreeGrowStageRequirement`, `WeepingWiccaGrowStageRequirement`

So "3 days left" is often a lie — a plant can sit forever unwatered, wait on a season, or
gate on a **random chance** roll. `Director.Nodes.GetGrowableGrowDurationNode` shows the game
does compute a duration for the simple case, but the general case isn't a countdown.

**Design accordingly, and it becomes a better mod than the naive version:**

> **Moonpetal** — stage 2 of 4
> Next stage needs: **water** ✗ · summer ✓
> Planted day 6 · in this stage 2 days

That's strictly more useful than a fake ETA, and it honestly reflects the model. Show a day
estimate only when the path is `Auto`-gated with no player requirement.

#### Implementation notes

- **No world-hover system exists in the game** — a search for hover/highlight types turns up
  only `TelekinesisHoverEffect` and `SpeechHighlight`. You'll need your own raycast, or hook
  the `Interactable` targeting the player already uses.
- **Reuse the game's tooltip** rather than building a panel. The pattern is proven by
  Extra Tooltip:
  ```csharp
  [HarmonyPatch(typeof(NameplateScreen), "Show")]
  public static class NameplateScreen_Show_Patch {
      public static void Postfix(NameplateScreen __instance, RectTransform target, INameplateData nameplateData) { ... }
  }
  ```
  `NameplateScreen` anchors to a `RectTransform`, so a world plant needs its screen position
  converted — or accept a fixed-corner panel for v1.
- `ItemGrowableInfoDisplay` and `AlmanacGrowableScreen` already exist and likely render some
  of this for the almanac. **Read them before writing any UI** — there may be a formatter to
  reuse.

### Rung 5 — Bigger UI — 🔨 IN PROGRESS

Make the small text readable. Explored, built and run on 2026-08-04, driven by a real player on
this machine who finds the default type too small. Source in
[mods/BiggerUI](mods/BiggerUI/README.md); **v0.2.0** scales font sizes, after **v0.1.0** scaled
canvases and wrecked the display.

**The lesson, and it generalises past this mod:** scaling every `CanvasScaler` is not the same
as scaling the UI. The run found eight canvases, and only two (`SharedCanvas`, `MenuCanvas`)
were the readable interface. The rest were the mouse cursor, a safe-area boundary whose 800x600
reference became 640x480 — black band at the bottom, layout not fitting, the window resizing to
a tiny resolution — a canvas literally named `UnscaledCanvas`, and, worst, **two canvases
belonging to other installed mods.**

Three rules, none of them specific to this mod:

1. **Allowlist, never sweep.** `FindObjectsOfTypeAll` reaches things you do not own.
2. **Never touch another mod's UI by default.**
3. **Match names exactly.** `Canvas` as a substring matches `MinimapCanvas` and `:: CANVAS`.

This is the first idea here with a **named user** rather than a download count behind it,
and the first that is an accessibility feature rather than a convenience one.

#### Gap check (full sweep, 2026-08-04)

**Confirmed absent, twice over.**

- **Nexus**: all 88 mods read sorted by date; keyword searches for `font` (0 results),
  `scale` (0), `text` (2 — both *texture* frameworks), `UI` (4 — QuickSpells, Museum
  donations, item spawner, Extra Tooltip). Nothing scales the UI. The whole
  **User Interface** category is tooltips, minimap, museum tracker, mouse tweaks, mod menu,
  item value, stack-to-storage, portrait studio — and Chest Labels. **No accessibility mod
  of any kind exists for this game.**
- **The game itself has no such setting.** `SettingsGameplayScreen` offers exactly eight:
  clock format, interaction prompts, speech bubbles, controller vibration, text animation,
  language, day duration, portrait style. `SettingsVideoScreen` offers resolution, screen
  mode, VSync, render scale, framerate. `AppSettingsLibrary` confirms that is the complete
  set. There is no text size and no UI scale, so this is not a mod competing with a built-in
  option — it is filling a hole in the base game.

#### What the decompile settled

- **The UI is `CanvasScaler`-driven, and the game does not fight you.** `UIAspectRatioSizer`
  is `[RequireComponent(typeof(CanvasScaler))]` and runs every frame — but it only ever
  writes `matchWidthOrHeight` (lerped between 1.6 and 2.33 aspect). It never touches
  `referenceResolution` or `scaleFactor`. **Set those once and they stay set.** That is the
  finding the whole idea rests on: no Harmony patch, no per-frame re-apply fight.
- **The developers already picked a "bigger" number: 1.3x.** `UITouchInputOverrides` exists
  for the touch builds and multiplies both `transform.localScale` and
  `TextMeshProUGUI.fontSize` by a default `1.3f`. Their own answer to "make it readable on a
  small screen" is a good starting default and a good upper sanity bound.
  *(Aside, harmless to us: its font branch reads `if (overrideFontSize && !TryGetComponent(...out var component))` and
  then dereferences `component` — it can only run when the component is null. PC never
  enables it.)*
- **Text stays crisp when scaled.** Everything is TextMeshPro SDF, not bitmap — upscaling
  costs nothing in quality.

#### Two approaches, and why one of them is a trap

**A. Scale the canvases** *(recommended)* — walk `CanvasScaler`s and divide
`referenceResolution` (or multiply `scaleFactor` for constant-pixel canvases) by the chosen
factor. Panels, icons, buttons and text all grow together, so **layout cannot break**: nothing
overflows a box that grew with it, hit areas follow the RectTransforms automatically, and the
cost is one pass, not a per-frame loop. The trade is screen real estate — lists show fewer
rows, and edge-anchored HUD eats more of the view.

**B. Multiply `fontSize` on every text** *(what "bump the font up" sounds like)* — grows text
inside boxes that did **not** grow. Expect clipped buttons, truncated labels and re-wrapped
list rows, worst exactly where text is longest. Also has to track originals per component or
it compounds on every re-apply, and has to keep re-applying as screens load. Worth keeping
only as a targeted supplement for specific elements that still read small after A.

Start with A. It is less code, less risk, and closer to what "everything is bigger" means.

#### Design sketch

- Config: a single `Scale` float, 1.0–2.0, default 1.25. **No hotkey** — a scale setting is
  its own interface, and the config entry's `SettingChanged` event already makes an in-game
  editor apply it live, which is the same tuning loop without a keybind to remember or
  collide with.
- Apply over `Resources.FindObjectsOfTypeAll<CanvasScaler>()` so inactive screens are caught
  too; always compute from a **remembered original** per instance, never from the current
  value. Re-apply on scene load and when new canvases appear (screens load via Addressables).
- Per-canvas exclusion list in config, for the minigames — Embroidery, Nokturna and Pottery
  have their own canvases and their own assumptions about fitting the screen.
- **Writes nothing to the save.** Purely visual, removable at any time — say so on the mod
  page, the way Far Sight does.
- [Mod Menu](https://www.nexusmods.com/moonlightpeaks/mods/98) already adds a Mods button to
  the pause menu for compatible BepInEx mods. A slider there is the right home for this
  eventually: an accessibility setting you can only change by editing a config file is a
  worse accessibility setting.

#### Open questions, all answerable in one launch

- How many canvases exist, and which `ScaleMode` each uses.
- Whether world-space text — speech bubbles, `WorldUIScreen` / `WorldUIWidget` — sits on a
  separate canvas that a screen-space scale misses. If so it needs its own handling, and it
  matters: dialogue is the most-read text in the game.
- Where the first thing breaks as the factor climbs (full-width HUD is the likely first
  casualty).

A ~30-line diagnostic pass that logs every canvas, its scaler mode and its reference
resolution answers all three before any real code is written.

### Rung 6 — Health Bars on Trees and Rocks — 🔨 IN PROGRESS

Added and started 2026-08-04. Show how much a tree, stump or rock has left — **but only while
you are actually swinging at it.** No bar over an untouched forest; the bar appears on the one
thing your axe is aimed at and goes away when you look elsewhere.

Source in [mods/LastSwing](mods/LastSwing/README.md), **v0.2.0 — confirmed working in game on
2026-08-04**, and now its own repo at
[dirtyredz/Last-Swing](https://github.com/dirtyredz/Last-Swing) rather than living in this one.
Two findings from the build that are not in the research below:

- **`ChopTreeGridComponent` has two gates, not one.** `Chop()` never destroys the tree — it
  dispatches `RequestGrowstageCheck`, and the stump transition is gated by
  `DamageTakenRequirement`. So the felling threshold is `max(healthTree + 1, ceil(DamageAmount))`
  and both halves have to be read. This answers the third open question below.
- **Plant Peek already reads half of this.** Its `GrowthReader.ReadChoppedPercent` reports
  `chopped 47%` from the same `DamageTakenRequirement`, and it established the rule this mod
  depends on: **`TryGetByGuid`, never `FindOrCreate`** — the game's `FindOrCreate` writes a
  damage record for anything it is asked about, which for a mod that inspects whatever the tool
  points at would seed one per tree walked past.

**Working name: Last Swing.** Nexus title `Last Swing - Health Bars for Trees and Rocks` —
the subtitle carries the search, the name carries the Discord message. Alternates considered:
*Timber* (already ambiguous with lumber mods), *Death Toll* (too grim for a cozy game's mod
list). Internals stay literal: `DamageBarWidget`, `SwingTargetWatcher`.

#### Gap check (2026-08-04)

**Confirmed absent.** The listing is still 88 mods with nothing published since Chest Labels
(re-read sorted by date today). Keyword searches: `health` **0 results**, `damage` **0**,
`durability` **0**, `chop` **0**. The nearest neighbours are adjacent but not overlapping —
Farming QoL adds *dry-crop* indicators, MoonlightAutoToolSelect picks the axe *for* you, and
Serena's Grimoire's Death's Grasp fells trees in an area. **Nothing in the scene displays a
world object's remaining health.** Note the caveat: Nexus keyword search appears to match
titles only (`chop` returns 0 despite "chopping" appearing in descriptions), so the full
date-sorted read is the load-bearing part of this check, not the keyword counts.

The game does not show this either. Damage on world objects is invisible — the only feedback
is a shake, a particle and a sound, identical on hit 1 and hit 4.

#### What the decompile settled

**This is the cheapest idea on this page. It is a pure read, and the game hands you both
halves of it.**

- **The "actively attacking" signal already exists, fully public.** `SwingToolView` — the
  equipped-axe/pickaxe view — recomputes its target every frame in `ProcessEquippedUpdate` and
  exposes it:

  ```csharp
  public IInteractable Target { get; private set; }
  public bool TargetIsInRange { get; private set; }
  ```

  That is exactly the object the game is already drawing its grid cursor on. **No raycast, no
  hover system, no Harmony patch** — a stark contrast with Chest Labels and Plant Peek, both of
  which had to build world hover from scratch. Reach it via
  `PlayerView.Instance.Equipment.GrabbedItemView`, and note it exists *only* while a swing tool
  is equipped, which is most of the "only when attacking" gate for free.
- **Damage is stored per object and is public.** `DamagePersistence : GuidPersistence` holds
  `DamageValue` plus `IsDead(int health)` / `IsAlive(int health)`, and lives in
  `GamePersistence.Instance.CurrentRoom.DamagePersistences`, keyed by the grid object's GUID —
  so identity is stable, the Chest Labels problem does not recur here.
- **Read-only.** Nothing is written. Save-safe is trivially true, as with Plant Peek.
- **⚠️ Four damageable types, no common interface, and one of them counts differently.**
  All four expose `public DamagePersistence`, but each finds its max health elsewhere:

  | Component | Covers | Max health | Dies when |
  |---|---|---|---|
  | `DestructibleView` | rocks, ore, breakables | `GridObjectPersistence.ItemAsset.DestructibleAddon.TotalHealthPoints` — **public** | `Damage >= health` |
  | `DestructableTreeGridComponent` | small trees | private `ItemParameterRef<int> healthTree` (default 3) | `Damage >= health` |
  | `ChopStumpGridComponent` | stumps | private `ItemParameterRef<int> healthStump` (default 3) | `Damage >= health` |
  | `ChopTreeGridComponent` | full trees | private `ItemParameterRef<int> healthTree` (default 5) | **`Damage > health`** |

  **`ChopTreeGridComponent` uses `>` where the other three use `IsDead`'s `>=`.** A full tree
  with health 5 survives damage 5 and falls on the sixth point. Compute that bar with
  `health` as the denominator and it reads empty a whole swing before the tree comes down —
  the exact moment the player is watching it. **Denominator is `health + 1` for this one type.**
  This is the same shape of trap as `GetFinalGrowStage()` hanging on regrowing crops: the
  method name tells you nothing, only the body does.
- **Three of the four need one reflection call, and only one.** The health fields are private,
  but `ItemParameterRef<T>.GetValue(UnityEngine.Object context)` is public — so cache one
  `FieldInfo` per component type at startup and call `GetValue(component)` through it. Health
  can be overridden per item asset via `ItemParametersAddon`, so **read it, never hardcode 3
  and 5**, or modded or higher-tier trees will report wrong.
- **The game has a world-space UI system and it is public.** `GameWorldUIScreen.InstantiateWidget<T>(T prefab, Transform target)`
  attaches a `GameWorldUIWidget` to a world transform and then handles world→canvas projection,
  re-projection on `OnGameCameraPositionChanged`, depth sorting between widgets, optional
  off-screen clamping, and hiding during cutscenes. It also declares
  `showDuringPlayerConfinement => false`, so it disappears in menus and confined states
  **without the `PlayerCursorInteractionScreen` gating that Chest Labels had to work out.**
  Subclass `GameWorldUIWidget` on a runtime-built GameObject — no prefab asset to ship.

#### The feature that makes it more than a bar

`GameInventory.GrabbedToolAddon.Damage` is public, and so are
`Interactable.InteractionToolDamageRequired` and `Interactable.ToolRequirements`.
`InteractionSwingToolState` shows what the game does with them:

```csharp
if (interactable.InteractionToolDamageRequired > swingToolView.ToolAsset.Damage
    || interactable.ToolRequirements.All(x => !x.FitsRequirement(swingToolView.ToolAsset)))
{
    interactable.ResolveFailedInteraction();      // shout: tool damage too low
}
```

So the mod can render, for free:

1. **A ghost segment** showing what the *next* swing will take off.
2. **"Your tool cannot hurt this"** — a struck-through or greyed bar when
   `InteractionToolDamageRequired > tool.Damage`, *before* the player wastes energy and gets
   shouted at.

(2) answers a real new-player question — *why isn't this rock breaking?* — that the game
currently answers only after the swing. That is a better mod than a plain bar, and it is the
same public fields.

#### Design sketch

- **Segmented, not continuous.** Health values are 3 and 5, not 100. Draw one notch per hit so
  the bar reads *"two swings left"* at a glance. A smooth 60%-full bar for a 5 HP tree is
  fake precision.
- **Trigger, in three tightening steps** — ship 1+2, config-gate 3:
  1. A swing tool is equipped and `SwingToolView.Target` resolves to one of the four types.
  2. `TargetIsInRange` is true. *(Read it only when `Target != null` — `SetTarget` clears
     `Target` but leaves `TargetIsInRange` at its previous value.)*
  3. **Now the default, and `Damage > 0` turned out to be the wrong test for it.** "Only once
     you have started hitting it" has to mean *this engagement*, not *ever* — otherwise every
     part-chopped tree on the farm lights up the moment it is aimed at. Record the damage the
     object already carries when it is first aimed at, and arm only when damage rises above
     that baseline.
- **Linger and fade** ~1.5s after the target is lost, so the bar does not blink out between
  swings as the weighted target re-resolves. Same shape as Coffin Break's grace timer.
- **Never on full health with 0 damage** if step 3 is on — that is the config most players who
  dislike floating UI will want.
- Follow [10-visual-integration.md](10-visual-integration.md) for the plate and palette. The
  bar sits above `Target.Transform` via `GameWorldUIScreen`, which puts it in the same visual
  layer the game already uses for its own world UI.
- Writes nothing. Say **save-safe** and **comfort, not a cheat** on the page — it shows
  information the game already simulated, it does not change a single number.

#### Open questions

- **`DamagePersistence.DayRegeneratedLast` exists and nothing found so far writes it.** If
  damage regenerates overnight, partial chops reset — the bar will show it correctly either
  way since it reads live, but the mod page must say so. Find the writer before release.
- ~~**Full trees do not destroy themselves.**~~ **Settled during the build.** `Chop()`
  dispatches `RequestGrowstageCheck`, and `DamageTakenRequirement : BaseGrowStageRequirement`
  gates the stump transition on `DamageValue >= DamageAmount`. Both gates must pass, so the
  answer is neither one alone: the threshold is `max(healthTree + 1, ceil(DamageAmount))`.
  Which one actually binds in practice is still unknown, but taking the max is correct either
  way.
- Whether ethereal tools (`EtherealAxesToolView`, `EtherealPickaxesToolView`) route through
  `SwingToolView` at all, or are a separate view with a separate target. If separate, the
  trigger needs a second source — and Better Ethereal Tools is a popular mod.

### Rung 7 — Move Planted Crops in Decorate Mode — 📦 v1.0.0 PACKAGED

Added 2026-08-04, from a player request: *in build mode, let me pick up and move a plant.*
Built and confirmed working the same day; v1.0.0 packaged, pending screenshots and two
save-safety checks. Source in [mods/Transplant](mods/Transplant/README.md).
Full decompile notes in
[mods/Transplant/research/01-moving-growables.md](mods/Transplant/research/01-moving-growables.md).

#### Name — settled 2026-08-04

**Transplant.** Nexus title `Transplant - Move Planted Crops Without Losing Growth`.
GUID `com.dirtyredz.moonlightpeaks.transplant`, folder `mods/Transplant`. Internals stay
literal, per the Last Swing convention.

`transplant` and `root` both return **0 results** on the Moonlight Peaks listing, so the space
is free.

**Why this name and not a cozier one.** The usual rule — *the subtitle carries the search, the
name carries the Discord message* — has an extra job here. Serena's Conjuring already moves
buildings and states on its own page that crops are excluded *because their watering and growth
records aren't safe*. This mod is therefore arguing against an incumbent's published reason for
not doing it, so the name should imply **the plant survives the move**. "Transplant" is the
literal horticultural term for exactly that operation and carries the claim for free. It costs
the two-word pattern shared by Chest Labels, Plant Peek, Last Swing, Coffin Break and Bigger UI
— a real but acceptable trade.

The subtitle is not a search-vs-differentiation tradeoff: *move*, *planted*, *crops* and
*growth* are all search terms, and "without losing growth" is the differentiator, in the same
breath.

**Rejected, so they don't get re-proposed:**

| Name | Why not |
|---|---|
| **Uprooted** | Evocative and plant-accurate, but connotes disruption and loss — the exact opposite of the thesis. Same category of miss as *Death Toll*. |
| **Replant** | Actively misleading. Replanting means starting over from seed, which is precisely what this mod exists to avoid. |
| **Repot** | Implies pots, and herb-garden pots are the one thing explicitly out of scope for v1. |
| **Second Bed** | Garden bed / vampire bed, in the *Coffin Break* pun register. Too oblique — "you should get Second Bed" doesn't parse. |
| **Green Thumb** | Cozy, says nothing. |
| **Garden Shuffle** | Genuinely good and nearly won: cozy, two words, matches the family rhythm. Lost because "shuffle" undersells the care angle that is this mod's whole argument. |

#### Gap check (2026-08-04)

**Confirmed absent, and confirmed *hard*.** Listing is now 90 mods (up from 88 — the two new
ones are Plant Peek and Coffin Break), read sorted by date. Keyword `plant` returns 3 results:
Plant Peek, Endless Harvest, Faster Planting. None move anything.

The load-bearing evidence is on the nearest neighbour's own page.
[Serena's Conjuring](https://www.nexusmods.com/moonlightpeaks/mods/62) (v1.8.6, 1,029 unique
DLs) already unlocks moving **buildings** in decorate mode, and states:

> Crops, tilled soil, paths and other location-dependent farming objects are deliberately
> excluded so their watering and growth records remain safe.

**The scene's most-downloaded decorate mod hit this wall and walked away.** That is a better
gap signal than any keyword search: the territory is unoccupied because the problem is real,
not because nobody wanted it. Free Decorate (mod 84) patches placement *validation* only and
never touches the pickup gate, so it doesn't overlap either.

#### What the decompile settled

- **The gate is one virtual method.** `BaseDecorateStateMachineContext.CanMoveGridView` fails
  crops purely because their `ItemAsset` lacks `GridControlType.Movable`. `GridControlType.Movable`
  is read in exactly **three** places in the whole assembly — the complete blast radius.
- **No hover system to build.** `DecorateSelectState` already falls back to a grid-column
  lookup gated only by that method. A stark contrast with Chest Labels and Plant Peek, which
  each had to build world hover from scratch. Same shape of luck as Last Swing.
- **Identity survives the move.** Pickup/place is `RemoveFromGrid()` / `AddToGrid()` on the
  *same* view; `SetPosition` writes only `GridObjectPersistence.Position`. GUID-keyed data —
  grow stage, `DayPlanted`, `TimesHarvested`, drank/fed logs — is untouched.
- **⚠️ Watering is keyed by position, not GUID, and it lives on the soil.**
  `WaterGrowStageRequirement.GetWaterablePersistence` scans for *another grid object sharing
  the plant's cell* — the farm tile — and reads its watered log. **Move a plant onto bare
  ground and it stops growing permanently**, looking perfectly healthy, with no warning and no
  log line. So the mod's core rule is not "let plants move", it is **refuse to place a growable
  on a cell with no waterable.** This is exactly what Serena's page is describing, and solving
  it *is* the mod.
- **⚠️ `ObjectPickupAction.Cancel` restores position only when the asset has `Movable`.** Patch
  the context method alone and pressing Esc mid-move drops the crop wherever the cursor is
  instead of putting it back. Patch `GridObjectItemAddon.get_ControlTypes` instead and cursor,
  selection and cancel-restore all agree from one hook. Same shape of trap as
  `ChopTreeGridComponent` using `>` where its three siblings use `>=` — the method name tells
  you nothing, only the body does.
- **Three other requirements re-evaluate at the destination and that is correct.** Near-water,
  crops-near and footprint all recompute; a plant moved beside a pond genuinely is beside a
  pond now.
- **Input action is `Toggle_Pickup = 34`** ("Pick Up Place", category `Decoration`). Rewired
  keeps default bindings in its input-manager asset, not the DLL, so the actual keyboard key is
  a one-launch check — and it doesn't affect the design, since patching the gate makes whatever
  key already picks things up start working on plants.

**Writes nothing new to the save** — no sidecar, no new persistence type, just the game's own
`SetPosition` on an object it already owns. Save-safe, and comfort rather than cheat: it moves
a plant without skipping a growth day, changing a yield or duplicating anything.

---

## Also viable

**Chest / item locator.** "Which chest has the copper ore?"

⚠️ **Weaker than first assessed.** [Catalog QoL](https://www.nexusmods.com/moonlightpeaks/mods/108)
covers more ground than its one-line summary suggests: an integrated toolbar on cooking,
workbench **and farm storage** screens, searching by recipe, item, variant, ingredient and
custom names, with Ctrl+F to focus. Search exists, and it reaches storage.

What is still missing is narrow: finding an item across **placed chests** without opening
them. And [Craft from Chests](https://www.nexusmods.com/moonlightpeaks/mods/16) already pulls
ingredients from any chest, so the practical pain is smaller again.

Worth doing only alongside chest labels, where "Ore Chest" plus a locator is a coherent
story. As a standalone mod it is thin.

*(Lesson: a one-line Nexus summary undersells what a mod does. Read the full page before
calling something a gap — the same mistake as assuming Extra Tooltip covered plant growth,
in the opposite direction.)*

**Auto-sell / shipping automation.** A genuine gap, but hold off. Touches the economy and
writes to save state — the exact place a first mod can quietly corrupt someone's file.

---

## Deliberately not suggesting

- **New items / NPCs / map areas** — the full Unity + Addressables + Blender chain. This is
  why the Items category has exactly one mod in it. See [05-custom-assets.md](05-custom-assets.md).
- **Localization** — high downloads (French: 2.7k), but it needs fluency, not code.
- **A framework mod** — two already exist (Serena's Enchanted Studio, Fippsie's TSF) and
  frameworks demand API stability commitments you can't make on mod #1.

---

## Already covered — check here before having an idea

From the full 88-mod sweep, 2026-08-02. Grouped so you can spot occupied territory fast.

- **Storage/inventory**: Craft from Chests, House Storage Anywhere, Stack to Storage,
  Catalog QoL, BiggerStacks, Mouse Tweaks, Consume All Button, Toolbar Plus
- **Time**: TimeControl, Clock Pause, Serenas Day Walker
- **Farming**: FasterGrowth, Faster Planting, Walk Through Crops, Endless Harvest,
  Farming QoL, No Crows, Never Ending Can, Better Ethereal Tools
- **Animals**: Barn Butler, Auto Pet, No More Chicks, RotateBarns, Pink Draculamb,
  White Cheeken
- **Cooking/crafting**: Batch Cooking, Meal Prep, Faster Machines, Instant Crafting,
  Converter Status, Controlled Random Quality
- **Camera**: Far Sight, Camera Zoom Mod, RPG Camera *(none hide UI)*
- **Info/UI**: Extra Tooltip, Detailed Minimap, Quest & Character Tracker,
  My Little Black Book, Museum Tracker, Always Show Item Value, Mod Menu
- **Resources/cheats**: Infinite Energy, EnergyPlus, ManaPlus, Daily Mana Modifier,
  Energy Multiplier, EasyMoney, Item Duplication, item spawners
- **Critters/fishing**: CritterPlus, Calm Critters and Soulblobs, FishingPlus
- **Nokturna minigame**: Nokturna Auto Win, Unlimited Nokturna, Nokturna Portrait Studio
- **Social**: Gift Taste Multiplier
- **Decorating**: Free Decorate, Place Items Diagonally, Gates and Diagonal Fences,
  Fippsie's Fences and Gates
- **Shops**: Always Open Shops, Resourceful Shops, Yabbis Sells Gramophone
- **Weather**: Weather Manipulator
- **Spells/tools**: MoonlightQuickSpells, MoonlightAutoToolSelect, Serena's Grimoire
- **Frameworks**: Serena's Enchanted Studio, Fippsie's TSF, Serena's Portrait Replacer,
  Translation Toolkit
- **Cosmetic/content**: many portrait packs, Dash the Familiar, Fippsie's HellPuppy
- **Translations**: FR, ES, PL, PT-BR

**Still empty after three sweeps** (2026-08-02, and twice on 2026-08-03): photo mode / UI
hiding, crop chore automation, auto-sell. World-hover plant growth info was on this list and is
now being built as [Plant Peek](mods/PlantPeek/README.md).

**Also empty as of the 2026-08-04 sweep**: UI/text scaling and accessibility generally
(Rung 5), AFK/idle handling, and **any display of a world object's remaining health**
(Rung 6 — `health`, `damage`, `durability` and `chop` all return zero results), and **moving
planted crops in decorate mode** (Rung 7 — `plant` returns 3 results, none of which move
anything, and Serena's Conjuring explicitly excludes crops from its building-mover).

The third sweep sorted by date rather than downloads, per the lesson at the top of this page.
Listing total was 88 including Chest Labels, and nothing had been published since it — so the
occupied-territory map below still holds as written.

*(Chest labels was on this list and is now built. Cross-chest item search was on it and has
been removed — Catalog QoL covers most of that ground.)*

### Verified by decompiling installed mods, not just descriptions

Nexus descriptions overstate coverage. Extra Tooltip says "crop growth times", which sounds
like it owns the plant-growth space — but all 18 of its Harmony patches target menu widgets,
none touch world objects. **When an idea looks taken, decompile the DLL before giving up.**

Installed locally and available to read: `MoonlightPeaksExtraTooltip.dll` (the richest —
18 patches, TMPro/Unity UI usage, config patterns), `MoonlightMinimap.dll`, `Far Sight.dll`,
`Save Anywhere.dll`, `FasterGrowth.dll`. All in `BepInEx\plugins\`. Same `ilspycmd` workflow
as [09-exploring-the-assembly.md](09-exploring-the-assembly.md).

## What to build next

With Chest Labels done, the ranking has shifted — the world-hover machinery it produced makes
one idea substantially cheaper than it was.

1. ~~**Plant Growth Info on Hover**~~ (Rung 4). **Taken — this is what is being built.** The
   prediction held: reusing `HoverLabel.cs` made it cheap, and the remaining work really is
   reading `GrowablePersistence` and formatting requirements. See
   [mods/PlantPeek](mods/PlantPeek/README.md).
2. ~~**Bigger UI & Text**~~ (Rung 5, added 2026-08-04). **Taken — in progress at v0.4.0.**
   It jumped the queue for a reason the download counts can't show: a specific person who
   wants to play this game and finds the text too small.
3. ~~**Health Bars on Trees and Rocks**~~ (Rung 6, added 2026-08-04). **Done in a day —
   [Last Swing](mods/LastSwing/README.md) v0.2.0 works in game.** The "cheapest idea on this
   page" call was right, and by a wide margin: five source files, no Harmony patch, and it ran
   correctly the first time it was launched — the only mod here that has. The reason is worth
   generalising: **`SwingToolView.Target` meant not building world hover at all.** Chest Labels
   and Plant Peek each built their own and then spent versions reconciling their reach with the
   game's; reading the game's own answer cannot disagree with it. Before building any world-UI
   mod, look for whatever the game already tracks as "the thing being pointed at".
   `GameWorldUIScreen` was **not** used — see the mod's README for why, and treat it as the
   first thing to revisit.
4. **Move Planted Crops in Decorate Mode** (Rung 7, added 2026-08-04). **Researched, not
   started.** The strongest candidate on this list right now, for a reason none of the others
   have: the scene's most-downloaded decorate mod publicly documented *not* doing it. The gate
   is one method, there is no hover system to build, and the whole difficulty is a single
   knowable fact — watering is keyed by cell, not by plant. See
   [mods/Transplant/research](mods/Transplant/research/01-moving-growables.md).
5. **Photo Mode.** Still unclaimed after a third full sweep. Shares little with what has been
   built, so it is mostly fresh work — but it is a clean, self-contained gap.
6. ~~**Cross-chest item search.**~~ Demoted. Catalog QoL already searches storage screens
   including farm storage; only cross-*placed-chest* locating is missing, and Craft from
   Chests blunts even that. See the note under "Also viable".

Auto-Water is still a genuine gap and still the strongest "real mod" idea, but it writes to
world state, which is the one area none of this work has touched yet.

## The five-minute feasibility check

Before committing to any idea, once the game is installed:

1. Decompile `Vampire.Runtime.dll` (ILSpy)
2. Search for the class that owns the behavior
3. Look at the method you'd need to patch

**If it's a clean public method** → the mod is a weekend.
**If the logic is buried inside a 300-line `Update()`** → pick a different idea.

This check is worth more than any amount of upfront planning.

## Conventions to follow from day one

### Nothing ships looking bolted on

**If a player can tell which pixels are modded, that is a defect.**

Full guidance, the game's fonts and palette, and reusable code:
**[10-visual-integration.md](10-visual-integration.md)**. Read it before writing UI.

### Other conventions

- Expose settings via `Config.Bind` — you get [Mod Menu](https://www.nexusmods.com/moonlightpeaks/mods/102)
  and ConfigurationManager support for free, which is the scene's expectation.
- Say plainly in the description whether it's **save-safe** and whether it's
  **comfort or cheat**. This community cares about the distinction, and the mods that state
  it clearly have the better endorsement ratios.
- Avoid F1 as a default hotkey — it collides with Serena's Grimoire and ConfigurationManager.
