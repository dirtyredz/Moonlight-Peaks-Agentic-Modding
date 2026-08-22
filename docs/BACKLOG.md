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
- [~] **Root build/pack/status tooling.** **Status shipped 2026-08-22** — `tools/status-mods.ps1`
      reports per-mod version, dist-zip presence, git dirty count, ahead/behind, and shared-file drift.
      Still open: a **build-all / pack-all** command (run every mod's `pack.ps1` in one go).
- [x] **README stale line.** "This directory is **not** a repository" — fixed 2026-08-22 (the line now
      states the root is its own repo containing the nested mod repos).

## P2 — housekeeping

- [x] **Loose uncommitted work** in 5 mods — **committed + pushed 2026-08-22** as unreleased WIP
      checkpoints (all built clean first). Turned out to be finished-looking feature work, not tidy-up.
- [ ] **Unreleased features awaiting a publish decision** (P1-ish): three mods now carry committed but
      unpublished features on top of their live 1.0.0 — **FormLock** (form-pickup stutter fix),
      **LastSwing** (killing-blow detection for rocks/ore off-grid), **ModNook** (gamepad cancel, Proton
      overlay fix, long-name overflow, prose choice-parser). Each needs: in-game test → version bump +
      CHANGELOG → repackage → Nexus update. CoffinBreak/Transplant also have refreshed page copy that
      may need pushing to their Nexus pages.
- [ ] **Doc-set drift guards per mod.** Consider extending the living-doc set / gate into individual
      mod repos as they grow (currently root-only).

## Notes

- The standalone-repo constraint ([DECISIONS.md](DECISIONS.md)) is the root cause of the P0/P1
  duplication — solutions must generate-into-each-mod, not centralize-into-one-file.

_Living doc — refresh with /project-docs when it drifts._
