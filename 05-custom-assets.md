# Custom Assets — the Unity / Addressables Path

Needed only when a mod adds **new art**: models, new items, food, interactables, or
placed world objects. Pure code mods never touch any of this.

This is why the Items category has 1 mod and Gameplay has 49.

Sources: [Creating a Unity Project for Creating Assets](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Creating_a_Unity_Project_for_Creating_Assets),
[Importing Game Assets into the Project](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Importing_Game_Assets_into_the_Project)

## Toolchain, pinned

| Tool | Version | Note |
|---|---|---|
| Unity Hub | latest | |
| Unity Editor | **6.3 LTS**, preferred `6000.3.6f1` | any 6.3 LTS patch should work |
| Project template | **Universal 3D** | |
| `com.unity.addressables` | **2.8.1 — exactly** | wiki is emphatic; do not take the latest |
| Blender | any recent | models |
| Photoshop / equivalent | any | textures |

The Addressables pin matters because the game loads your bundle through its own catalog
system. A mismatched Addressables version produces a catalog the game refuses.

## The pipeline

1. **Author the asset.** Models as `.blend`, exported to `.fbx` / `.obj` / `.dae` / `.dxf`.
   Textures as `.psd` / `.tiff`.
2. **Import** into `Assets/MoonlightPeaksMod/` in the Unity project.
3. **Build a Prefab** combining mesh + materials + any visual components.
4. **Mark it Addressable** — the checkbox on the Prefab inspector, or on the containing
   folder.
5. **Assign a clean address**, e.g. `MoonlightPeaksMod/Prefabs/GlowingMushroom`.
   This string is what your C# code looks the asset up by, so treat it as an API.
6. **Build Addressables content** — via the Addressables Groups window (Addressables-only
   build) or as part of a Player build. Output is a set of **AssetBundles + a catalog file
   + a hash file**.
7. **Ship those built files with your mod** and load them at runtime from your BepInEx
   plugin — covered by
   [Loading Built Addressable Assets in a Mod](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Loading_Built_Addressable_Assets_in_a_Mod).

## Then, depending on what you're making

| Goal | Wiki guide |
|---|---|
| Put a prefab into a specific game room | Loading an Addressable Prefab in a Specific Room |
| Find the room ID to target | Full-Game Room List |
| Make it survive save/load | Saving Custom Objects in Game Persistence |
| Make it clickable/usable | Creating a New Interactable |
| Register a new item | Creating a New ItemAsset |
| Register new food | Creating a New Food Item |
| Replace/add character portraits | Creating Custom Portraits |

**Portraits are the cheap exception.** They're 2D and don't need the Addressables pipeline —
which is exactly why the Visuals category is almost entirely portrait replacers. And
[Serena's Portrait Replacer](https://www.nexusmods.com/moonlightpeaks/mods/76) reduced it
further to "drop PNGs in a folder", so a portrait pack today needs *no* code at all.

## Note on extracting existing game assets

The wiki's guide covers **authoring assets from scratch**. It does not mention AssetRipper
or AssetStudio, and there's no documented workflow for pulling the game's shipped models
out to use as a base or a style reference.

If you go that route: check the game's EULA before redistributing anything derived from
shipped assets. Replacer mods that ship modified original art are a different legal
situation from mods that ship original work.

## Realistic assessment

For a first mod, skip this entirely. The Addressables round-trip (author → prefab →
address → build → load from plugin → place in room → persist in save) is six systems that
can each fail silently, and the wiki guides for the later steps are newer and less
battle-tested than the BepInEx ones. Get a Harmony mod working first so you know your
loader, logging, and debugging loop are solid.
