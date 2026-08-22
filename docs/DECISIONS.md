# DECISIONS

Choices worth not re-litigating, newest first. Drawn from the numbered guides, git history, and
prior sessions. Where rationale isn't recorded, it's marked.

## 2026-08-22 — Shared mod files (`pack.ps1`, `Directory.Build.props`) unified via one sync tool

**Decision:** Replace the 11 hand-copied `pack.ps1` scripts with one **generic** script
(`tools/pack.template.ps1`) that derives the mod name, paths, and version at runtime from
`src/*.csproj`, so it is byte-identical in every mod. Canonical behaviour: write the archive to the
mod's own `dist/` (correct for a standalone clone) and additionally mirror to the shared root `dist/`
when running under `mods/`. `Directory.Build.props` (already mod-agnostic — game paths + the version
target) is standardized the same way: canonical copy in `tools/`, at **every mod's root** (the two
copies mislocated in `src/` were moved), byte-identical everywhere. Both files are distributed by one
tool, `tools/sync-mod-files.ps1` (byte-exact copy; `-Check` reports drift and exits non-zero — CI
guard), rather than a separate script per file.
**Why:** the copies had drifted and a packing fix meant 11 hand-edits. A generic file needs no
per-mod substitution, so "sync" is a plain copy — the strongest anti-drift design under the
standalone-repo constraint (the file must still physically live in each mod). Fixed a latent bug: the
ChestLabels-style copies hardcoded the grandparent as repo root and would break if cloned standalone.
**Rejected:** a shared `pack.psm1` module each mod dot-sources — breaks the standalone constraint
unless vendored, which just reintroduces the copy. Per-mod placeholder substitution — leaves room to
drift and needs a parser; a fully generic script avoids substitution entirely.

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
