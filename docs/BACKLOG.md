# BACKLOG

Prioritized trough of deferred work and known issues for the **root repo / cross-mod tooling**.
Per-mod feature work lives in each mod's repo; this is the workspace-level list. Most-useful first.

## P0 — drift that will bite

- [x] **Unify the 11 `pack.ps1` copies.** **Done 2026-08-22.** `pack.ps1` is now generic (derives
      everything at runtime) and lives in `tools/pack.template.ps1`, distributed byte-identical to
      every mod by `tools/sync-mod-files.ps1` (`-Check` = CI drift guard). Verified end-to-end by packing
      ModNook. Fixed a latent standalone-clone bug in the ChestLabels-style copies as a bonus.
- [x] **`BiggerUI` has no `pack.ps1`.** ~~Add one~~ — moot: BiggerUI was **retired 2026-08-22** (never
      published, unmaintained). Exclude it from the pack.ps1 unify task.

## P1 — inconsistency

- [x] **Standardize `Directory.Build.props`.** **Done 2026-08-22.** Correction: all 12 mods always had
      it with identical content — the drift was whitespace, plus two copies mislocated in `src/`
      (CoffinBreak, PlantPeek, now moved to the mod root). Canonical in `tools/Directory.Build.props`,
      distributed byte-identical by the generalized `tools/sync-mod-files.ps1` (which now syncs both
      `pack.ps1` and `Directory.Build.props`). Verified by packing CoffinBreak after the move.
- [ ] **Root build/pack/status tooling.** No single command to build all, pack all, or report per-mod
      health (missing files, version vs. dist, uncommitted changes). Add a root script.
- [x] **README stale line.** "This directory is **not** a repository" — fixed 2026-08-22 (the line now
      states the root is its own repo containing the nested mod repos).

## P2 — housekeeping

- [ ] **Loose uncommitted work** in several mods (as of 2026-08-22): CoffinBreak, FormLock, LastSwing,
      ModNook, Transplant. Review and commit or discard so the next release sees a clean tree.
- [ ] **Doc-set drift guards per mod.** Consider extending the living-doc set / gate into individual
      mod repos as they grow (currently root-only).

## Notes

- The standalone-repo constraint ([DECISIONS.md](DECISIONS.md)) is the root cause of the P0/P1
  duplication — solutions must generate-into-each-mod, not centralize-into-one-file.

_Living doc — refresh with /project-docs when it drifts._
