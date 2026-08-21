# Nexus Page Standard

Applies to every mod's page. The three fields below drifted across the first six listings —
each one was written fresh, so the same claim ended up phrased six ways. Paste from here.

Per-mod copy lives in `mods/<Name>/NEXUS.md`; this file is what those agree on.

---

## Requirements

Always this shape, in this order:

```
Required

- BepInEx 5 (win_x64), version 5.4.23.5 or newer

Recommended companion

- Mod Nook — my in-game settings menu. <one line on what this mod's settings gain from it.>
  Nothing here needs it; without it the settings live in a plain config file.
  https://www.nexusmods.com/moonlightpeaks/mods/127
- Mod Menu by Elsiabeth does the same job and is also supported. Mod Nook and Mod Menu can
  both be installed — each adds its own button and neither interferes with the other.

PC/Steam only. The Switch and mobile builds cannot load BepInEx.

Compatibility

<per-mod>
```

**Do not pin BepInEx to an exact build.** Last Swing's page said `BepInEx 5.4.23.5` flat,
which reads as "only this build works" and dates the page the moment BepInEx updates. State
the floor: *5.4.23.5 or newer*. Keep `(win_x64)` — it is the download a player has to pick
from between several on the BepInEx releases page, and it is the one thing they can get wrong
before the mod has even loaded.

**Mod Nook goes on every page.** It is the reason none of these mods ship a settings screen,
and the sentence should say what *this* mod's settings gain from it — a colour picker, a key
bound by pressing it, a slider that cannot go out of range. A generic "adds a Mods page"
line is the same sentence six times and reads like boilerplate, because it is.

Mod Nook's own page carries the reverse: the five mods it configures, each with the one
setting that is nicer in it.

---

## Installation instructions

Vortex first — most people never read past it.

```
With Vortex

Open the Files tab, click the Vortex button, and enable the mod. Done.

Manually

1. Install BepInEx 5 (win_x64) into your Moonlight Peaks folder if you do not have it
   already. The BepInEx folder sits beside Moonlight Peaks.exe.
2. Launch the game once, then quit. This creates the BepInEx/plugins folder.
3. Download the archive from the Files tab and extract it over your Moonlight Peaks folder,
   so the file ends up at BepInEx/plugins/<Name>/<Name>.dll.
4. Launch the game.

Settings are written to BepInEx/config/com.dirtyredz.moonlightpeaks.<name>.cfg on first
launch. With Mod Nook installed you never need to open it — every setting appears under
Pause > Mod Nook and applies immediately, without a restart.

To uninstall, delete BepInEx/plugins/<Name>. <per-mod save-safety line.>
```

Four points that were missing from one page or another:

- **Launch once, then quit.** Three pages jumped straight from "install BepInEx" to "extract
  the mod", which on a clean install means extracting into a `plugins` folder that does not
  exist yet.
- **The full DLL path**, not just the folder. "It will land in BepInEx/plugins/X" is not
  something a player can check; a path they can paste into Explorer is.
- **The Vortex line.** It was written for Last Swing and never reached the live page.
- **Where the config file is**, so the mod is configurable without Mod Nook.

---

# The edit form, mechanically

Learned the hard way on 2026-08-04. Worth knowing before editing a page by any means other
than typing into it by hand.

