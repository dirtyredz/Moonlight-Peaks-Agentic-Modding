# ROADMAP

Trajectory of the workspace: mods to build and tooling to harden. Seeded from
`08-mod-ideas.md` (the idea ladder) and the current mod inventory. Mod-idea feasibility is judged by
the five-minute check in `08-mod-ideas.md`.

## Now — finish what's in flight

- **DeadReckoning** (v0.x) → floating skull tracker; steer via `Mover.Move`, save-safe. Toward 1.0.0.

> **BiggerUI retired** (2026-08-22) — never published; no longer maintained. See [FEATURES.md](FEATURES.md#retired).

## Next — mod ideas still open

From the ranked ladder, most rungs are shipped. Genuinely fresh gaps that remain:

- **Photo Mode** — unclaimed after three sweeps; mostly fresh work, clean self-contained gap.
- **Auto-Water** — strongest "real mod" idea, but writes to world state (untouched territory; higher
  risk). Watering is keyed by cell, not by plant (see Transplant research).
- **Fintastic Palette** — mermaid/Aqua form recolour, completing the Tastic Palette trio
  (Purrtastic → Fangtastic → Fintastic). Reuse the settled recolour methodology; probe the new form
  first.

## Tooling hardening (the efficiency track)

Cross-mod plumbing has drifted; this is the work that makes every future mod cheaper. Detail +
priorities in [BACKLOG.md](BACKLOG.md).

1. ✅ **Unify `pack.ps1`** (2026-08-22) — generic template + `tools/sync-mod-files.ps1` drift guard.
2. ✅ **Standardize `Directory.Build.props`** (2026-08-22) — canonical in `tools/`, at every mod root,
   synced byte-identical by the same tool.
3. **Root build/pack/status tooling** — one command to build, pack, or health-check every mod.
4. **Structure-review gate + living docs** — installed for the root 2026-08-22; extend per mod as
   they warrant it.

_Living doc — refresh with /project-docs when it drifts._
