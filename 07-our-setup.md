# Our Setup — Machine Status & Realistic Capability

Audited 2026-08-02 on this machine.

## What's here

| Requirement | Status | Notes |
|---|---|---|
| .NET SDK | ✅ 8.0.301, 10.0.301 | Builds `netstandard2.1` targets fine |
| C# IDE | ✅ Rider 2025.2.2, Visual Studio Community 2026, VS Code 1.131 | Rider has a built-in decompiler |
| Steam | ✅ 2.10.91.91 | Single library at `C:\Program Files (x86)\Steam` |
| **Moonlight Peaks** | ✅ **INSTALLED** | `C:\Program Files (x86)\Steam\steamapps\common\Moonlight Peaks` |
| Decompiler | ✅ `ilspycmd` 10.1.1.8388 | `dotnet tool install -g ilspycmd` — see [09](09-exploring-the-assembly.md) |
| BepInEx | ✅ **5.4.23.5** | Installed via Vortex; all 5 plugins load clean per `LogOutput.log` |
| Reference mods | ✅ 5 installed | ExtraTooltip 1.1.4, MoonlightMinimap 1.3.0, Far Sight 2.1.1, Save Anywhere 2.0.1, FasterGrowth 1.0 |
| Save file | ✅ 2-day save | Backed up; format documented in [ChestLabels research](mods/ChestLabels/README.md) |

**The toolchain is fully proven** — BepInEx 5.4.23.5 with HarmonyX 2.9 loads five
third-party plugins without error on this machine. Nothing about the environment is
theoretical any more.

Vortex manages the plugins folder (`__folder_managed_by_vortex` markers). Hand-placed mod
DLLs should go in a subfolder to stay out of its way — the `MoonlightPeaksMods\<modname>\`
convention from [04](04-first-mod-walkthrough.md) does this already.

### Installed mods are also reference material

Decompiling them is the fastest way to learn real patterns and to fact-check Nexus
descriptions. `MoonlightPeaksExtraTooltip.dll` is the most instructive: 18 Harmony patches,
BepInEx config binding, TMPro/Unity UI construction, and Addressables loading for its icons.
| Unity 6.3 LTS | ❌ | Only needed for asset mods |
| Blender | ❌ | Only needed for 3D asset mods |
| ILSpy / dnSpy | ❌ | Free, small, install when the game lands |

## Status: unblocked

The game is installed and the assembly is readable. `Vampire.Runtime.dll` is **12.9 MB**,
**5,274 types**, **no obfuscation** — full method and field names.

Confirmed present alongside it: Newtonsoft.Json, DOTween, Cinemachine, Rewired, UniTask,
A* Pathfinding, Sentry, and Little Chicken's own `chicken-ui` / `chicken-utilities`.

Remaining before code runs: **install BepInEx** ([02-installing-mods.md](02-installing-mods.md)),
then get the hello-world plugin loading ([04-first-mod-walkthrough.md](04-first-mod-walkthrough.md)).

The `Directory.Build.props` sample in guide 04 already points at the correct path — Steam has
a single library, exactly where the sample assumed.

## Honest capability split

### Confident — code mods

Once the game is installed, this loop is well within reach:

1. Decompile `Vampire.Runtime.dll`, search for the relevant class
2. Write the Harmony prefix/postfix
3. `dotnet build` → auto-deploys to `BepInEx\plugins\`
4. Launch, read `LogOutput.log` / the BepInEx console
5. Iterate

Reading IL, writing patches, wiring `Config.Bind` settings, driving the build — all
ordinary C# work.

### Qualified — asset mods

The split here is **plumbing vs. art**, not hard vs. easy.

**Plumbing is scriptable and tractable:**
- Unity runs headless: `Unity.exe -batchmode -quit -executeMethod MyBuilder.Build`
- Addressables groups, address assignment, and content builds can be driven from C# editor
  scripts
- Blender has a full Python API: `blender --background --python make_thing.py` — anything
  describable procedurally (fences, crates, signposts, geometric props) is scriptable
- Runtime loading, room placement, and save persistence are all C#

**Art is not.** Producing a model that matches Moonlight Peaks' stylized silhouette and
palette, and reads correctly at gameplay camera distance, is visual craft built on fast
iteration and reliable taste. Expect programmer art from the automated path.

**Realistic division of labour:** full working pipeline + placeholder mesh, delivered
automated. Making the mesh look good is a human job.

### The cheap exception — portraits

2D, skips Addressables entirely. With
[Serena's Portrait Replacer](https://www.nexusmods.com/moonlightpeaks/mods/76) it's just
PNGs in a folder — no Unity, no Blender, no code. This is why Visuals is almost entirely
portrait packs.

## Recommended path from here

1. **Install Moonlight Peaks** (Steam) — unblocks everything
2. **Install BepInEx 5 win_x64** — [02-installing-mods.md](02-installing-mods.md)
3. **Install ILSpy** — <https://github.com/icsharpcode/ILSpy>
4. **Build the hello-world plugin** — [04-first-mod-walkthrough.md](04-first-mod-walkthrough.md).
   Confirms the whole loop works before any real logic
5. **Pick a pure-code first mod.** Nothing in the Nexus top 20, outside the portrait packs,
   required a single 3D asset. The "surfaces hidden information" category has the scene's
   best endorsement-to-download ratios and needs zero art.

Unity and Blender are a later decision, not a prerequisite.

## Minor notes

- `msbuild` isn't on PATH, but `dotnet build` is all the wiki's workflow needs.
- Steam has one library folder, so the game will land at
  `C:\Program Files (x86)\Steam\steamapps\common\Moonlight Peaks` — which is already the
  default in the `Directory.Build.props` sample.
