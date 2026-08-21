# Development Environment

Two separate toolchains, and **you only need the second one if you're adding new art/models**:

| Track | What you need | Use for |
|---|---|---|
| **A. Code mods** | .NET SDK + an editor + BepInEx installed | QoL, tweaks, UI, cheats, behavior changes — ~90% of the mod scene |
| **B. Content mods** | Track A **plus** Unity 6.3 LTS + Addressables | New models, items, food, interactables |

Start with Track A. See [05-custom-assets.md](05-custom-assets.md) for Track B.

---

## Track A — code mods

### Prerequisites

1. **BepInEx installed and verified** — see [02-installing-mods.md](02-installing-mods.md).
2. **.NET SDK** (any recent version; the SDK builds `netstandard2.1` targets fine).
   Check with:

```bash
dotnet --version
```

3. An editor — Visual Studio, Rider, or VS Code with the C# Dev Kit.

### The assemblies you'll reference

All under `Moonlight Peaks\Moonlight Peaks_Data\Managed\`:

| DLL | Why |
|---|---|
| `Vampire.Runtime.dll` | **The game's own code.** Every class you'll patch lives here. The single most important reference. |
| `UnityEngine.dll` | Unity core |
| `UnityEngine.CoreModule.dll` | Unity core |
| `Assembly-CSharp.dll` | May or may not exist — this game ships its logic in `Vampire.Runtime` instead. Check the folder. |

Plus `BepInEx\core\BepInEx.dll` (and `0Harmony.dll` when you start patching).

> The `Vampire.*` namespace naming is a leftover from the project's working title —
> useful to know when searching decompiled code.

### Reading the game's code (essential)

There is no published API documentation. You find method names by decompiling
`Vampire.Runtime.dll`:

- **[ILSpy](https://github.com/icsharpcode/ILSpy)** — free, Windows, good search
- **[dnSpy / dnSpyEx](https://github.com/dnSpyEx/dnSpy)** — also lets you set breakpoints
  in the running game, which is a superpower for this
- **JetBrains dotPeek** — free
- Rider has a built-in decompiler

Workflow in practice: search the decompiled assembly for a likely class name
(`Energy`, `Crop`, `Inventory`, `SaveManager`), read the method you want to change, then
write a Harmony patch against it.

Because it's Mono (not IL2CPP), method and field names are **intact** — no deobfuscation
needed. This is the main reason the scene grew so fast.

### Directory layout that the wiki's samples assume

```
<workspace>\
├── Directory.Build.props        <- shared game paths + DLL references
├── MoonlightPeaksMods.sln
└── src\
    └── Sample.MoonlightPeaks.FirstMod\
        ├── Sample.MoonlightPeaks.FirstMod.csproj
        └── FirstModPlugin.cs
```

The point of `Directory.Build.props` is that the game path and every `<Reference>` is
declared **once**, and each mod project inherits it. Worth adopting even for a single mod.

---

## Track B — content mods (summary)

Required, per the wiki, with unusually specific version pinning:

- **Unity Hub**, then **Unity 6.3 LTS**, preferred exact patch `6000.3.6f1`
- Project template: **Universal 3D**
- Package: **`com.unity.addressables` version `2.8.1` — exactly**.
  The guide is emphatic: *"Do not use the latest Addressables version unless a later
  Moonlight Peaks guide changes this requirement."* Version mismatch produces catalogs the
  game can't load.
- **Blender** for models (`.blend`, exported as `.fbx`/`.obj`/`.dae`/`.dxf`)
- Photoshop or equivalent for textures (`.psd`/`.tiff`)

Notably the wiki's asset guide is about **authoring new assets from scratch**, not ripping
existing ones — it doesn't cover AssetRipper/AssetStudio. If you want to inspect existing
game assets for reference, that's off-guide territory (and check the game's EULA before
redistributing anything derived from shipped assets).

## Version pinning cheatsheet

| Thing | Version | Hard requirement? |
|---|---|---|
| BepInEx | 5.x, `win_x64`, stable | Yes — not 6 |
| Target framework | `netstandard2.1` | Yes |
| Unity | 6.3 LTS (`6000.3.6f1`) | Only for Track B |
| Addressables | `2.8.1` exactly | Yes, for Track B |
