# FEATURES — mod inventory

What exists across the workspace. Each mod is a standalone repo under `mods/`; this is the roll-up.
Versions/statuses mirror [../README.md](../README.md) — update both together.

## Published on Nexus

| Mod | Ver | Nexus | What it does |
|---|---|---|---|
| ChestLabels | 1.0.1 | [119](https://www.nexusmods.com/moonlightpeaks/mods/119) | name your chests |
| PlantPeek | 1.0.1 | [120](https://www.nexusmods.com/moonlightpeaks/mods/120) | growth info on plant hover |
| CoffinBreak | 1.0.1 | [121](https://www.nexusmods.com/moonlightpeaks/mods/121) | stops the clock when AFK |
| LastSwing | 1.0.0 | [122](https://www.nexusmods.com/moonlightpeaks/mods/122) | health bars on trees/rocks |
| Transplant | 1.0.0 | [126](https://www.nexusmods.com/moonlightpeaks/mods/126) | move planted crops |
| ModNook | 1.0.0 | [127](https://www.nexusmods.com/moonlightpeaks/mods/127) | every mod's settings in the pause menu |
| Vampscape | 1.0.1 | [128](https://www.nexusmods.com/moonlightpeaks/mods/128) | zoom the camera out in build mode |
| FormLock | 1.0.0 | [141](https://www.nexusmods.com/moonlightpeaks/mods/141) | keeps Cat/Bat/Aqua form through pickups/harvests |
| PurrtasticPalette | 1.1.0 | [142](https://www.nexusmods.com/moonlightpeaks/mods/142) | recolours Cat Form (fur, whiskers, eyes, trail) |
| FangtasticPalette | 1.0.0 | [143](https://www.nexusmods.com/moonlightpeaks/mods/143) | recolours Bat Form (body, wings, face, trail) |

## In progress (unpublished)

| Mod | Ver | Status |
|---|---|---|
| BiggerUI | 0.10.0 | scales UI font sizes for readability. **Missing `pack.ps1`** — not release-ready |
| DeadReckoning | 0.x | floating skull that steers you to a tracked NPC/place/map-pin; replaces Quest & Character Tracker idea |

## Shared tooling / capabilities

- **nexus-publish skill** — Chrome automation to publish/update a mod page, restyle a description, or
  deploy a new page.
- **Per-mod `pack.ps1`** — builds the Nexus-layout release zip from the single-source csproj version.
- **`Directory.Build.props`** — shared game DLL references + `GenerateModBuildInfo` version target
  (present in most mods; see [BACKLOG.md](BACKLOG.md) for the gaps).
- **Tastic Palette series** — reusable form-recolour methodology (Purrtastic→Fangtastic→planned
  Fintastic); see [ROADMAP.md](ROADMAP.md).

_Living doc — refresh with /project-docs when it drifts._
