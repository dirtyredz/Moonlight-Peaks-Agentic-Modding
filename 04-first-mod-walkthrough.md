# First Mod Walkthrough

A minimal BepInEx plugin that loads into Moonlight Peaks and logs a line, with
auto-deploy on build. Then the Harmony step that makes it actually *do* something.

Primary source: [Modding - Creating a BepInEx Project](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Creating_a_BepInEx_Project).
Sections marked **[wiki]** are from that guide; sections marked **[standard]** are ordinary
BepInEx/Harmony practice not yet cross-checked against a Moonlight Peaks-specific guide.

---

## 1. Create the project **[wiki]**

The wiki deliberately does **not** use the BepInEx project template — just a plain class
library:

```bash
dotnet new classlib -n Sample.MoonlightPeaks.FirstMod -o src/Sample.MoonlightPeaks.FirstMod --framework netstandard2.1
```

## 2. `Directory.Build.props` at the workspace root **[wiki]**

Declares game paths and DLL references once, for every mod project in the workspace.

```xml
<Project>
  <PropertyGroup>
    <MoonlightPeaksGamePath>C:\Program Files (x86)\Steam\steamapps\common\Moonlight Peaks</MoonlightPeaksGamePath>
    <MoonlightPeaksManagedPath>$(MoonlightPeaksGamePath)\Moonlight Peaks_Data\Managed</MoonlightPeaksManagedPath>
    <MoonlightPeaksBepInExCorePath>$(MoonlightPeaksGamePath)\BepInEx\core</MoonlightPeaksBepInExCorePath>
    <MoonlightPeaksPluginDeployPath>$(MoonlightPeaksGamePath)\BepInEx\plugins\MoonlightPeaksMods</MoonlightPeaksPluginDeployPath>
  </PropertyGroup>

  <ItemGroup>
    <Reference Include="BepInEx">
      <HintPath>$(MoonlightPeaksBepInExCorePath)\BepInEx.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="UnityEngine">
      <HintPath>$(MoonlightPeaksManagedPath)\UnityEngine.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="UnityEngine.CoreModule">
      <HintPath>$(MoonlightPeaksManagedPath)\UnityEngine.CoreModule.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="Vampire.Runtime">
      <HintPath>$(MoonlightPeaksManagedPath)\Vampire.Runtime.dll</HintPath>
      <Private>false</Private>
    </Reference>
  </ItemGroup>
</Project>
```

`<Private>false</Private>` means "reference it, don't copy it next to my DLL" — important,
you never ship the game's own assemblies with your mod.

**Adjust `MoonlightPeaksGamePath`** if Steam is on another drive.

## 3. The `.csproj` **[wiki]**

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>netstandard2.1</TargetFramework>
    <AssemblyName>Sample.MoonlightPeaks.FirstMod</AssemblyName>
    <RootNamespace>Sample.MoonlightPeaks.FirstMod</RootNamespace>
    <Version>1.0.0</Version>
    <AllowUnsafeBlocks>false</AllowUnsafeBlocks>
    <ModDeployPath>$(MoonlightPeaksPluginDeployPath)\firstmod</ModDeployPath>
  </PropertyGroup>

  <Target Name="DeployPlugin" AfterTargets="Build">
    <MakeDir Directories="$(ModDeployPath)" />
    <Copy SourceFiles="$(TargetPath)" DestinationFolder="$(ModDeployPath)" SkipUnchangedFiles="true" />
  </Target>
</Project>
```

The `DeployPlugin` target is the quality-of-life bit: every build drops the DLL straight
into the game's plugins folder. Build → launch → test.

## 4. The plugin class **[wiki]**

```csharp
using BepInEx;

namespace Sample.MoonlightPeaks.FirstMod {

    [BepInPlugin(PLUGIN_GUID, PLUGIN_NAME, PLUGIN_VERSION)]
    [BepInProcess("Moonlight Peaks.exe")]
    public sealed class FirstModPlugin : BaseUnityPlugin {

        public const string PLUGIN_GUID = "com.sample.moonlightpeaks.first_mod";
        public const string PLUGIN_NAME = "Moonlight Peaks First Mod";
        public const string PLUGIN_VERSION = "1.0.0";

