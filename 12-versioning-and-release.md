# Versioning and Release

Applies to every mod in this repo.

---

## The version number is for players, not for us

**It is not a build counter.** It moves only when something is published.

Chest Labels development produced 0.7.0 through 0.11.4 as build iterations while converging
on a look — roughly a version bump per round of feedback. None were published. Shipping
0.11.4 straight after a published 0.6.0 would have implied five minor releases nobody could
have installed, disrupted anyone tracking versions, and made the mod look like it churns.
They were collapsed into a single **0.7.0**.

### Rules

- **The first published version of a mod is `1.0.0`.** Whatever the development builds were
  numbered, the number players first see is 1.0.0. A 0.x on the listing invites "is this
  finished?" from people deciding whether to install, and every dev build before the first
  release is folded into that entry anyway. Chest Labels shipped 0.6.0 and Plant Peek 1.0.0 —
  **1.0.0 is the rule going forward.**
- **Bump only when publishing**, as the last step before packaging.
- **Iterate without touching it.** Rebuild and redeploy as often as needed; the number stays
  put. A dev build and the release before it can share a version — only the published one
  matters.
- **One CHANGELOG entry per released version**, not per build. Fold the iterations into the
  release entry, including anything tried and reverted; that history is useful and belongs
  there rather than in five stub entries.
- **The version lives in one place: `<Version>` in the csproj.** An MSBuild target
  (`GenerateModBuildInfo`, in each mod's `Directory.Build.props`) generates a compile-time
  `ModBuildInfo.Version` constant from it, and `Plugin.cs` sets
  `PluginVersion = ModBuildInfo.Version`. So the attribute BepInEx reports and the archive name
  `pack.ps1` builds both come from the csproj and can never disagree. **Never hardcode a version
  string in `Plugin.cs`** — bump the csproj only. (New mods inherit this by copying an existing
  mod's `Directory.Build.props`.)

### What each part means

| Bump | When |
|---|---|
| Patch | Bug fixes, no behaviour change |
| Minor | New features, or a visible change of look |
| Major | Save or config format changes in a way that is not backwards compatible |

---

## Release archive layout

Nexus and Vortex expect the archive to mirror the game folder:

```
<ModName>-<version>.zip
└── BepInEx/
    └── plugins/
        └── <ModName>/
            └── <ModName>.dll
```

Note this is **not** the dev deploy path. Chest Labels deploys locally to
`plugins/MoonlightPeaksMods/<ModName>/` purely to keep hand-built DLLs clear of Vortex during
development. Players get the plain `plugins/<ModName>/` layout.

`mods/ChestLabels/pack.ps1` is a working example: it reads the version from the csproj so the
archive can never disagree with the DLL, runs the tests and refuses to package if they fail,
and builds with `SkipDeploy=true` so packaging never overwrites the copy under test.

---

## Config settings survive upgrades

**BepInEx preserves existing values in a user's `.cfg`.** Changing a default in code does
nothing for anyone who already has the mod — this cost several rounds of confusion during
Chest Labels development, where new defaults appeared to have no effect.

Consequences worth designing around:

- A setting whose **meaning** changes is a breaking change. Rename the key instead, so old
  values are dropped rather than silently misapplied.
- New keys do get their defaults, so adding a setting is safe.
- When testing a default change locally, edit the live `.cfg` as well or you are still
  testing the old value.

---

## Pre-release checklist

Visual integration first — it is the easiest thing to ship wrong. See
[10-visual-integration.md](10-visual-integration.md).

- [ ] Every text element uses the game's font. Grep for `defaultFontAsset`; it should appear
      only as a fallback
- [ ] Colours come from the game's palette
- [ ] No flat rectangles where the game would use a rounded, rimmed panel
- [ ] `<Version>` in the csproj was bumped for **this release** (`Plugin.cs` derives from it via
      `ModBuildInfo.Version`, so there is nothing to keep in sync)
- [ ] CHANGELOG has one entry for this version
- [ ] Tests pass
- [ ] Diagnostics default to off
- [ ] Tested on a **fresh install** — delete the config, launch, confirm sensible defaults
- [ ] Save verified untouched, per [11-mod-data-and-saves.md](11-mod-data-and-saves.md)
- [ ] Screenshots show the **current** build, not a previous release
- [ ] Archive extracted onto a clean install and verified in game

---

## Commit and tag every release

Each mod is its own git repo (`origin` on GitHub under `dirtyredz`). Commit under the `dirtyredz`
identity that global git config is set to — **never a work email**. A published version must be a
real, tagged commit:

1. **Commit the release as one commit** — the csproj bump, the CHANGELOG entry, and any release
   code together. Do not publish from an uncommitted working tree. (Chest Labels 1.0.1 and Plant
   Peek 1.0.1 were shipped uncommitted and had to be reconstructed afterwards — the thing this
   rule exists to prevent.)
2. **Tag it** annotated at that commit and push branch and tag:

   ```bash
   git tag -a v1.2.3 -m "Release 1.2.3"
   git push origin main
   git push origin v1.2.3
   ```

3. The `vX.Y.Z` tag is the record of exactly what shipped to Nexus. One tag per published
   version; dev builds are not tagged.
