# ARCHITECTURE — the modding system

How the system these notes describe actually works, end to end. For *where files live* see
[../STRUCTURE.md](../STRUCTURE.md).

## System overview

Moonlight Peaks is a **Unity Mono** game (not IL2CPP). There is **no official mod API**; the
community standardized on **BepInEx 5 (win_x64)** as the loader and **HarmonyX** for runtime
patching. Game logic lives in `Vampire.Runtime.dll` — the assembly every mod references and patches.

A mod is a normal C# class library targeting **netstandard2.1**, loaded by BepInEx at startup. QoL
/ tweak mods are code-only (~30 lines to load). Content mods additionally need Unity 6.3 LTS +
Addressables 2.8.1 to build asset bundles. Platform: **PC/Steam only** (Switch/mobile can't load
BepInEx).

## Two install paths (deliberately different)

| Path | Location | Purpose |
|---|---|---|
| **Dev deploy** | `plugins/MoonlightPeaksMods/<Mod>` | hand-built DLLs during dev, kept clear of Vortex |
| **Release** | `BepInEx/plugins/<Mod>/<Mod>.dll` | what `pack.ps1` builds; what Nexus/Vortex expect |

`pack.ps1` builds with `-p:SkipDeploy=true` so a release build never overwrites the copy under test.

## Version single-source chain

The version lives in **exactly one place** and flows outward so nothing can disagree:

```
<Version> in src/<Mod>.csproj
   │  MSBuild target GenerateModBuildInfo (in Directory.Build.props)
   ▼
ModBuildInfo.Version  (compile-time constant)
   │  Plugin.cs: PluginVersion = ModBuildInfo.Version
   ▼
BepInEx-reported version  ── and ──  pack.ps1 reads the csproj for the archive name
```

**Never hardcode a version in `Plugin.cs`.** Bump the csproj only, and only when publishing (see
[DECISIONS.md](DECISIONS.md) and root `12-versioning-and-release.md`). First published version of any
mod is `1.0.0` regardless of dev build numbers.

> Caveat: `GenerateModBuildInfo` lives in `Directory.Build.props`, which **CoffinBreak and PlantPeek
> lack** — so this exact chain doesn't hold for them; confirm how those two source their version
> before relying on it. Standardizing this is tracked in [BACKLOG.md](BACKLOG.md).

## Release flow

1. Bump `<Version>` in the mod's csproj (last step before packaging).
2. Update the mod's `CHANGELOG.md` (one entry per released version).
3. Run the mod's `pack.ps1` → builds `Release`, stages `BepInEx/plugins/<Mod>/<Mod>.dll`, writes
   `dist/<Mod>-<version>.zip` (Nexus layout). Some copies also mirror into the shared root `dist/`.
4. Publish/update the Nexus page via the **nexus-publish** skill.

## Nexus page pipeline

Page copy has two synchronized forms per mod: `NEXUS.md` (readable draft + screenshot shot list) and
`nexus-paste.md` (unwrapped copy that goes into the upload form). The shared boilerplate
(Requirements / Installation / Shout outs) and the edit-form behaviour they must respect are in root
`13-nexus-page-standard.md`; styling rules in `15-page-style.md`.

## External interfaces

- **Nexus Mods** — hosting/distribution; driven by the nexus-publish Chrome skill.
- **BepInEx / HarmonyX** — load + patch runtime.
- **Vortex** — Nexus's mod manager; the dev-deploy path exists to stay out of its way.
- **Game saves** — mods store data in **sidecar files keyed by the game's GUIDs**, never by reusing
  game fields (root `11-mod-data-and-saves.md`).

_Living doc — refresh with /project-docs when it drifts._