        private void Awake() {
            Logger.LogInfo($"{PLUGIN_NAME} {PLUGIN_VERSION} loaded.");
        }

    }

}
```

Things to know:
- `PLUGIN_GUID` must be globally unique — reverse-domain style. It's also the filename of
  your generated config: `BepInEx/config/com.sample.moonlightpeaks.first_mod.cfg`.
- `[BepInProcess]` means the plugin only loads for this executable.
- `BaseUnityPlugin` is a `MonoBehaviour`, so `Awake`, `Start`, `Update`, `OnGUI` all work.
- `Logger` is provided by the base class.

## 5. Build and verify **[wiki]**

```bash
dotnet build .\MoonlightPeaksMods.sln -c Release
```

Launch the game and check `BepInEx\LogOutput.log` for the load line. With the console
enabled (see [02-installing-mods.md](02-installing-mods.md)) you'll see it live.

---

## 6. Making it do something: Harmony **[standard]**

`Awake` only fires once at startup. To change game behavior you patch the game's methods
with **HarmonyX**, which ships inside BepInEx 5 (`BepInEx\core\0Harmony.dll`).

Add the reference to `Directory.Build.props`:

```xml
<Reference Include="0Harmony">
  <HintPath>$(MoonlightPeaksBepInExCorePath)\0Harmony.dll</HintPath>
  <Private>false</Private>
</Reference>
```

Then, in `Awake`:

```csharp
using BepInEx;
using HarmonyLib;

// inside the plugin class
private readonly Harmony _harmony = new Harmony(PLUGIN_GUID);

private void Awake() {
    Logger.LogInfo($"{PLUGIN_NAME} {PLUGIN_VERSION} loaded.");
    _harmony.PatchAll();
}
```

And a patch class. **The type and method names below are placeholders** — you must find the
real ones by decompiling `Vampire.Runtime.dll` (see [03-dev-environment.md](03-dev-environment.md)):

```csharp
using HarmonyLib;

namespace Sample.MoonlightPeaks.FirstMod {

    [HarmonyPatch(typeof(SomeGameClass), nameof(SomeGameClass.SomeMethod))]
    internal static class SomeMethodPatch {

        // Runs before the original. Return false to skip the original entirely.
        static bool Prefix(ref float amount) {
            amount = 0f;   // e.g. the "infinite energy" trick: never spend energy
            return true;
        }

        // Runs after the original; can rewrite the return value.
        static void Postfix(ref int __result) {
            __result *= 2;
        }

    }

}
```

The three patch kinds you'll use 95% of the time:
- **Prefix** — run before; `return false` cancels the original method.
- **Postfix** — run after; `ref __result` lets you modify the return value.
- **Transpiler** — rewrite IL. Powerful, fragile, avoid until you need it.

Special parameter names Harmony injects: `__instance` (the object), `__result` (return
value), `__state` (pass data prefix→postfix), and `___fieldName` (three underscores) to
reach private fields.

## 7. Config that players can edit **[standard, wiki has a dedicated guide]**

```csharp
private ConfigEntry<bool> _enabled;
private ConfigEntry<float> _multiplier;

private void Awake() {
    _enabled    = Config.Bind("General", "Enabled", true, "Turn the mod on or off.");
    _multiplier = Config.Bind("General", "Multiplier", 3.0f, "Speed multiplier (1-10).");
}
```

This auto-generates `BepInEx/config/<GUID>.cfg` and — because it's the standard API —
makes your mod show up automatically in **Mod Menu** and **ConfigurationManager**. Do this
from the start; it's the scene's expected convention.

The wiki has [Modding - Using Custom Config Files](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Using_Custom_Config_Files)
for cases where the built-in config system isn't enough.

---

## Before you draw anything on screen

Read **[10-visual-integration.md](10-visual-integration.md)**.

The game uses the **Gelica** font family with its own outline material presets, and a
specific plum/gold palette. Every Unity and TextMeshPro default is wrong for it. UI parented
inside a game screen tends to inherit the right look; UI on your own canvas inherits nothing,
which is how a released mod shipped with stock TMP text.

`GameFonts.cs` and `PanelSprite.cs` in `mods/ChestLabels/src/` solve the font and
panel problems and are meant to be copied.

## Suggested first project

Pick something in the "information the game hides" bucket — those had the best
endorsement-to-download ratios and need no art assets. A pure-Harmony, pure-UI mod avoids
the entire Unity/Addressables toolchain.

## Where the wiki goes next

Once the hello-world loads, the guides worth reading in order are:

1. Using Custom Config Files
2. Creating a Custom Component for a Mod
3. Loading Built Addressable Assets in a Mod

Then the world/persistence set — notably **Saving Custom Objects in Game Persistence**,
which is what you need if your mod adds anything that must survive a save/load.
