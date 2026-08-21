# Description Review — all six live pages

Review pass on 2026-08-04, before any further edits. Structure and content only; the
mechanical formatting rules stay in [13-nexus-page-standard.md](13-nexus-page-standard.md).

**Status: applied to all six on 2026-08-04.** Every page below now follows the structure in
§1, with Mod Nook in the Configuration slot per §2 and Mod Menu removed entirely per §3.

Two things in this review were rejected in the doing, and the reasons are recorded where they
belong rather than here:

- **Name subtitles** — proposed for Coffin Break, Last Swing and Transplant. Applied to Coffin
  Break, then reverted. Mod names stay clean; see
  [13-nexus-page-standard.md](13-nexus-page-standard.md).
- **`afk` / `idle` tags** — not possible. Nexus tags are a fixed per-game vocabulary and both
  return "No Tags found".

---

## 1. The section order is wrong on all six

Every page currently runs:

```
Description → Installation instructions → Main features → Requirements → Shout outs
```

**Installation sits second**, ahead of what the mod actually does. A reader on that page has
not decided to install yet — they are deciding whether they want it. Install steps are
reference material you come back to *after* you have decided, not the second thing you read.

Proposed order:

```
Description        the hook — the problem, the fix, save-safe
Main features      what you get, scannable
Requirements       BepInEx, and nothing else
Installation       Vortex first, then manual
Configuration      where the settings are — and Mod Nook
Compatibility      what it sits alongside
Shout outs         credits
```

Everything a browser needs to decide is now above the fold-ish; everything an installer needs
is below it, in the order they will need it.

## 2. Mod Nook needs its own slot, and it is Configuration

This has been got wrong twice. To be explicit about what it is *not*:

- **Not a requirement.** It is not needed to run anything.
- **Not "more from me".** That framing sells my mod list. Wrong pitch.

What it actually is: **a mod you install alongside this one so that configuring this one is
better.** That makes it part of the answer to "how do I change the settings?", which is a
question every one of these pages already answers badly — the config path is currently
buried in the last line of the install steps.

So each page gets:

```
Configuration

Settings are written to BepInEx/config/<id>.cfg on first launch. The defaults are meant to
be left alone.

Install Mod Nook and you can change them in game instead. <Mod> shows up in it on its own —
<the one thing that is genuinely nicer for THIS mod>. Nothing here needs it; it just makes
this mod easier to live with.
```

The middle sentence is per-mod and must be concrete, not boilerplate:

| Mod | The line that earns it |
|---|---|
| Chest Labels | set the nameplate tint with a colour picker |
| Plant Peek | rebind the peek key by pressing it; set the detail level from a list |
| Coffin Break | nudge the idle timings on sliders and see it apply straight away |
| Last Swing | pick the yellow and red thresholds from a palette with a live preview |
| Transplant | bind the arming key by pressing it; toggle wild plants without leaving the game |

Mod Nook's own page inverts it: a Configuration section listing the five mods it configures.

## 3. Mod Menu comes out

It is currently recommended in Requirements on five pages and credited in Shout outs on all
six. The recommendation goes — pointing players at a competing settings menu on my own mod
pages makes no sense now that Mod Nook exists.

**Open question for you:** the Shout outs credit. Two defensible positions:

- **Drop it too.** Clean break, no mention of Mod Menu anywhere.
- **Keep it as history.** It genuinely was the thing that made the case for in-game settings,
  and modding scenes notice when prior art stops being credited. Wording would be purely
  past-tense: *"Elsiabeth, for Mod Menu — it made the case that in-game settings were worth
  having."* No link, no recommendation.

Currently removed from Chest Labels. Say which you want and it goes the same way on all six.

## 4. Content problems, per page

| Page | What is actually wrong |
|---|---|
| **Chest Labels** 119 | Edited live already, and the prose was rewritten further than it should have been — the Main features bullets were reworded into bold lead-ins that were not asked for. Needs reverting to your wording with only the structure changed. |
| **Plant Peek** 120 | Config path in a code block mid-sentence, which breaks the line in three. Shout outs lost the entchen66 / Farming QoL bullet that is in the draft. |
| **Coffin Break** 121 | Missing the *"stops the clock, not the game"* feature bullet — the one that stops the banner's "pause the game" reading as a false claim. Tagged `User Interface` on a mod with no interface. Missing `afk` / `idle` tags. Subtitle dropped. |
| **Last Swing** 122 | Worst formatting of the six: 77 hard line breaks, zero lists. Shout outs dropped the BepInEx team while Requirements demands BepInEx. Pins BepInEx to an exact build. Subtitle dropped. |
| **Transplant** 126 | 48 hard line breaks, zero lists. Summary starts lowercase with no full stop. Filed under User Interface; it is a Gameplay mod. Subtitle dropped. |
| **Mod Nook** 127 | Summary has three errors in one line. Paths in code blocks mid-sentence. Filed under Gameplay; it is a settings interface. |

## 5. What does not change

Worth stating so it does not get "improved" again:

- **Your Description prose.** The hooks are good and they are yours. Structure and formatting
  change; the words do not.
- **Your Main features wording.** Reformatting into a real list is fine. Rewriting the bullets
  is not.
- **Your Shout outs**, other than the Mod Menu question above and restoring credits that were
  dropped on upload.
- **"My Mate, for being my inspiration."** Stays on every page, same wording.

## 6. Order of work

1. Agree the skeleton and the Mod Menu question here.
2. Write all six as local drafts.
3. You read them.
4. Then, and only then, they go to Nexus — one page, shown rendered, before the rest follow.
