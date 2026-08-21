# Nexus Page Style

The visual language for every mod page. [13-nexus-page-standard.md](13-nexus-page-standard.md)
covers *structure and mechanics*; this file covers *how it looks*.

Applied to all six pages on 2026-08-04.

---

## Palette

Straight from [10-visual-integration.md](10-visual-integration.md), so the pages match the
banners and thumbnails rather than inventing a second identity.

| Token | Hex | Used for |
|---|---|---|
| Warm gold | `#F7D994` | Mod title, section headings, bold lead-ins inside panels |
| Gold rim | `#C7A25B` | Tagline (italic), the at-a-glance strip |
| Muted plum | `#7A6A9B` | Horizontal rules |
| Body | `#D4D4D8` | All prose. Nexus's own body colour |

---

## Element vocabulary

```bbcode
[size=6][color=#F7D994]📦  Chest Labels[/color][/size]
[color=#C7A25B][i]One-line pitch — same text as the short description.[/i][/color]
[color=#C7A25B]💾 Save-safe  ·  ⚙️ BepInEx 5  ·  ✏️ Rename in game  ·  🎨 Configurable[/color]
[color=#7A6A9B]────────────────────────────────────────[/color]
[quote]💾  [color=#F7D994][b]The promise.[/b][/color] The one thing this mod guarantees.[/quote]

[size=5][color=#F7D994]🌙  What it does[/color][/size]
[color=#D4D4D8]Prose…[/color]
```

- **Title** — emoji, two spaces, Title Case. `[size=6]`, gold. Never centered.
- **Tagline** — italic gold rim, the short description verbatim.
- **At-a-glance strip** — four emoji facts separated by ` · `. Must be *true* for that mod;
  don't paste one mod's strip onto another.
- **Rule** — see the trap below.
- **Promise panel** — `[quote]` renders as a raised block with a gold left bar, which is the
  gold-rim-on-plum motif from the art. One near the top carrying the mod's central guarantee,
  one in Configuration carrying the Mod Nook pitch.
- **Headings** — `[size=5]` gold, emoji + two spaces + Title Case, left-aligned.
- **Spoiler** — `[spoiler]` for long tails. Only Mod Nook uses it, for *For mod authors*.

Two spaces after the emoji, not one — a single space reads cramped at `size=5`.

### Per-mod

| Mod | Title emoji | Promise panel |
|---|---|---|
| Chest Labels | 📦 | 💾 Save-safe — names live in the mod's own file |
| Plant Peek | 🌱 | 💾 Save-safe — read-only, no Harmony patches |
| Coffin Break | ⚰️ | ⏸️ Stops the clock, not the game |
| Last Swing | 🪓 | 🍃 Comfort, not a cheat |
| Transplant | 🌿 | 🛟 It refuses to let you ruin one |
| Mod Nook | 🎛️ | 📝 Your config files do not change |

Section emoji are shared so the six read as a set: ✨ Main features · 📋 Requirements ·
📥 Installation · 🎛️ Configuration · 🤝 Compatibility · 💜 Shout outs. The *What it does*
emoji varies per mod (see above). Mod Nook adds 🧩 Mods it configures and 🛠️ For mod authors.

Inside Installation: `[b]🟢 With Vortex[/b]` and `[b]🔧 Manually[/b]`.

---

## ⚠️ The `[line]` trap

**`[hr]` does not work, and it fails silently.**

SCEditor accepts `[hr]`, renders a rule in the editor, and rewrites it to **`[line]`** on save.
Nexus's public renderer then **strips `[line]` entirely**. The editor shows three rules; the
live page has none, with no error anywhere.

This shipped to all six pages before verification caught it.

Use a character rule instead:

```bbcode
[color=#7A6A9B]────────────────────────────────────────[/color]
```

Forty `─` (U+2500), left-aligned, no ornaments. **Verify rules on the live page, never in the
editor** — the editor is not a preview of what Nexus will serve.

---

## What we deliberately do not do

The page that prompted this look is *Enchanted Nightfall* (mod 124), and an early pass copied
it closely enough to be obvious. Its signature is off limits:

- ❌ `☾ NAME ☽` moon brackets around the title
- ❌ `✦ ───────────── ☾ ───────────── ✦` ornamented centered dividers
- ❌ Centered ALL-CAPS section headings
- ❌ Lilac `#D9B8FF` / periwinkle `#AFC5FF` / pink `#F2A9D5`

Ours is the inverse on every axis: left-aligned, Title Case, unornamented rules, gold. The
elements that carry our flair — `[quote]` panels and `[spoiler]` — are ones Nightfall never
uses at all.

Other authors' looks are theirs. If a future page needs a fresh element, take it from the
game's own art, not from another mod's listing.

---

## Driving this from an agent

`/nexus-publish` (`.claude/skills/nexus-publish/SKILL.md`) points an agent at this file plus
[13](13-nexus-page-standard.md) and [14](14-description-review.md), and walks it through
driving Chrome to upload a file version, restyle a page, or stage a new mod listing. It
carries the SCEditor recipe, the three silent-failure traps, and the standing decisions.
