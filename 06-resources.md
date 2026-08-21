# Resources

## Primary — trust these

| Link | What |
|---|---|
| [Official Wiki: Modding hub](https://moonlightpeaks.wiki.gg/wiki/Modding) | 15-guide series, the canonical source |
| [Nexus Mods: Moonlight Peaks](https://www.nexusmods.com/games/moonlightpeaks/mods) | The distribution hub. 88 mods as of 2026-08-02 |
| [BepInEx releases](https://github.com/BepInEx/BepInEx/releases) | Get `BepInEx_win_x64_5.x.x.x.zip` |
| [Official Moonlight Peaks Discord](https://discord.com/invite/heWNF8A8Aw) | ~16.8k members; where modders actually talk |
| [iTestor/moonlight-peaks-mods](https://github.com/iTestor/moonlight-peaks-mods) | Community mod source on GitHub — real working examples |

## Full wiki guide list

**Beginner setup path** (do in order)
1. [Installing Unity Hub](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Installing_Unity_Hub)
2. [Creating a Unity Project for Creating Assets](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Creating_a_Unity_Project_for_Creating_Assets)
3. [Importing Game Assets into the Project](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Importing_Game_Assets_into_the_Project)
4. [Installing BepInEx](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Installing_BepInEx)
5. [Creating a BepInEx Project](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Creating_a_BepInEx_Project)

> For a code-only mod you can skip 1–3 and start at 4.

**Core mod systems**
- [Using Custom Config Files](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Using_Custom_Config_Files)
- [Creating a Custom Component for a Mod](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Creating_a_Custom_Component_for_a_Mod)
- [Loading Built Addressable Assets in a Mod](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Loading_Built_Addressable_Assets_in_a_Mod)

**World & persistence**
- [Loading an Addressable Prefab in a Specific Room](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Loading_an_Addressable_Prefab_in_a_Specific_Room)
- [Full-Game Room List](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Full-Game_Room_List)
- [Saving Custom Objects in Game Persistence](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Saving_Custom_Objects_in_Game_Persistence)
- [Creating a New Interactable](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Creating_a_New_Interactable)

**Content systems**
- [Creating a New ItemAsset](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Creating_a_New_ItemAsset)
- [Creating a New Food Item](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Creating_a_New_Food_Item)
- [Creating Custom Portraits](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Creating_Custom_Portraits)

## Tooling

| Tool | Link | Why |
|---|---|---|
| ILSpy | <https://github.com/icsharpcode/ILSpy> | Decompile `Vampire.Runtime.dll` to find what to patch |
| dnSpyEx | <https://github.com/dnSpyEx/dnSpy> | Decompile **and** attach a debugger to the running game |
| HarmonyX docs | <https://harmony.pardeike.net/> | Patching reference (BepInEx 5 bundles HarmonyX) |
| BepInEx docs | <https://docs.bepinex.dev/> | Plugin lifecycle, config API, logging |
| Unity Hub | <https://unity.com/download> | Only for asset mods |

## Community frameworks worth building on

- **[Serena's Enchanted Studio and Texture Framework](https://www.nexusmods.com/moonlightpeaks/mods/52)** — most-downloaded mod in the scene; texture-swap layer
- **Fippsie's Texture Swap Framework (TSF)** — newer competing texture framework
- **[Mod Menu](https://www.nexusmods.com/moonlightpeaks/mods/102)** by Elsiabeth — in-game config UI for BepInEx mods. Use the standard `Config.Bind` API and you get support for free

## Authors to watch

`SerenaEnchanted`, `MissLarifari1`, `roguechikkin`, `Elsiabeth`, `CostMillion`, `lockyaw`,
`entchen66`, `rainhatesyou`, `mwunhh`, `SeanTerry01`, `TinyAngeI`.
Their Nexus pages often link source repos — the fastest way to see real patterns.

## Avoid

`plitch.com`, `xmodhub.com`, `modsportal.com`, and the several `moonlightpeaks*.wiki` /
`moonlightpeakswiki.com` lookalike domains. These are SEO aggregators and paid-trainer
services, not the community. The real wiki is **`moonlightpeaks.wiki.gg`**.

## Open questions

- Has Little Chicken Game Company made any official statement on modding? Nothing found —
  the wiki modding series appears to be community-written. Worth asking in Discord before
  investing heavily.
- No Thunderstore or Steam Workshop presence yet. If either appears, distribution norms
  will shift.
- Patch cadence vs. mod breakage: the game is a month old and updating. Unknown how often
  Harmony patches break.
