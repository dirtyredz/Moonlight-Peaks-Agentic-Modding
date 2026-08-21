---
name: nexus-publish
description: Publish or update a Moonlight Peaks mod on Nexus by driving Chrome — upload a new file version, restyle a description, or deploy a new mod page. Use when the user asks to publish, deploy, upload, push, or update a mod on Nexus, or to fix/restyle a mod page.
---

# Publishing to Nexus

You drive the user's real Chrome (`mcp__claude-in-chrome__*`) against their logged-in Nexus
account. Everything you write here is **public content on a live listing**.

Argument, if given, is the mod name or ID (e.g. `Chest Labels`, `119`). If absent, ask which
mod and which mode.

---

## 0. Read these first — do not skip

Working directory: `C:\Users\dirty\Moonlight Peaks`

| File | What it settles |
|---|---|
| `13-nexus-page-standard.md` | Section boilerplate, the edit form's behaviour, formatting rules |
| `14-description-review.md` | Section order, where Mod Nook belongs, decisions already made |
| `15-page-style.md` | **Palette, element vocabulary, per-mod emoji, and the `[line]` trap** |
| `12-versioning-and-release.md` | Version rules — the number moves only when publishing |
| `mods/<ModName>/CHANGELOG.md` | What actually changed in this version |
| `mods/<ModName>/RELEASING.md` | That mod's pre-release checklist |

`mods/<ModName>/nexus-paste.md` files are **superseded** and carry a banner saying so. They
hold pre-style BBCode. The **live page is the source of truth** — read its current BBCode out
of the edit form and modify that.

## Live mod IDs

| Mod | ID | Config GUID suffix |
|---|---|---|
| Chest Labels | 119 | `chestlabels` |
| Plant Peek | 120 | `plantpeek` |
| Coffin Break | 121 | `coffinbreak` |
| Last Swing | 122 | `lastswing` |
| Transplant | 126 | `transplant` |
| Mod Nook | 127 | `modnook` |

Config files are `BepInEx/config/com.dirtyredz.moonlightpeaks.<suffix>.cfg`.
BiggerUI is unpublished.

---

## 1. Get a browser

```
ToolSearch: select:mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__javascript_tool,mcp__claude-in-chrome__computer,mcp__claude-in-chrome__find,mcp__claude-in-chrome__file_upload
```

Then `tabs_context_mcp{createIfEmpty:true}` and navigate to
`https://www.nexusmods.com/games/moonlightpeaks/mods/119/edit/general`.

If the page says "Please log in" or the extension is not connected: **stop and ask the user to
sign in themselves.** You must never enter credentials. The in-app Browser pane
(`mcp__Claude_Browser__*`) is a *different* browser and is not logged in — it is fine for
reading public pages, useless for editing.

Edit tabs: `/edit/general`, `/edit/media`, `/edit/files`, `/edit/requirements`,
`/edit/permissions`.

---

## 2. How the form actually works — three traps

These have each caused a silent failure. Do not trust the editor.

### The description is BBCode behind SCEditor

The visible editor is an iframe; the real value is a hidden `<textarea>` holding BBCode.
**Writing to the textarea directly does nothing** — SCEditor overwrites it on submit. Go
through the instance:

```js
const ta = [...document.querySelectorAll('textarea')]
  .find(t => t.parentElement.className.includes('bbcode-editor'));
const current = ta._sceditor.val();          // read the live BBCode
ta._sceditor.val(newDoc);                     // write
ta._sceditor.updateOriginal();
ta._sceditor.valueChanged();                  // required, see below
```

### Save is disabled unless a React-controlled field differs

The description textarea is uncontrolled, so changing it does **not** mark the form dirty —
Save stays greyed out and clicking does nothing. The dirty check is a real value comparison,
so setting a field to its existing value does not help either.

If the edit also changes the short description, name or category, that dirties it naturally.
For a **description-only** edit, pad and restore across two saves:

```js
const save = () => [...document.querySelectorAll('button')]
  .filter(b => /^\s*Save\s*$/.test(b.innerText))
  .forEach(b => { if (!b.disabled) b.click(); });
const sd = document.getElementById('short-description');
const set = (el,v) => { Object.getOwnPropertyDescriptor(el.constructor.prototype,'value')
  .set.call(el,v); el.dispatchEvent(new Event('input',{bubbles:true})); };

set(sd, sd.value.replace(/\s+$/,'') + ' ');   // pad → dirty
save(); await new Promise(r=>setTimeout(r,3500));
set(sd, sd.value.replace(/\s+$/,''));          // restore
save(); await new Promise(r=>setTimeout(r,3000));
```

