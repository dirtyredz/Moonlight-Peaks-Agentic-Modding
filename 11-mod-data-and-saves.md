# Storing Mod Data — Never Write to the Game Save

**A mod's own data belongs in the mod's own file, keyed by the game's identifiers.**

Applies to every mod in this repo. Read it before designing anything that has to persist.

---

## The decision, and why

Chest Labels needed to remember a name per chest. The obvious route was the game's own
`ItemEntry.CustomName` field: already serialized into the save, already used by the game to
let players name animals, and free to use.

**It was the wrong choice, and the reason is not obvious.**

`CustomName` participates in item equality:

```csharp
[Flags]
public enum ItemEntryCompareMask
{
    Metadata            = 0x10,
    CustomName          = 0x20,
    Metadata_CustomName = 0x30,
    QualitySame_Metadata_CustomName = 0x32,   // the default nearly everywhere
}
```

That default mask is used throughout `GameInventory`, `Inventory`, `CraftingHelper`, shop
screens and quest checks. Chests can be picked up into the inventory, so a named chest would
have become **a different item** from an unnamed one — it would stop stacking, stop counting
toward anything asking the player to have a chest, and behave oddly in shops. Silently, and
only for players who used the feature.

The lesson generalises past this one field: **a field that persists is not automatically a
field you may write to.** Find out what else reads it first.

---

## The pattern

### 1. Sidecar file, keyed by the game's GUIDs

```
BepInEx/config/<ModName>/<save-guid>.json
{ "<object-guid>": "value", ... }
```

- **Save GUID** — `GamePersistence.Instance.Guid`. Also the save's folder name. Scoping by it
  keeps separate playthroughs separate, and Steam accounts separate for free.
- **Object GUID** — persistent objects derive from `GuidPersistence`, which carries a
  `SerializedGuid Guid`. Position is stored separately, so identity survives an object being
  picked up and re-placed.
- Verified empirically: 3,759 grid objects across 27 rooms, all GUIDs unique. Not per-room,
  so a flat map is correct.

### 2. Newtonsoft.Json is already loaded

The game ships it in `Managed`. Reference it; do not bundle a serializer.

### 3. Handle a corrupt file without destroying it

Rename to `<name>.corrupt-<timestamp>` and continue with an empty set. Never delete a
player's data because it failed to parse.

### 4. Write atomically

Temp file, then move into place, so an interrupted write cannot leave a half-file.

### 5. Prune when the object is destroyed

Otherwise the file grows forever. For chests that is a prefix patch on `Chest.Delete`, taken
before the persistence reference is nulled.

---

## Why it is worth the extra work

- **Uninstalling leaves no trace.** The save is byte-for-byte what the game wrote — verified
  by decompressing it and confirming zero occurrences of both the mod's strings and
  `CustomName`.
- **"Save-safe" becomes a claim you can defend**, which this community reads for.
- **Game patches cannot corrupt your data**, and your data cannot corrupt theirs.

## Verifying before release

Saves are **gzipped** despite the `.json` extension. Decompress, then check:

```powershell
"CustomName occurrences: " + ([regex]::Matches($txt,'"CustomName"')).Count   # expect 0
```

Search for one of your own stored values too. It must not appear.

Full save-format notes: [mods/ChestLabels/research/02-save-format.md](mods/ChestLabels/research/02-save-format.md).

---

## When writing to the save is legitimate

If a mod genuinely adds world content — a placed object that must exist for other systems —
the wiki's
[Saving Custom Objects in Game Persistence](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Saving_Custom_Objects_in_Game_Persistence)
is the supported route. The rule is not "never touch the save"; it is **do not put mod
preferences in the save, and never reuse a game field without knowing what else reads it.**

---

## Reusable code

`mods/ChestLabels/src/LabelStore.cs` implements all of the above and is
deliberately free of Unity and BepInEx types, so it can be unit tested without the game.
`mods/ChestLabels/tests/` is a console runner with no test framework — 16
tests covering round-trips, save isolation, corruption recovery and atomic writes.
