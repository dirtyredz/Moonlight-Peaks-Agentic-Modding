# Visual Integration — Don't Ship Bolted-On UI

**If a player can tell which pixels are modded, that is a defect.** Not a polish item for
later — a defect, at the same level as a bug.

This applies to every mod in this repo. Read it before writing any UI code.

---

## Why this doc exists

Chest Labels v0.6.0 shipped to Nexus with its world hover label rendering in Unity's stock
TextMeshPro font, while the same mod's in-panel title correctly used the game's Gelica.

The cause is worth understanding, because it will happen again otherwise:

- The **in-panel title** was parented inside a game screen. It borrowed its font from a
  neighbouring text element, so it looked right *by accident of location*.
- The **hover label** lives on the mod's own canvas. There is no neighbour to copy, so every
  property falls back to a Unity default — and every Unity default is wrong for this game.

Both were "add a text element". They are not the same job.

> **UI parented inside a game screen inherits the right look for free.
> UI on your own canvas inherits nothing.**
> Floating labels, world-space text and custom overlays need the *most* scrutiny, not the least.

---

## The game's assets

Measured from the shipped game — no need to rediscover any of this.

### Fonts

| Asset | Notes |
|---|---|
| **Gelica-Bold** | What the game's UI headers use. The default choice. |
| Gelica-Black, Gelica-Regular | Other weights |
| Gelica-Bold-Italic, Gelica-Regular-Italic | Italics |
| **`Gelica-Bold-Outline`** | Material preset — the game's own treatment for text that must read against the world |
| `Gelica-Bold-Glow`, `Gelica-Black-Glow` | Glow presets |
| Calistoga, Janitor, Nunito | Used elsewhere in the UI |

Material presets are **Materials**, not font assets — they need a separate lookup.

### Palette

| Use | Hex |
|---|---|
| Panel fill | `#1B0F2E` deep plum |
| Panel rim | `#C7A25B` muted gold |
| Text / item counts | `#F7D994` warm gold |
| Outline / ink | `#2A1B3D` |

### Shape and icons

- Panels are **rounded with a lighter rim**. Flat rectangles read as modded instantly.
- **1,659 `Icon_*.png` sprites** ship with the game. Check for an existing one before drawing
  your own. There is no pencil, quill or edit icon — that gap is real, and why Chest Labels
  generates one.

---

## Reusable code

Both live in `mods/ChestLabels/src/` and are written to be copied:

| File | Does |
|---|---|
| `GameFonts.cs` | Resolves Gelica and its outline preset from loaded assets, with fallbacks. `GameFonts.Apply(text, preferOutline: true)` |
| `PanelSprite.cs` | Generates a 9-sliced rounded plate in the game's palette — corners hold their radius at any width |
| `PencilIcon.cs` | Pattern for generating an icon procedurally when the game has none |

---

## The checklist

Before any UI element is considered done:

1. **Font** — the game's own. Never leave `TMP_Settings.defaultFontAsset` as the intended
   path; it is a fallback only. Grep for it before shipping.
2. **Colour** — sample the palette above. Do not invent one.
3. **Shape** — rounded, with a rim. Not a flat rectangle.
4. **Reuse before generating** — check the game's icons and material presets first.
5. **Ask explicitly:** *would a player know this was not in the base game?* Answer it for
   every element, including the ones that look fine.

---

## Related

- [04-first-mod-walkthrough.md](04-first-mod-walkthrough.md) — building the plugin itself
- [09-exploring-the-assembly.md](09-exploring-the-assembly.md) — finding assets and hooks
- [mods/ChestLabels/README.md](mods/ChestLabels/README.md) — the same principle applied to a
  real mod, with its own history
