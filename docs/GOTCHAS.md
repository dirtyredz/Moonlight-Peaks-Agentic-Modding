# GOTCHAS

Traps a newcomer (or a future session) hits. Each: **trap → why → do instead.** Pulled from the
numbered guides and prior sessions.

## Build & release

- **Editing one mod's `pack.ps1` doesn't fix the others.** → There are 11 near-identical copies (a
  standalone-repo requirement). → Fix the template/all copies together; see [BACKLOG.md](BACKLOG.md).
- **Hardcoding a version in `Plugin.cs`.** → It drifts from the archive name and BepInEx report. →
  Bump `<Version>` in the csproj only; `GenerateModBuildInfo` propagates it.
- **A stale deployed DLL can break a mod even when the source is fine.** → BepInEx loads the deployed
  copy, not your source. → Trust `LogOutput.log` for real breaks; on a game update, rebuild + redeploy
  before diagnosing. Decompile `Vampire.Runtime` to check symbols, but the log is truth.
- **A release build overwriting the copy under test.** → `pack.ps1` passes `-p:SkipDeploy=true` for
  exactly this; don't remove it.

## Visual / world

- **Material colour writes silently do nothing.** → The game uses a shared gradient atlas; direct
  material writes are ignored. → Use HSV colorize; read non-readable textures the documented way
  (`16-recolouring-characters.md`).
- **Modded-looking pixels are a defect.** → The game uses Gelica with specific outline presets and a
  plum/gold palette; Unity defaults are all wrong. → Read `10-visual-integration.md` before drawing.
  A mod already shipped with the wrong font because this wasn't written down.
- **UI layout flags that silently blank the panel.** → Wrong layout flags on the wardrobe/customize
  screens blank the whole panel. → Follow `17-wardrobe-ui.md`.
- **Build UI world-hover: don't build your own "what's pointed at".** → ChestLabels/PlantPeek each
  built one and spent versions reconciling reach. → Reuse whatever the game already tracks as the
  target (e.g. `SwingToolView.Target`).

## Camera / state machine

- **`StateMachine.OnDeactivate` is empty** — don't count substate events; read live `CurrentState`.
- **Far Sight leaves the Close camera active in build mode.** Build cameras are **perspective** (use
  FOV, not orthographic size). See prior camera notes.

## Saves

- **Reusing a game save field to store mod data.** → It bit a mod once. → Store in sidecar files keyed
  by the game's GUIDs (`11-mod-data-and-saves.md`).

## Nexus publishing

- **Update-existing-file resets the name/version;** editing details **drops the changelog.** → The
  edit form behaves non-obviously. → Bump the mod version on edit/general; re-enter fields; verify on
  the live page. See the nexus-publish skill and `13-nexus-page-standard.md`.
- **The `[line]` tag silently drops every horizontal rule** in a Nexus description. → Avoid it; see
  `15-page-style.md`.

## Workspace hygiene

- **Never publish `save-backup-*/`** — real save data + Steam ID. Also keep `dist/`, `bin/`, `obj/`,
  and decompiled game code out of anything published.

_Living doc — refresh with /project-docs when it drifts._
