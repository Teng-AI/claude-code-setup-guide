---
name: open
description: Find and open a file by fuzzy name match. Use when user says "open X", "show me X", or wants to open a specific file (markdown, PDF, image, etc.) without specifying the full path.
---

# Open

Find a file matching the user's query and open it with the system default app (`open` on macOS).

Use `/open` for:
- Files from prior sessions or older work
- Files Claude didn't directly edit (e.g., reference docs, lease PDFs, formation paperwork)
- Files in folders the user mentions but you haven't read yet
- A file just created or edited in this session, when the user wants to see it in its default app

## How It Works

1. Take the user's query as a search term (whatever they typed after `/open`).
2. Search for matching files using `find` across `~/Documents/projects/` (their main projects directory).
3. Open the best match, or ask the user to pick if there are multiple.

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
| **1** | Open it: `open "<path>"`. Confirm what was opened in one line. |
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

- **Query is a full path:** Just run `open <path>` directly.
- **Query has spaces:** Wrap in quotes for the find command. Try splitting on spaces if the literal match returns nothing.
- **No matches in `~/Documents/projects/`:** Try broader search in `~/Documents/` or ask user where to look.
- **Match is inside a `.app` bundle or hidden folder:** Skip it.
- **Match is in `*/memory/*` (Claude's auto-memory):** Skip — these are internal context files, not user-authored docs.

## What This Skill Does NOT Do

- Doesn't index files in advance — relies on `find` each time.
- Doesn't open URLs or web links — use a browser for those.
- Doesn't read the file or summarize — just opens it in the default app.
- Doesn't search file contents — only filenames.

If you need content search, use `grep` directly — don't extend this skill.
