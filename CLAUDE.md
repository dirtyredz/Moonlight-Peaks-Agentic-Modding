# CLAUDE.md — working in the Moonlight Peaks workspace

How to work in this repo. Orientation lives in the doc set — read those, don't duplicate them here.

- **[README.md](README.md)** — human quick-start + mod index.
- **[STRUCTURE.md](STRUCTURE.md)** — where things live; the two-layer git layout.
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** — how the modding/release system works.
- **[docs/DECISIONS.md](docs/DECISIONS.md) · [FEATURES.md](docs/FEATURES.md) ·
  [ROADMAP.md](docs/ROADMAP.md) · [BACKLOG.md](docs/BACKLOG.md) · [GOTCHAS.md](docs/GOTCHAS.md)**

## This is a multi-repo workspace

The **root** is its own git repo (the numbered `NN-*.md` guides + this doc set + the mod index).
Each `mods/<Name>/` is a **separate standalone git repo**. The one you're "working on" is the
**innermost repo** of the files being edited:

- Editing root notes/docs → the **root** repo is active. Its gate, its baseline.
- "Work on <Mod>" → `mods/<Mod>` is the active repo. Honor **its** gate/baseline, not the root's.

Scope every sweep with `git ls-files --cached --others --exclude-standard` — it respects
`.gitignore` and never lists a nested repo's internals, so a review can't span sibling repos.

## Conventions

- **Commit identity:** `dirtyredz <dirtyredz@live.com>`. Never the work email (scrubbed 2026-08-20).
- **Versioning:** bump `<Version>` in the mod's csproj only, only when publishing; first release is
  `1.0.0`. Never hardcode a version in `Plugin.cs`. See [docs/DECISIONS.md](docs/DECISIONS.md).
- **Mod layout:** plugin `.cs` flat in `src/` (no `src/<ModName>/`); docs + `pack.ps1` at mod root.
- **Read-before-you-code gates:** UI → `10`/`17`; colour → `16`; saves → `11`; Nexus page → `13`/`15`.
- **Never publish** `save-backup-*/`, `dist/`, `bin/`, `obj/`, or decompiled game code.

## Release + publish

- Build/pack a mod with its `pack.ps1` → `dist/<Mod>-<version>.zip` in Nexus layout.
- Publish/update a Nexus page with the **nexus-publish** skill (`.claude/skills/nexus-publish`).
- Full chain: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Structure-review gate

The root repo is gated (pre-push hook, installed 2026-08-22). Edit/debug freely; the review fires
once at **push** on the accumulated change, not per edit or per commit. Commit freely at logical
boundaries; Claude runs the review and pushes (asking first) when work is ready. `/gate status` shows
what's pending. Nested mod repos are gated on their own when they warrant it.
