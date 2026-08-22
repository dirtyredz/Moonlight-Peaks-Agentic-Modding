# Moonlight Peaks Modding Notes

Working notes on the Moonlight Peaks mod scene and how mods are actually built — and the
twelve mods built from them (ten published, two in progress).

**Snapshot date:** 2026-08-04. The game launched 2026-07-07, so everything here is
about a month old and moving fast — re-check numbers and tool versions before relying on them.

## Contents

| File | What's in it |
|---|---|
| [01-mod-landscape.md](01-mod-landscape.md) | What the mod scene looks like, top mods by downloads, who the notable authors are, where the gaps are |
| [02-installing-mods.md](02-installing-mods.md) | Getting BepInEx + mods running on your own install (do this first — it's also step 1 of dev setup) |
| [03-dev-environment.md](03-dev-environment.md) | Full toolchain setup: .NET, Unity 6.3 LTS, game DLL references |
| [04-first-mod-walkthrough.md](04-first-mod-walkthrough.md) | Copy-pasteable "hello world" plugin, csproj, auto-deploy, Harmony patching |
| [05-custom-assets.md](05-custom-assets.md) | The harder path: new models/items/portraits via Unity Addressables |
| [06-resources.md](06-resources.md) | Every link worth keeping |
| [07-our-setup.md](07-our-setup.md) | **Start here** — what's on this machine, what's missing, honest capability assessment |
| [08-mod-ideas.md](08-mod-ideas.md) | Candidate first mods, ranked by learning value, with the gaps they fill |
| [09-exploring-the-assembly.md](09-exploring-the-assembly.md) | Decompiling `Vampire.Runtime.dll` — working commands, gotchas, architectural patterns |
| [10-visual-integration.md](10-visual-integration.md) | **Read before writing any UI.** The game's fonts, palette and shapes — and why modded-looking pixels are a defect |
| [11-mod-data-and-saves.md](11-mod-data-and-saves.md) | **Read before storing anything.** Sidecar files keyed by the game's GUIDs, and why reusing a game field bit us |
| [12-versioning-and-release.md](12-versioning-and-release.md) | Version numbers are for players, not builds. Archive layout, config-upgrade traps, release checklist |
| [13-nexus-page-standard.md](13-nexus-page-standard.md) | **Read before writing a mod page.** The Requirements / Installation / Shout outs boilerplate every listing shares, the drift it exists to stop, and how the edit form actually behaves |
| [14-description-review.md](14-description-review.md) | The 2026-08-04 review of all six live pages — section order, where Mod Nook belongs, and the two proposals that were rejected |
| [15-page-style.md](15-page-style.md) | **Read before styling a mod page.** Palette, element vocabulary, per-mod emoji, and the `[line]` trap that silently drops every horizontal rule |
| [16-recolouring-characters.md](16-recolouring-characters.md) | **Read before changing any colour in the world.** Why material writes silently do nothing, HSV colorize, reading non-readable textures, and the shared gradient atlas |
| [17-wardrobe-ui.md](17-wardrobe-ui.md) | **Read before adding UI to the customization screens.** Adding a wardrobe tab, driving the preview, cloning the game's swatch/header widgets, and the layout flags that silently blank the panel |

## Mods

Ten published, two in progress. Root docs (`01`–`17`) are general and apply to every mod; each
mod has its own directory under `mods/` with its own README, research notes, source and
release process.

| Mod | Version | Status |
|---|---|---|
| [mods/ChestLabels](mods/ChestLabels/README.md) | 1.0.1 | 🚀 [Nexus mod 119](https://www.nexusmods.com/moonlightpeaks/mods/119) — name your chests |
| [mods/PlantPeek](mods/PlantPeek/README.md) | 1.0.1 | 🚀 [Nexus mod 120](https://www.nexusmods.com/moonlightpeaks/mods/120) — growth info on plant hover |
| [mods/CoffinBreak](mods/CoffinBreak/README.md) | 1.0.1 | 🚀 [Nexus mod 121](https://www.nexusmods.com/moonlightpeaks/mods/121) — stops the clock when you go AFK |
| [mods/LastSwing](mods/LastSwing/README.md) | 1.0.0 | 🚀 [Nexus mod 122](https://www.nexusmods.com/moonlightpeaks/mods/122) — health bars on trees and rocks |
| [mods/Transplant](mods/Transplant/README.md) | 1.0.0 | 🚀 [Nexus mod 126](https://www.nexusmods.com/moonlightpeaks/mods/126) — move planted crops |
| [mods/ModNook](mods/ModNook/README.md) | 1.0.0 | 🚀 [Nexus mod 127](https://www.nexusmods.com/moonlightpeaks/mods/127) — every mod's settings in the pause menu |
| [mods/Vampscape](mods/Vampscape/README.md) | 1.0.1 | 🚀 [Nexus mod 128](https://www.nexusmods.com/moonlightpeaks/mods/128) — zoom the camera out in build mode |
| [mods/FormLock](mods/FormLock/README.md) | 1.0.0 | 🚀 [Nexus mod 141](https://www.nexusmods.com/moonlightpeaks/mods/141) — keeps Cat/Bat/Aqua form on through pickups and harvests |
| [mods/PurrtasticPalette](mods/PurrtasticPalette/README.md) | 1.1.0 | 🚀 [Nexus mod 142](https://www.nexusmods.com/moonlightpeaks/mods/142) — recolours Cat Form's fur, whiskers, eyes and trail |
| [mods/FangtasticPalette](mods/FangtasticPalette/README.md) | 1.0.0 | 🚀 [Nexus mod 143](https://www.nexusmods.com/moonlightpeaks/mods/143) — recolours Bat Form's body, wings, face and trail |
| [mods/BiggerUI](mods/BiggerUI/README.md) | 0.10.0 | in progress; scales UI font sizes for readability, unpublished |
| [mods/DeadReckoning](mods/DeadReckoning/README.md) | 0.x | in progress; floating skull that steers you to a tracked NPC, place or map pin, unpublished |

Page copy for the published mods lives in each mod's `NEXUS.md` (the readable draft) and `nexus-paste.md`
(the unwrapped version that actually goes into the upload form). What they must agree on is in
[13-nexus-page-standard.md](13-nexus-page-standard.md).

## Folder layout

This directory **is its own git repository** (tracking the shared notes and the mod index), and it
also **contains** the mod directories — each of which is its own separate repo. Git tooling here
never descends into the nested mod repos; they're tracked and released independently.

```
.
├── 01-17 *.md              general modding notes, apply to any mod
├── dist/                   packaged release archives
├── save-backup-*/          pre-modding save backups — never publish these
└── mods/
    ├── <ModName>/
    │   ├── README.md               design, decisions, and why they were made
    │   ├── CHANGELOG.md            version history, incl. what was decided against
    │   ├── NEXUS.md                mod page draft + screenshot shot list
    │   ├── nexus-paste.md          the same copy unwrapped, for the upload form
    │   ├── RELEASING.md            packaging and pre-release checklist
    │   ├── TESTING.md              running log of what was tested and what broke
    │   ├── Directory.Build.props   shared game paths and DLL references
    │   ├── pack.ps1                builds dist/<ModName>-<version>.zip
    │   ├── research/               decompilation and save-format findings
    │   ├── screenshots/            for the Nexus page
    │   ├── src/                    the plugin (netstandard2.1)
    │   └── tests/                  console test runner (net8.0, no framework)
    └── …
```

**Standard mod layout.** Each mod under `mods/` is self-contained: docs and `pack.ps1` at its
root, `Directory.Build.props` beside them, and the plugin's `.cs` files **directly in `src/`**
— no folder inside `src/` named after the mod. Not every mod has every file; `research/`,
`tests/` and `TESTING.md` appear where they earned their place.

## Keep out of anything published

- **`save-backup-*/`** — pre-modding save backups. They contain a Steam ID and personal save
  data and must never be uploaded anywhere.
- **Decompiled game code** — kept in a scratch directory outside this folder. It is derived
  from the shipped game. See [09-exploring-the-assembly.md](09-exploring-the-assembly.md) to
  regenerate it.
- **`dist/`, `bin/`, `obj/`** — build output.

## The 30-second version

- Moonlight Peaks is a **Unity Mono** game (not IL2CPP), which makes it easy to mod.
- There is **no official mod API**. The community standardized on **BepInEx 5 (win_x64)**
  as the loader and **HarmonyX** for runtime patching of the game's own code.
- The game's own logic lives in `Vampire.Runtime.dll` — that's the assembly you reference
  and patch against.
- Code-only mods (QoL, tweaks, cheats) are a normal C# class library: ~30 lines to get
  something loading. This is the realistic starting point.
- Content mods (new items, models, portraits) additionally need Unity 6.3 LTS +
  Addressables 2.8.1 to build asset bundles.
- The [official wiki](https://moonlightpeaks.wiki.gg/wiki/Modding) has a genuinely good
  15-guide series. It's the primary source for most of these notes.
- **If a mod draws anything on screen, read
  [10-visual-integration.md](10-visual-integration.md) first.** The game uses Gelica with its
  own outline presets and a specific plum/gold palette; Unity's defaults are all wrong, and a
  released mod has already shipped with the wrong font because this was not written down.

## Platform caveat

Modding is **PC/Steam only**. The Switch, Switch 2, and Google Play builds can't load
BepInEx.
