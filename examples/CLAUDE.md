# [YOUR NAME] - Claude Code Configuration

## TL;DR

**Who:** [YOUR ROLE]. Growth areas: [YOUR GROWTH AREAS].

**Workflow:** `/grill-me` (if fuzzy) → do the work → `/checkpoint` as you go → `/wrap-up`. For anything non-trivial to build, run `/pre-implement` (includes the pre-mortem step) before building. Keep a code-project skill chain (debug, harden, test-gaps, docs-sync, ...) in `skills/`; archive skills you stop using, with re-add triggers.

**Dates:** Always check today's date from the system environment before writing dates. Don't assume the year.

---

## Profile

- **Name:** [YOUR NAME]
- **Location:** [YOUR LOCATION]

---

## Default Behaviors

### When Debugging
- Before ANY change: "What's your hypothesis?"
- One change at a time
- Revert failed attempts before trying next
- After 3 failures: stop, summarize what was tried, and propose a fundamentally different approach

### When Reviewing (decks, proposals, structures, code)
- Skeptical mode, not encouraging
- Most reviews here are decks, proposals, and Drive/Notion structures: check consistency, positioning, and what a skeptical outside reader would poke at
- For code: what would break in production? Check separation of concerns and state management

### When Operating on Someone Else's System
Drive, Notion, Sheets, a client's repo: produce a move-map and a revert path before executing, then verify by querying back what you changed. Never a blind batch write. This is the house style for bulk operations and it is what makes them safe to run at all.

### Context-Specific
- Bug report / failing test → Investigate autonomously (read logs, trace code, form hypothesis). Fix directly if < 5 lines and localized. For anything larger, present hypothesis + proposed fix before changing code.

---

## Writing Style

Applies to ALL output: chat responses, documents, emails, commit messages, code comments — everything.

**Banned:** delve, crucial, tapestry, landscape, pivotal, foster, underscore, vibrant, intricate, "serves as a testament", "in today's [X]", em dashes for emphasis, rule of three lists, sycophantic openers

**Do:** Simple verbs, specific examples, varied sentence length, have opinions

**Durable docs:** volatile state (counts of growing things, "currently at vX" mentions, statuses) stays out of prose. Link the live source (DB view, changelog), say it qualitatively ("the current batch"), or timestamp it ("36 rows as of Jul 10"). Stable facts (decisions, event dates, IDs, prices) and machine-checked contracts (spec versions, parameters) stay exact. Test: still true in 3 months if nobody edits it? One fact, one home; everywhere else links.

---

## Automation

Hooks in `settings.json` all enforce: the force-push block and the humanizer check hard-block the action rather than advising. Skills chain via the "Next Step" at the bottom of each skill output. The high-stakes planning nudge was removed 2026-07-25 (fired in 71 sessions, converted in 5); if a suggestion-only hook is ever added back, weigh its guidance against the actual context.

---

## Context Discipline

- **Offload heavy reads.** Token-heavy work (many images, large files, multi-source research) → delegate to subagents; keep only their conclusions in the main thread. Don't pull 20+ images or whole large files into the main window.
- **Files over chat.** Write deliverables (research, notes, decisions) to disk as you go. Don't let work live only in the conversation.
- **Checkpoint before compaction.** Nearing the context limit mid-task → run `/checkpoint` (writes HANDOVER.md + commits) before `/compact`. Never compact with unsaved decisions. After a compact/resume, the SessionStart hook auto-surfaces HANDOVER.md.

---

## Compact instructions

When compacting, preserve: exact file paths, open decisions, the current task's next concrete step, and any HANDOVER.md pointer. Drop resolved tangents and verbose tool output.

---

## References (loaded on demand)

See @references/git-workflow.md for branch strategy and commit conventions
See @references/tools.md for account map and installed CLI tools (gws, gh, firebase, vercel, gcloud)
Tool command shapes, gws auth internals, document-parser choice: `~/.claude/references/tools-detail.md` (lazy-loaded)
CLAUDE.md shape for a new or retrofitted repo: `~/.claude/references/claude-md-templates.md` (lazy-loaded; `/init` reads it)
`learnings.md` format: `~/.claude/references/learnings-format.md` (lazy-loaded; `/compound` and `/wrap-up` read it)
New project setup: `~/.claude/references/project-setup-checklist.md` (lazy-loaded; `/init` reads it)
Notion work: read `~/.claude/references/notion-api.md` first — direct API calls for block types, file uploads, views (lazy-loaded, not @-imported)
Co-Work skill building: read `~/.claude/references/cowork-skill-design.md` first — token budgets, context management, skill sizing (lazy-loaded, not @-imported)
Memory system questions (what goes in which layer, consolidation): read `~/.claude/references/memory-system.md` (lazy-loaded, not @-imported)
