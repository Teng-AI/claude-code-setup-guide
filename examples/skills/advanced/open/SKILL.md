---
name: open
description: Find and open a file by fuzzy name match and surface it inside Claude Code. Use when user says "open X", "show me X", or wants to open a specific file (markdown, PDF, image, etc.) without specifying the full path.
---

# Open

Find a file matching the user's query and surface it **inside Claude Code**, using `SendUserFile`.

**Do not launch another application.** The point is to not get yanked out of the session: no file
should pull you into an editor, and none should be handed off to Claude chat either. Claude Code is
where the work is happening, so that is where the file appears. Everything else is an escape hatch
the user has to ask for by name.

Use `/open` for:
- Files from prior sessions or older work
- Files Claude didn't directly edit (e.g., reference docs, lease PDFs, formation paperwork)
- Files in folders the user mentions but you haven't read yet
- A file just created or edited in this session, when the user wants to see it in its default app

## How It Works

1. Take the user's query as a search term (whatever they typed after `/open`).
2. Search for matching files using `find` across `~/Documents/projects/` (their main projects directory).
3. Surface the best match with `SendUserFile`, or ask the user to pick if there are multiple.

## How To Surface It

Call `SendUserFile` with the path. Pick `display` by what the file actually is:

| File | `display` | Why |
|---|---|---|
| `.md`, `.html`, `.svg`, images, `.pdf`, `.csv` | `render` | opens inline in the side panel |
| source code, data, anything else | `attach` | a card he can click; an inline preview would be noise |

`.html` is the one that needs a decision. `render` shows the **rendered page**, not the source. That
is right for a report or a deck and wrong when he asked to read the markup. If the request was about
the code ("review the html", "what's in the css"), say what you are doing and offer `--editor`.

## The Escape Hatches

Only when the user asks for another app by name, or the file genuinely needs one.

```bash
~/.claude/skills/open/open-with.sh --editor "<path>"    # the editor already in use
~/.claude/skills/open/open-with.sh --default "<path>"   # Preview, Numbers, whatever owns the type
~/.claude/skills/open/open-with.sh --which              # print the editor, open nothing
```

**Never run `open -a Claude`.** That hands the file to Claude *chat*, which is a different surface
from Claude Code. It exits 0 and looks like it worked.

**Do not use the frontmost app to find the editor.** When Claude Code opens a file the frontmost app
is Claude itself, so `lsappinfo front` returns `Claude` every time. The trap is invisible if you test
detection by hand in a terminal. `open-with.sh` walks `lsappinfo visibleProcessList` instead, which
is front-to-back z-order, and takes the first known editor.

## The Command

```bash
find ~/Documents/projects -type f \
  -iname "*<query>*" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/.next/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  2>/dev/null | head -20
```

Replace `<query>` with the user's input. Use `-iname` for case-insensitive matching.

## Decision Logic

| Number of matches | Action |
|-------------------|--------|
| **0** | Tell user nothing found. Suggest broadening the query or checking spelling. |
| **1** | `SendUserFile` it, with `display` chosen from the table above. Say in one line what it is. |
| **2–5** | List numbered, ask user to pick. Don't open until they choose. |
| **6+** | Show top 5 by relevance + total count. Ask for a narrower query. |

## Relevance Tips

If multiple matches, prefer:
- Exact filename match over partial
- Files in shallower directories (closer to project root) over deep nests
- Recently modified files over old ones (use `ls -lt` if helpful)
- Working/source files (`.md`, `.pdf`, `.html`) over generated artifacts

## Examples

**User:** `/open roadmap`
→ Search for `*roadmap*`. If multiple roadmaps exist across projects, list them.

**User:** `/open form 2553`
→ Search for `*2553*` (the more specific term).

**User:** `/open lease`
→ Search for `*lease*`. Multiple matches likely → ask which one.

**User:** `/open`
→ No query given. Ask "what file do you want to open?"

## Edge Cases

- **Query is a full path:** Skip the search, surface it directly.
- **User names an app** ("open it in Preview", "in Cursor"): honour it, `open -a "<App>" <path>`.
- **Query has spaces:** Wrap in quotes for the find command. Try splitting on spaces if the literal match returns nothing.
- **No matches in `~/Documents/projects/`:** Try broader search in `~/Documents/` or ask user where to look.
- **Match is inside a `.app` bundle or hidden folder:** Skip it.
- **Match is in `*/memory/*` (Claude's auto-memory):** Skip — these are internal context files, not user-authored docs.

## What This Skill Does NOT Do

- Doesn't index files in advance — relies on `find` each time.
- Doesn't open URLs or web links — use a browser for those.
- Doesn't read the file or summarize — just surfaces it.
- Doesn't launch another app unless asked. That is the whole point of the skill now.
- Doesn't search file contents — only filenames.

If you need content search, use `grep` directly — don't extend this skill.
