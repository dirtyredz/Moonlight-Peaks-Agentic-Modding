# BACKLOG

Prioritized trough of deferred work and known issues for the **root repo / cross-mod tooling**.
Per-mod feature work lives in each mod's repo; this is the workspace-level list. Most-useful first.

## P0 — drift that will bite

- [ ] **Unify the 11 `pack.ps1` copies.** Each mod hand-copies the same script (48–79 lines) differing
      mostly by name, and they've already diverged (Vampscape and LastSwing carry a shared-`dist/`
      mirror block; repo-root detection differs between copies). A packing fix must be made 11×. → one
      canonical template at root +
      a `sync-tooling` script that regenerates each mod's `pack.ps1`. Honor the standalone-repo
      constraint: the file must still physically exist in each mod.
- [x] **`BiggerUI` has no `pack.ps1`.** ~~Add one~~ — moot: BiggerUI was **retired 2026-08-22** (never
      published, unmaintained). Exclude it from the pack.ps1 unify task.

## P1 — inconsistency

- [ ] **Standardize `Directory.Build.props`.** 8 mods identical; ChestLabels & Vampscape carry a
      variant; **CoffinBreak & PlantPeek have none**. Decide the canonical version, reconcile the two
      variants, add the two missing. Fold into the same sync tool as `pack.ps1`.
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
