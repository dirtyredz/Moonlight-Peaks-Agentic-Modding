# Exploring the Game Assembly

How to find what to patch. Applies to **every** mod — read this before starting any of them.

## Setup (done once)

The decompiler runs as a .NET global tool, no GUI needed:

```bash
dotnet tool install -g ilspycmd
```

It lands in `%USERPROFILE%\.dotnet\tools`. If that's not on PATH, prepend it per session:

```powershell
$env:Path += ";$env:USERPROFILE\.dotnet\tools"
```

Confirmed working here: **ilspycmd 10.1.1.8388**.

## Confirmed paths on this machine

| Thing | Path |
|---|---|
| Game root | `C:\Program Files (x86)\Steam\steamapps\common\Moonlight Peaks` |
| Game code | `...\Moonlight Peaks_Data\Managed\Vampire.Runtime.dll` (12.9 MB) |
| Managed DLLs | `...\Moonlight Peaks_Data\Managed\` |

## Commands that actually work

**Gotcha:** `-l c,i,s,e` silently returns nothing. Pass one kind at a time and concatenate.

```powershell
$dll = "C:\Program Files (x86)\Steam\steamapps\common\Moonlight Peaks\Moonlight Peaks_Data\Managed\Vampire.Runtime.dll"

# List all types (5,274 of them: 4,866 classes + interfaces + structs + enums)
$all = @(); foreach ($k in @('c','i','s','e')) { $all += ilspycmd -l $k $dll }

# Find a subsystem
$all | Where-Object { $_ -match 'chest|storage' }

# Decompile one type
ilspycmd -t Chest $dll

# Decompile everything to browsable .cs files (slow, ~minutes)
ilspycmd -p -o <outdir> $dll
```

**Second gotcha:** redirecting ilspycmd with `>` in PowerShell 5.1 can produce an empty file.
Assign to a variable and use `Out-File -Encoding utf8` instead.

## Where to put decompiled output

**Not in this project directory.** Decompiled output is derived from the shipped game and
shouldn't be committed or shared. Keep it in a scratch location and reference findings —
short quoted snippets for reference are fine, a full dump is not.

## What the codebase looks like

- **No obfuscation.** Mono build, full symbol names, readable method bodies.
- Namespaces are mostly flat — `Chest`, `Inventory`, `GamePersistence` sit at global scope.
  Some subsystems nest (`Director.Nodes.*`, `Entity.Behaviours.*`, `Minigames.*`).
- The `Vampire.*` assembly name is a working-title leftover.
- Third-party libraries present, useful to know: **Newtonsoft.Json** (so JSON serialization
  is already available to you), **DOTween** (tweening), **Cinemachine** (cameras),
  **Rewired** (input), **UniTask** (async), **A\* Pathfinding**, **Sentry** (crash reporting).

## Architectural patterns worth knowing

Learned while investigating chests; these recur everywhere.

### Persistence is GUID-based

```csharp
[DataContract]
public class GuidPersistence {
    [DataMember] public SerializedGuid Guid;
}
```

Persistent objects derive from `GuidPersistence`. Position is stored as a *separate* field,
so **object identity is stable across moves**. `[DataContract]`/`[DataMember]` means it's
serialized into the save.

Entry point for save data: `GamePersistence.Instance`, with `.CurrentRoom` exposing
per-room collections (e.g. `.Inventories`).

### Interactables use a state machine

```csharp
public override void ResolveInteraction(PlayerStateMachine playerStateMachine) {
    playerStateMachine.GotoState<PlayerStorageChestState>(new object[1] { this });
}
```

World objects derive from `Interactable`. Interacting pushes the player into a
`Player*State`. To hook "player opened X", patch the state's entry rather than the
`Interactable`.

Screens follow a parallel naming convention: `ChestScreen`, `ShippingChestScreen`.

### Localization

`LocalizationLibrary.Translate("shout-need-to-empty")` — kebab-case string keys. Use this
rather than hardcoding English if your mod shows text.

## Recommended workflow

1. Guess a noun (`Chest`, `Crop`, `Museum`, `Weather`) and list-grep the types.
2. Decompile the most promising type with `-t`.
3. Read what it *already* exposes — the game often has a field you can reuse instead of
   inventing your own storage. (This is exactly what happened with chest labels; see
   [mods/ChestLabels/research/](mods/ChestLabels/research/).)
4. Only then decide the patch target.

Step 3 is the one people skip, and it's where the time savings are.
