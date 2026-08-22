# DECISIONS

Choices worth not re-litigating, newest first. Drawn from the numbered guides, git history, and
prior sessions. Where rationale isn't recorded, it's marked.

## 2026-08-22 — Structure-review gate + living docs on the root repo

**Decision:** Onboard the root repo (this doc set + a pre-push review gate). The root is a real
project (its own git-scoped notes), gated independently of the nested mod repos.
**Why:** Every session was re-deriving the workspace layout from the tree; the cross-mod tooling had
drifted with nothing documenting it. **Rejected:** gating each mod now — deferred; mods are gated on
their own when they warrant it.

## 2026-08-21 — Root working folder put under git

**Decision:** The container folder became its own git repo (initial commit). **Why:** version the
shared notes and the mod index. **Follow-up:** README's stale "not a repository" line corrected
2026-08-22. **Rejected:** keeping it a loose folder — lost history on the shared knowledge base.

## Version is single-sourced from the csproj

**Decision:** `<Version>` in `src/<Mod>.csproj` is the only version; `GenerateModBuildInfo` propagates
it to `ModBuildInfo.Version`, `Plugin.cs`, and `pack.ps1`. Never hardcode a version in `Plugin.cs`.
**Why:** the BepInEx-reported version and the archive name can never disagree. **Rejected:** a version
string in `Plugin.cs` — drifts from the archive.

## Version numbers are for players, not builds; first release is 1.0.0

**Decision:** Bump only when publishing; iterate freely without touching the number; first published
version is always `1.0.0`. **Why:** a build counter would imply releases nobody could install and make
a mod look churny (ChestLabels' 0.7–0.11.4 dev builds collapsed to one release). **Rejected:** shipping
the dev build number; starting listings at 0.x (invites "is this finished?").

## Each mod is a standalone git repo; plugin `.cs` directly in `src/`

**Decision:** Every mod under `mods/` is self-contained with its own repo, docs, and `pack.ps1`;
source sits flat in `src/` (no `src/<ModName>/`). **Why:** a mod must build and release on its own,
cloned outside this workspace. **Consequence:** shared files (`pack.ps1`, `Directory.Build.props`) are
physically copied into each mod, which is why they drift — see [BACKLOG.md](BACKLOG.md).

## Mods store save data in GUID-keyed sidecar files

**Decision:** Persist mod state in sidecar files keyed by the game's GUIDs, never by reusing a game
field. **Why:** reusing a game field bit a mod once (see `11-mod-data-and-saves.md`). **Rejected:**
piggybacking on existing save fields.

## Read the visual/data contracts before drawing or storing

**Decision:** UI must match the game's Gelica font, outline presets, and plum/gold palette
(`10-visual-integration.md`); colour changes go through HSV colorize on the shared gradient atlas
(`16`). **Why:** a released mod already shipped with the wrong font because this wasn't written down.

## Commit identity

**Decision:** Commit as `dirtyredz <dirtyredz@live.com>`; never the work email (scrubbed from history
2026-08-20). **Why:** keep personal OSS identity clean.

_Living doc — refresh with /project-docs when it drifts._
