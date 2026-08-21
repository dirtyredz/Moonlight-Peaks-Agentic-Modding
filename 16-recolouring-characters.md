# Recolouring Characters and Objects

**Read before writing any mod that changes a colour on something in the world.**

Everything here was learned building [mods/PurrtasticPalette](mods/PurrtasticPalette/README.md) (Cat
Form) and [mods/TrueColors](mods/TrueColors/HANDOFF.md) (player hair). Most of it cost hours to
find and none of it is guessable from the outside.

---

## 1. The game overrides materials with MaterialPropertyBlock

**This is the one that will waste your day.** The game's customization system writes through
property blocks, not material properties:

```csharp
// ShaderCustomizationModifier.Apply()
MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();
if (renderer.HasPropertyBlock()) renderer.GetPropertyBlock(propertyBlock, j);
colorProperties.ForEach(x => propertyBlock.SetColor(x.GetName(), x.Value));
SetPropertyBlock(renderer, propertyBlock, j);
```

A `MaterialPropertyBlock` **overrides the material's own values at draw time**. If a renderer has
one, your `material.SetColor()` / `material.SetTexture()` is stored correctly and then never
rendered. There is no error, and reading the property back returns *your* value — so logging
looks perfect while the screen does not change.

Write through the block instead, read-modify-write per material index so you don't clobber what
the game put there:

```csharp
var block = new MaterialPropertyBlock();
if (renderer.HasPropertyBlock()) renderer.GetPropertyBlock(block, materialIndex);
block.SetTexture("_BaseMap", myTexture);
renderer.SetPropertyBlock(block, materialIndex);
```

Log `renderer.HasPropertyBlock()` early. If it's `true`, material writes are pointless.

Related: `MaskColorPropertyBlock` is a game component that does the same thing for simple tints;
it stores `property` and `color` as private serialized fields (reflection to read them).

## 2. Recolour with HSV colorize, not an RGB multiply

A tint multiplies the source: `result = source.rgb * target.rgb`. That fails in two ways.

- **A channel the source lacks can never appear.** Blue onto an orange texture stays black —
  `0 * anything = 0`. This is why a naive tint can only ever darken toward existing hues.
- **Dark regions turn to mud** rather than becoming dark versions of the target colour.

Take the target's hue and saturation, keep the source pixel's brightness:

```csharp
Color.RGBToHSV(target, out var h, out var s, out _);
Color.RGBToHSV(src, out _, out _, out var v);
var result = Color.HSVToRGB(h, s, v * targetV);
```

`Color.RGBToHSV`/`HSVToRGB` handle HDR values above 1.0 correctly (pass `hdr: true`), which
matters for particle emission — those routinely sit at 30+.

**Anchor the result to the target's own brightness.** Computing brightness independently of the
picked colour caps vibrancy: a fully vivid target over a dark texture still comes out dim.

## 3. Read textures that aren't marked readable

The game's shipped textures do not have "Read/Write Enabled", so `Texture2D.GetPixels()` returns
nothing. Blit through a `RenderTexture`:

```csharp
var rt = RenderTexture.GetTemporary(w, h, 0, RenderTextureFormat.ARGB32);
var prev = RenderTexture.active;
Graphics.Blit(source, rt);
RenderTexture.active = rt;
var readable = new Texture2D(w, h, TextureFormat.RGBA32, false);
readable.ReadPixels(new Rect(0, 0, w, h), 0, 0);
readable.Apply();
RenderTexture.active = prev;
RenderTexture.ReleaseTemporary(rt);
var pixels = readable.GetPixels();
```

**Cache the results.** A 4096×4096 regeneration is not something to do per frame; key the cache
by (source texture, colour, any thresholds).

**Meshes are a different story.** `mesh.uv` and `mesh.vertices` are empty for the same reason,
and `Mesh.AcquireReadOnlyMeshData` *throws* rather than working around it. There is currently no
known way to read UVs at runtime — so UV-based region masking is not available.

## 4. `GradientAtlas` is a shared palette, not per-object art

Several characters' materials use the `Game/Atlas/Atlas` shader with an `_Atlas` texture. That
texture is a **game-wide swatch palette**: a grid of narrow vertical strips, each strip a single
colour running dark at one end to light at the other. Which strip a given pixel of the model uses
is baked into the mesh UVs.

Consequences:

- **You cannot pick a region by UV** (see above), so separate regions by *colour* instead.
- **Brightness varies within a strip; hue and saturation do not.** So a brightness threshold cuts
  *across* every strip — on an eye that produced a "top half / bottom half" split rather than
  iris versus pupil. A saturation threshold separates strip from strip, which is the semantic
  boundary you actually want.
- **Saturation cannot separate white from black** — both are fully desaturated. Splitting those
  needs brightness. Cat Form's eye needed both axes: saturation for iris vs. not-iris, then
  brightness for pupil vs. highlight.

## 5. A converted material can have two albedo slots

`HellKitten01` is URP/Lit but still carries `_MainTex`/`_Color` alongside `_BaseMap`/`_BaseColor`
— leftovers from a Standard-shader material that was converted rather than re-authored.
`_WorkflowMode`, `_Glossiness` and `_GlossyReflections` are the tells.

Set **both**, or the untouched slot keeps showing the original texture and the result looks
half-applied.

## 6. Emission is probably not available

URP/Lit multiplies albedo by scene lighting, and Moonlight Peaks is dark. Emission would bypass
that, but Unity **strips unused shader variants at build time**. If a material ships with
`_EmissionColor` black and `_EmissionMap` unset, the `_EMISSION` variant is almost certainly not
in the build, and `material.EnableKeyword("_EMISSION")` silently does nothing.

