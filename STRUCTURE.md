# STRUCTURE — Moonlight Peaks workspace

<!-- Last full review: 2026-08-22 -->


Where things live in the **root repo** and how the workspace is shaped. The root repo is a
**notes/knowledge base + container**; the actual mods are separate nested git repos it does not
track. Pairs with [README.md](README.md) (human quick-start) and the [docs/](docs/) set.

## Overview

Two layers of git:

- **Root repo** (this one) — the 17 numbered guides, this doc set, `README`, `LICENSE`, and the
  `.claude/` skills. Its "code" is prose: cross-mod knowledge that applies to every mod.
- **12 nested mod repos** under `mods/<Name>/` — each is its own standalone git repo with its own
  release process. Git tooling here (`git ls-files`) never descends into them; they are documented
  in their own repos, not this one. See [docs/FEATURES.md](docs/FEATURES.md) for the inventory.

Shared, untracked-or-output siblings: `dist/` (packaged release zips from every mod),
`save-backup-*/` (pre-modding saves — **never publish**, see [README](README.md#keep-out-of-anything-published)).

## Architecture at a glance

The root repo has no build; it's read. The *system* it documents — BepInEx plugins, the
version-single-source release chain, the Nexus page pipeline — is described in
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Components (root repo)

| Component | Responsibility | Key files | Seam (where change lands) |
|---|---|---|---|
| **Onboarding guides** | Get a new machine/dev building mods | `01`–`06`, `09` | add a guide as tooling changes |
| **Our-setup / ideas** | This machine's capability + the idea ladder | `07-our-setup.md`, `08-mod-ideas.md` | `08` is the roadmap source ([docs/ROADMAP.md](docs/ROADMAP.md)) |
| **Visual/data contracts** | Rules a mod must obey to look/behave native | `10`–`11`, `16`, `17` | read-before-you-code gates |
| **Release + Nexus pipeline** | Versioning, packaging, page standard/style | `12`–`15` | the release workflow all mods share |
| **Cross-mod tooling** | Canonical shared mod files, drift-free distribution, health dashboard | `tools/pack.template.ps1`, `tools/Directory.Build.props`, `tools/sync-mod-files.ps1`, `tools/status-mods.ps1` | edit a canonical file + re-run sync; add a column to status |
| **Nexus-publish skill** | Drives Chrome to publish/update a mod page | `.claude/skills/nexus-publish/SKILL.md` | the publish automation |
| **Repo meta** | How to work here + the multi-repo boundary | `CLAUDE.md`, `.gitignore` (excludes `mods/`, `dist/`, backups), this doc set | edit when conventions or the gate change |

## Key flows

- **Add cross-mod knowledge** → a numbered `NN-*.md` guide + a row in the README Contents table.
- **Release a mod** → per-mod `pack.ps1` builds `dist/<Mod>-<ver>.zip`; version comes only from the
  mod's csproj. Full chain in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
- **Publish a page** → `NEXUS.md` (draft) → `nexus-paste.md` (unwrapped) → nexus-publish skill.

## Conventions

- Numbered guides are ordered by reading sequence, not priority; `07` is the real "start here".
- Each mod is self-contained: `pack.ps1` and `Directory.Build.props` at its root, plugin `.cs`
  **directly in `src/`** (no `src/<ModName>/`). Those two shared files are kept byte-identical across
  mods by `tools/sync-mod-files.ps1`. See [docs/GOTCHAS.md](docs/GOTCHAS.md).
- Commit identity for this repo and mods: `dirtyredz <dirtyredz@live.com>`.

## Where to find things

- "How do I set up / decompile / patch?" → `03`, `04`, `09`.
- "What are the rules for UI / colour / saves?" → `10`, `16`, `17`, `11`.
- "How do I version / package / publish?" → `12`–`15` + the mod's `RELEASING.md`.
- "What's the plan / what's next?" → [docs/ROADMAP.md](docs/ROADMAP.md), [docs/BACKLOG.md](docs/BACKLOG.md).

## Structural debt

The root repo's *content* is healthy; the **cross-mod tooling** it standardizes has drifted. Full
list with priorities in [docs/BACKLOG.md](docs/BACKLOG.md). Headlines:

- ~~**11 divergent `pack.ps1` copies**~~ **RESOLVED 2026-08-22.** `pack.ps1` is now a generic script
  (derives mod name/version/paths at runtime) kept in `tools/pack.template.ps1` and distributed
  byte-identical to every mod by `tools/sync-mod-files.ps1` (`-Check` fails on drift, for CI). Unifying
  also fixed a latent bug: the ChestLabels-style copies hardcoded the grandparent as repo root and
  would break if cloned standalone.
- ~~**`Directory.Build.props` inconsistent**~~ **RESOLVED 2026-08-22.** All 12 mods always had it with
  identical content; the drift was whitespace + two copies mislocated in `src/` (CoffinBreak,
  PlantPeek). Now canonical in `tools/Directory.Build.props`, at each mod's root, distributed
  byte-identical by `tools/sync-mod-files.ps1`.
- **No root build-all / status tooling** — packing and health-checking is manual, per folder.

_Living doc — refresh with /project-docs when it drifts._
