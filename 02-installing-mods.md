# Installing Mods (and Step 1 of Dev Setup)

Even if the goal is writing mods, you need BepInEx installed the same way a player does.
This is that.

Source: [Modding - Installing BepInEx](https://moonlightpeaks.wiki.gg/wiki/Modding_-_Installing_BepInEx)

## 1. Install BepInEx

**Use BepInEx 5, Windows, x64 — the stable release.** Not BepInEx 6.

> Why: Moonlight Peaks is a **Unity Mono** build. BepInEx 6 only has stable releases for
> the Mono path anyway, and the whole community is on 5.x. Matching everyone else means
> other people's mods actually work alongside yours.

1. Close the game completely.
2. Download from <https://github.com/BepInEx/BepInEx/releases> — grab the asset named like
   `BepInEx_win_x64_5.x.x.x.zip`. **Not** the "Source code" downloads.
3. Find the game root folder — the one containing `Moonlight Peaks.exe`.
   Default Steam path: `C:\Program Files (x86)\Steam\steamapps\common\Moonlight Peaks`
4. Extract the zip **directly into that folder**. Do not create a subfolder.

You should end up with:

```
Moonlight Peaks/
├── Moonlight Peaks.exe
├── Moonlight Peaks_Data/
├── BepInEx/
├── doorstop_config.ini
└── winhttp.dll
```

## 2. Verify it actually ran

1. Launch the game, get to the main menu, quit.
2. Check that these now exist:
   - `BepInEx/config/BepInEx.cfg`
   - `BepInEx/LogOutput.log`

If both are there, BepInEx loaded. If not, the extraction went into the wrong folder.

## 3. Turn on the console (do this if you're developing)

Edit `BepInEx/config/BepInEx.cfg`, find the `[Logging.Console]` section, set:

```ini
Enabled = true
```

Now you get a live console window with mod logs when the game runs. Invaluable for
debugging; players usually leave it off.

## 4. Installing a mod

Most Nexus mods are a `.dll` (sometimes with a folder of assets). Drop it into:

```
Moonlight Peaks\BepInEx\plugins\
```

The wiki's convention — and the path the sample build scripts use — is a subfolder:

```
Moonlight Peaks\BepInEx\plugins\MoonlightPeaksMods\<modname>\
```

Read each mod's own instructions; some (portrait replacers, texture frameworks) want PNGs
dropped into a specific folder instead.

## 5. Configuring mods

- First launch after installing generates `BepInEx/config/<plugin.guid>.cfg`.
- Editing that file by hand is the baseline.
- Better: install **[Mod Menu](https://www.nexusmods.com/moonlightpeaks/mods/102)** by
  Elsiabeth — adds a "Mods" button to the pause menu and edits compatible mods' settings
  in-game.
- Some mods reference **ConfigurationManager** (the standard BepInEx in-game config UI,
  usually F1) — note that F1 collides with Serena's Grimoire's hotkey.

## Housekeeping

- **Back up your saves before modding.** Saves live under your user profile, not the game
  folder. Cheat/spawner mods can write things into a save that a later uninstall won't
  cleanly remove.
- **A game patch can break every mod at once.** Moonlight Peaks is a month old and patching
  frequently; Harmony patches bind to method signatures that updates can change.
- To fully uninstall: delete `BepInEx/`, `doorstop_config.ini`, and `winhttp.dll`, or just
  use Steam's "Verify integrity of game files".
- Mods marked "save-safe" (e.g. Far Sight) only touch presentation. Anything that spawns
  items or alters progression is not.