This was built and tested for Cat Form's fur and had no effect at any strength. Assume emission
is unavailable unless you find a material that already uses it.

If albedo alone comes out too dark, the fix is to stop preserving the source's brightness: on a
near-black texture, recolour at full brightness. Shading still reads correctly because it comes
from real-time lighting and the normal map, not from the albedo.

## 7. Form bodies are separate prefabs

Cat/Bat/Aqua form is not a recoloured player. `FormToolView<T>.HandleEquipped` calls
`EntityCustomization.SetBodyView`, which instantiates a whole different body prefab
(`HellkittenBodyView` for cat).

- Patch **`HandleEnterVisuallySwitchedBodyViews`**, not `HandleEquipped` — the latter fires before
  the async load finishes, so the renderers you want don't exist yet.
- Patch the **closed generic** (`FormToolView<CatToolAsset>`); Bat and Aqua get their own methods,
  so this is also how you scope a patch to one form.
- `BodyViewAsset.RootSkinnedMeshRenderer` is **unset** on at least the cat body. Walk
  `GetComponentsInChildren<Renderer>(true)` instead of trusting that field.
- A fresh material instance exists after every body swap, so caches keyed by `Material` don't need
  eviction — but anything you applied is gone and must be reapplied.

## 8. Something reapplies customization; reapply every frame

Colours applied once to the fur got reverted, silently and on no fixed schedule — most likely the
customization system reinstantiating materials. A once-per-second reapply was *worse* than none:
long enough for the wrong state to be visible, producing a visible pop.

Reapplying every frame in `Update` fixes it and is cheap when the recoloured textures are cached.

**But don't reapply everything.** Cat Form's eyes never showed reversion, and adding them to the
per-frame loop made them flicker and wash out — the signature of fighting another writer at
matched frequency instead of beating it. Reapply what actually needs it.

## 9. Write a probe before writing the feature

Nearly every finding above came from one diagnostic hotkey rather than from reading decompiled
code. Worth building first:

- every renderer under the target, with full hierarchy paths
- every material, and **all** shader properties with values — not just colours. `_MainTex`
  appearing next to `_BaseMap`, and `_EmissionMap` being null, were both found this way.
- `renderer.HasPropertyBlock()` per renderer
- optionally force every colour property to magenta, to see which are wired to anything
- export the source textures to PNG — looking at the atlas is what revealed it was a shared
  palette; no amount of reasoning about pixel statistics would have shown that

`mods/PurrtasticPalette/src/ProbeController.cs` (in git history — the probe was stripped from the
released mod) is a working implementation to copy.

**Wrap each diagnostic in its own try/catch.** An exception in one part silently truncated the
whole dump, which looked like "the probe didn't run" for two rounds of testing.

## 10. Separate features that share a texture with a spatial UV mask — and calibrate it live

When two features share **the same material and the same colour/brightness** (Bat Form's fang
teeth vs. the ear/eye highlights; the nose vs. the cheeks), no hue/value/saturation gate can tell
them apart — every threshold catches both. Confirmed three ways on the bat: the fangs are the same
submesh as the whole head (a material-index probe), the same near-white tone as the rim (a
brightness probe), and spatially mixed with other bright bits (a texture crop). The only handle
left is **location in the texture**: recolour a rectangle in UV space over the pixels the feature
is painted on. `Bat_Body` reads the box as `u = (i % width)/width`, `v = (i / width)/height` (note
`GetPixels` is **bottom-up**, so `v=0` is the texture's bottom), and paints that rectangle its own
colour — flat, or shaded like the rest. Because it's keyed by texture position, not colour, it
isolates one feature even when its colour is identical to its neighbours'.

**The catch: you cannot read the mesh's UVs at runtime (§3), so you don't know where a feature's
box goes.** Guessing the rectangle and rebuilding to check is brutally slow — the bat's nose took
five wrong boxes that way (it kept landing on the chest, the cheek, the fang tips...). Two tools
turn that blind loop into one pass:

- **A UV read-out debug.** Paint every pixel `RGB = (u, v, 0.25)` so its colour *encodes its
  texture coordinate* — red is horizontal, green is vertical. One photo of the target feature and
  you read its `u,v` straight off the colour. This is what finally located the nose after days of
  guessing.
- **Live slider boxes in the wardrobe.** Expose each box's four edges (`uMin/uMax/vMin/vMax`) as
  `ConfigEntry<float>` sliders **in the mirror panel** (gated behind the debug flag). The preview
  recolours live as you drag, so you *drag the box onto the feature while watching it*, no rebuild
  per attempt. Tint each box's slider fill+handle with that region's debug colour (fang=magenta,
  nose=cyan, ...) so the sliders are self-labelling against what they paint on the model. Once
  dialed in, read the values out of the `.cfg`, bake them to constants, and strip the sliders.

This slider-driven approach is dramatically more effective than guess-and-rebuild: the player
calibrates a mask precisely themselves in a single sitting, and every region (fangs, nose, mouth,
a face patch) is just another box + colour. **Expect a rectangular UV box to render as an
irregular, blobby patch on the model** — the mesh's UV layout is not axis-aligned, so a clean
rectangle in the texture maps to a ragged shape in 3D. That's normal and usually fine; it only
bites when two features are interleaved in UV space so tightly that no rectangle separates them.

The reusable pieces live in `mods/FangtasticPalette`: `TextureRecolor.SpatialRegion` +
`InBox`, the `uvDebug` branch, and the `AddBoxSliders` / colour-tinted `AddSliderRow` in
`BatFormColorPanel.cs`.