Then assert `!/\s$/.test(sd.value)` — never leave the padding space saved.

### `[hr]` is silently destroyed

SCEditor rewrites `[hr]` to `[line]`, renders a rule in the editor, and **Nexus strips
`[line]` from the public page.** Use the character rule from `15-page-style.md`:

```
[color=#7A6A9B]────────────────────────────────────────[/color]
```

---

## 3. Verify on the live page. Always.

The editor is not a preview. After every save, fetch the public page and assert:

```js
const r = await fetch(`https://www.nexusmods.com/moonlightpeaks/mods/${id}?cb=${Date.now()}`,
  {credentials:'include', cache:'no-store'});
const t = await r.text();
const d = new DOMParser().parseFromString(t,'text/html')
  .querySelector('.mod_description_container');
({ lists: d.querySelectorAll('ul,ol').length,
   panels: d.querySelectorAll('blockquote').length,
   rules: /────/.test(t),
   modMenuAbsent: !/Mod Menu/.test(t) })
```

A save that appears to succeed can persist only *some* fields — this has happened. If an
assertion fails, say so plainly rather than reporting success.

Reading large values back can trip a content filter (`[BLOCKED: ...]`). Return counts,
booleans and short slices instead of dumping raw HTML or full field values.

---

## 4. Mode A — update an existing mod (new file version)

1. **Confirm the version.** `<Version>` in the csproj and `PluginVersion` in `Plugin.cs` must
   match, and the number moves only for a release (`12-versioning-and-release.md`). The
   archive in `dist/` is named from the csproj.
2. **Confirm the archive exists** in `dist/` and its layout is
   `BepInEx/plugins/<ModName>/<ModName>.dll`.
3. Go to `/edit/files`. The file input accepts `.rar .zip .7z .exe .omod`, max 20GB, one at a
   time. Attach with `mcp__claude-in-chrome__file_upload`.
4. Set **name**, **version**, and **category** (`Main` for a normal release). Use the
   `Update` action on the existing file if replacing rather than adding.
5. Add the player-facing changelog. Describe the **symptom**, not the Harmony patch —
   `mods/<ModName>/CHANGELOG.md` is written for us, the Nexus changelog is for players.
6. Update the description only if the release changes what it says.
7. Verify per §3, then confirm the new file shows on the public Files tab.

**Ask before uploading.** A new file is public distribution. Show the user the archive path,
version and changelog text, and wait for a clear yes.

## Mode B — restyle or fix a description

Read the current BBCode out of the editor, modify it, write it back. Follow
`15-page-style.md` exactly — palette, per-mod emoji, promise panel, at-a-glance strip.

**Preserve the user's prose.** Description paragraphs and Main features bullet wording are
theirs. You may restructure, reformat and re-order; you may not rewrite their sentences into
your own. This has gone wrong before.

## Mode C — deploy a new mod page

⚠️ **Unverified flow — no new mod has been created this way yet.** The "Upload" control in
the header is a JS button, not a link, so discover the flow rather than assuming it. Expect
the same five tabs: General → Media → Files → Requirements → Permissions.

Work through the sections using `15-page-style.md` for the description, then **stop before
publishing** and show the user the fully staged page. Creating a public listing is not
something to do on your own initiative.

---

## 5. Standing decisions — do not relitigate

- **Never rename a mod** to add a keyword subtitle. Tried, rejected.
- **Never recommend Mod Menu.** Mod Nook is the companion, and it belongs in the
  **Configuration** section — not Requirements, not a "more from me" plug.
- **No AI-disclosure line** on any page.
- Nexus **tags are a fixed per-game vocabulary**; free text like `afk` cannot be added.
- Structured requirements: `/edit/requirements` offers file-to-file (on-Nexus files and DLC
  only) or **mod requirements (legacy)** for external files. BepInEx is off-site, so legacy is
  the only route — currently unset on all six, deliberately.
- Do not copy another author's page identity. See the "what we deliberately do not do"
  section of `15-page-style.md`.

## 6. Report honestly

State per mod what changed and what you verified against the live page. If something was
skipped, blocked, or failed an assertion, say which and why. Do not report success on the
strength of the editor looking right.