**The description is BBCode, not rich text.** The field is [SCEditor](https://www.sceditor.com/)
wrapping a hidden `<textarea>` whose value is raw BBCode — `[size=4][b]…[/b][/size]`,
`[list]`, `[*]`, `[color=#D4D4D8]`, `[url=…]`. The WYSIWYG surface is an iframe. This is why
each mod's `nexus-paste.md` is stored as BBCode: it is literally the field's value.

**Setting the textarea directly does nothing.** SCEditor holds its own state in the iframe and
overwrites the textarea on submit. Content must go through the editor instance
(`textarea._sceditor.val(...)`, then `updateOriginal()`).

**Save stays disabled until a React-controlled field actually differs.** The description
textarea is uncontrolled (`defaultValue`), so changing it never marks the form dirty — the
Save button stays greyed out and a click does nothing. The dirty check is a real value
comparison, not a "was touched" flag: setting a field to its existing value leaves Save
disabled.

So a description-only edit needs something else to differ. Where the page also needs a new
short description, that does it. Where it does not, the workaround is to save twice — pad the
short description, save, strip the padding, save again — and verify the final text has no
trailing space.

**This silently half-saves.** The first attempt on Chest Labels saved the short description
and dropped the description entirely, with no error shown. **Always verify against the live
page after saving**, not against the editor.

---

# Formatting

Measured off the live HTML of all six pages on 2026-08-04. The plain text reads fine on every
one of them; the markup does not, and the difference is only visible in the rendered page.

| Page | Real lists | `<br>` | Inline bold | Verdict |
|---|---|---|---|---|
| Chest Labels 119 | yes | few | yes | good |
| Plant Peek 120 | yes | few | yes | code blocks break two sentences |
| Coffin Break 121 | 5 lists, 19 items | 28 | 15 | **the reference. Match this one.** |
| Last Swing 122 | **none** | **77** | **none** | needs a full re-paste |
| Transplant 126 | **none** | **48** | **none** | needs a full re-paste |
| Mod Nook 127 | 3 lists, 16 items | 26 | 24 | code blocks break two sentences |

## 1. Never paste hard-wrapped text

This is the one that ruined Last Swing. These notes are wrapped at about 90 columns so they
are readable in the repo. The editor turns **every one of those wraps into a `<br>`**:

```html
Chopping a tree in Moonlight Peaks tells you nothing. Hit one looks and sounds exactly<br>
like hit four — the same shake, the same puff of leaves, the same thud. So the only way<br>
to know whether a rock is nearly broken is to keep swinging and find out.
```

The result is a paragraph frozen at 90 characters wide. It does not reflow, so on a narrower
window every line wraps again halfway through and the text goes ragged; on a wider one it
sits in a column down the left with the rest of the page empty beside it. Reading the page
as plain text gives no hint that anything is wrong.

**Every paragraph must be a single unbroken line before it goes into the editor.** That is
what `nexus-paste.md` in each mod folder is for — same copy, unwrapped, ready to paste.

## 2. Use the toolbar's list button

Last Swing and Transplant have **zero** `<ul>` between them. Their steps and features are
literal `1.` and `- ` characters on `<br>` lines, while Coffin Break's identical copy renders
as proper lists.

Paste the bullet lines with no `-` or `1.` in front, one per line, then select them and press
the bulleted or numbered list button. Ordered lists come out as
`<ul class="content_list content_list_ordered">`, which is correct.

## 3. Do not put a code block inside a sentence

Plant Peek and Mod Nook both do this, and both sentences are shredded:

```html
To uninstall, delete the <br><br><pre><code>BepInEx\plugins\ModNook</code></pre> folder.
```

`<pre>` is a block element. It forces a break before and after, so the sentence lands on
three lines with the word "folder." orphaned underneath a grey box. Coffin Break writes the
same paths as plain text and reads perfectly.

**Paths go inline as ordinary text, or bold.** Keep the code-block style for a path that
genuinely sits alone on its own line, and write the sentence so nothing follows it.

## 4. Bold every heading the same way

All six use `<font size="4"><strong>` for the five section headings, which is right — the
headings are typed into the description, they are not fields the form gives you. Keep them
identical, and do not size sub-labels like **Required** and **Recommended companion**; those
are plain bold at body size.

## 5. Watch what the paste drags in with it

- **`&nbsp;`** — Mod Nook has whole sentences where every space is a non-breaking space, so
  those lines cannot wrap at all. It comes from pasting out of a rendered view rather than a
  plain-text one. Paste from the raw file.
- **Colour spans** — every page is wrapped in `color: #D4D4D8`, and Transplant has both
  `#D4D4D8` and `#d4d4d8`, which is two pastes from two sources. Harmless today, but it means
  the text is pinned to a colour rather than inheriting the site's, so it will not follow a
  future theme change. Clear formatting on paste and let the site style it.
- **BBCode** — Mod Nook's draft is written in BBCode and it did render, so the editor parses
  it. But `[list=1]` still came out unordered and `[font]` produced 13 stray `<font>` tags.
  It is not worth the ambiguity: paste plain text and use the toolbar.

---

## Shout outs

Every page carries these four, in this order:

1. **Little Chicken Game Company** — with the mod-specific reason, not a stock line.
2. **The BepInEx and HarmonyX teams**, without whom none of this scene exists.
3. **Elsiabeth** for Mod Menu — it made the case that in-game settings were worth having,
   and it is why none of these mods had to build a settings screen of their own.
4. **My Mate**, for being my inspiration.

Then anyone whose page or mod actually shaped this one — cherrikei for Clock Pause,
SerenaEnchanted for Conjuring, MissLarifari1 for the "comfort, not a cheat" framing.
Those are the credits that mean something, and they are worth naming precisely.

**Credit BepInEx on every page that requires it.** Last Swing's live shout outs list dropped
the BepInEx team entirely while its Requirements field demands BepInEx.

**Keep the wording identical** where the credit is identical. Four pages thanked Elsiabeth in
four slightly different sentences, and "My Mate" appeared as `My Mate, for being my
inspiration`, `...inspiration.` and `My Mate - my inspiration for this.` on the same day.

---

## No AI disclosure line

Decided 2026-08-04: mod pages do not carry a "created with generative AI tools" sentence.
Removed from Mod Nook's draft, where it was the only one that had it; it was never on the
live page.

The one thing left inconsistent with that is the **`AI Media` tag on Coffin Break** — no
other page has it. Same decision applies either way; just make it the same on all six.

---

## Name and summary

These two are the entire listing tile. Everything above only matters once someone has already
clicked.

### Mod names stay clean — no keyword subtitles

Settled 2026-08-04. Several drafts specified names with descriptive subtitles
(`Coffin Break - AFK Auto-Pause`, `Last Swing - Health Bars for Trees and Rocks`,
`Transplant - Move Planted Crops Without Losing Growth`) on the reasoning that Nexus keyword
search matches titles.

**That reasoning loses to the name being the name.** Coffin Break was renamed and reverted
within the hour. Do not bolt detail onto a mod name — the short description is where the
searchable words go, and it is right underneath the title on every listing tile anyway.

The earlier per-mod notes saying "the subtitle carries the search, do not drop it" are
superseded. Leave the names alone.

### Tags are a fixed vocabulary

Worth knowing before planning around them: Nexus tags are chosen from a per-game list, not
typed freely. `afk` and `idle` — the two terms a keyword sweep found completely unused for
this game — return **"No Tags found"** in the tag field and cannot be added. A keyword sweep
measures *search*, which the description body serves; it says nothing about what is taggable.

### Summaries

Three of the six are fine. Three are not:

**Chest Labels** currently reads *"Chest Labels — a Moonlight Peaks mod for naming your chests.
Save-safe, BepInEx 5."* That is a repo README line — it names the mod twice, states the game
the reader is already browsing, and spends its last four words on a dependency. Replace with:

> Name your chests and see which is which — a title in the chest window and a label when you
> mouse over it.

**Transplant** currently reads *"open decorate mode, move a planted crop. Growth stage, planted
day and harvest count all survive"* — lowercase start, no closing full stop, and it opens with
an instruction to someone who does not yet know what the mod is. Replace with the drafted line:

> Planted the row slightly wrong? Move it. Crops keep their growth, and they will not let you
> strand them somewhere they cannot be watered.

**Mod Nook** currently reads *"Configure your mods your way An In-Game tool for changing other
mods config's. Designed to feel like its part of the game."* — a missing full stop after "way",
`config's` should be `configs`, and `its` should be `it's`. Three errors in the one line that
appears on every listing tile. Replace with:

> Every mod's settings, in the pause menu. Sliders, colour pickers and key binding by pressing
> the key — built out of the game's own interface.

Rules the three good ones follow: lead with the player's problem or the outcome, not the
mechanism; do not name the mod or the game; end with a full stop; keep the first sentence
standing alone, because listings truncate around 200 characters.

---

## Tags and category

Tags are keyword search. Set them deliberately.

- Coffin Break is tagged `User Interface` on a mod that has no interface beyond a badge, and
  it is missing `afk` and `idle` — the two terms `mods/CoffinBreak/NEXUS.md` established
  return **zero** results for this game. That was the whole plan and it did not make it onto
  the page.
- Transplant is filed under **User Interface**; its draft argued for **Gameplay**, alongside
  Free Decorate and Walk Through Crops, which is where someone looking for it would browse.
- Mod Nook is filed under **Gameplay**; it is a settings interface.

Category is where people browse, tags are how people search, and neither is the other.
