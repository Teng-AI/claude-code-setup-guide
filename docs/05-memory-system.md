# Memory System

> **Revision note (July 2026).** This doc originally described only Claude Code's built-in auto-memory. The live config has since grown a layered system around it (learnings logs, a promotion ladder, session handoffs, and scheduled consolidation), and an infrastructure audit produced an ownership map for what goes where. This version documents the full system.

## What Memory Is

Claude Code has a persistent, file-based memory that lets it remember things across conversations. When you tell Claude something important (your role, a correction, an ongoing constraint), it stores that in a memory file and recalls it in future sessions.

Memory is for durable context: things that stay true across conversations and that Claude cannot infer from the codebase alone.

## The Four Altitudes

The single most useful mental model: knowledge lives at four altitudes, each with a different writer and load time.

| Altitude | What lives there | Who writes it | When it loads |
|---|---|---|---|
| **Instructions** -- `~/.claude/CLAUDE.md` + eagerly-loaded `@refs` | Rules, workflow, style, tool cheatsheets | You | Every session, in full |
| **Index** -- `~/.claude/projects/<project>/memory/MEMORY.md` | One-line pointers to learned knowledge | Claude | Every session, but only the first ~200 lines / 25KB |
| **Content** -- topic files, `learnings.md`, `references/` | The actual knowledge | Claude (plus you) | On demand, via the index |
| **State** -- `HANDOVER.md`, `brainstorms/`, work logs | Where you left off, and why | Claude | Session boundaries only |

**Golden rule:** instructions are things you tell Claude (a correction you keep repeating belongs in CLAUDE.md); memories are things Claude discovered (a debugging insight belongs in a topic file).

## The Ownership Map (what goes where)

1. **Changes Claude's behavior** (tool gotchas, preferences, process) -> auto-memory. Nothing else goes there.
2. **World knowledge you would read yourself** -> a personal knowledge vault (a plain folder of markdown topic pages works fine); memory gets at most a one-line pointer stub.
3. **Project-specific lessons** -> that repo's `learnings.md`. They stay there.
4. **Global-scope lessons** -> the `learnings.md` entry AND a topic file in your home project's memory AND its MEMORY.md index line. All three, always; `/compound` enforces this.
5. **Tasks, ideas, triage** -> your task tracker. **Volatile status** -> nowhere durable; link the live source instead.
6. **When unsure:** for Claude -> memory; for you -> the vault; for this repo -> `learnings.md`.

## Memory Location

- **Project memory:** `~/.claude/projects/<escaped-project-path>/memory/` -- scoped to one project, loaded when working in that project's directory.
- **Home/global memory:** the same structure under your home project's path. Cross-project learnings live here as `learning_<slug>.md` topic files.

Each memory directory has a `MEMORY.md` index that Claude reads at conversation start. One line per memory, pointer only; content stays in the individual files.

## Memory Types

| Type | What it holds | Example |
|------|--------------|---------|
| `user` | Who you are: role, expertise, preferences | "Prefers explicit error handling over try/catch." |
| `feedback` | Guidance on how Claude should work, with the why | "Don't use default exports here; named exports everywhere." |
| `project` | Ongoing work, goals, constraints not derivable from code | "Migrating REST to GraphQL; new endpoints use GraphQL." |
| `reference` | Pointers to external resources | "Design specs live in Figma at [URL]." |

## Memory File Format

```markdown
---
name: short-kebab-case-slug
description: one-line summary, used to decide relevance during recall
metadata:
  type: user | feedback | project | reference
---

The fact. For feedback/project types, follow with **Why:** and
**How to apply:** lines. Link related memories with [[their-name]].
```

## learnings.md: The Capture Layer

Each project keeps a `learnings.md` in its root, appended to whenever you correct Claude, an assumption proves wrong, a library misbehaves, or a design decision has non-obvious rationale. Entries are typed (`correction`, `pattern`, `decision`, `domain`) and kept to 3-5 lines. See [Project Setup](06-project-setup.md) for the full format.

Capture is done by `/compound`, either standalone or as a step inside `/wrap-up`.

## The Promotion Ladder

Knowledge moves up as it proves durable:

Session observation -> (`/compound`) -> `learnings.md` entry -> (globally useful?) -> home memory `learning_*.md` topic file -> (recurred 3+ sessions, or really a rule?) -> CLAUDE.md rule, reference file, or skill.

At each hop the lower entry collapses to a pointer ("-> promoted to X") so knowledge never lives in two places.

## Lifecycle: What Runs When

| Moment | What runs | Manual or auto |
|---|---|---|
| Session start | MEMORY.md index loads natively; a SessionStart hook surfaces a recent HANDOVER.md after compact/resume | Auto |
| Coding session start | `/session-start` reads memory and scans hot `learnings.md` entries | Manual |
| Context running low | `/checkpoint` writes HANDOVER.md and commits | Manual |
| Compaction | A PreCompact hook archives the transcript and summarizes to HANDOVER.md, unless a manual checkpoint is fresh | Auto |
| Session end | `/wrap-up` runs `/compound`, updates memory, commits it | Manual |
| Monthly | `/setup-audit` checks index size caps, orphaned files, oversized learnings logs, uncommitted drift | Manual (cadenced) |
| When rot is flagged | A consolidation pass: merge duplicates, index orphans, slim the index, convert relative dates to absolute, delete contradicted facts | Manual |

## Failure Modes to Hunt

1. **Invisible memory.** A topic file with no index line is never recalled. Every file gets an index one-liner with the keywords you would actually search.
2. **Stale facts.** Memory reflects when it was written. Verify remembered specifics (paths, flags, IDs) against reality before acting on them, and use absolute dates only.
3. **Fat index.** Content pasted into MEMORY.md silently truncates at the load cap. The index holds greppable pointers; content belongs in topic files (moved verbatim, never summarized away).

## What Memory Is NOT

- **Not for ephemeral task details.** If it only matters this conversation, it does not belong in memory.
- **Not for things derivable from code.** If Claude can read it from source, tests, or git history, storing it just creates staleness risk.
- **Not for things already in CLAUDE.md.** One fact, one home.

## Deliberately Not Used

Vector or graph memory servers (markdown-first; add one only if flat files fail) and separate usage-logging hooks (grepping transcripts during the audit covers it). Boring files that you can read, diff, and commit beat infrastructure you have to maintain.
