---
name: wrap-up
description: End-of-session documentation routine. Creates work log, captures decisions, updates roadmap, and prepares handoff for next session. Use when ending a coding session, saying "done for today", "let's wrap", or "what did we accomplish".
disable-model-invocation: true
---

# Session Wrap-Up

A quick routine to close out a coding session. Captures what was done and sets up the next session for success.

## When to Use

Run `/wrap-up` when:
- Ending a coding session
- Done for the day
- Switching to a different project
- Before a break longer than a few hours
- User says "wrap up", "let's wrap", "done for today"

## IMPORTANT: Always Save Session Notes

**This skill MUST save a session log file.** Don't just output to screen - future sessions depend on this context.

### Where to Save

Check for existing work-logs structure:
```
.claude/work-logs/           ← Preferred (if exists)
docs/work-logs/              ← Alternative
work-logs/                   ← Alternative
```

If no work-logs folder exists, create one at `.claude/work-logs/`.

### File Naming

```
.claude/work-logs/YYYY-MM/YYYY-MM-DD_session-NN.md
```

Example: `.claude/work-logs/2025-01/2025-01-29_session-01.md`

If multiple sessions in one day, increment NN (session-01, session-02, etc.)

---

## The Wrap-Up Checklist

### Step 1: Summarize What Was Done (1 min)

List the key accomplishments:
- Features implemented
- Bugs fixed
- Decisions made
- Problems solved

### Step 2: Capture Outstanding Items (1 min)

Document what's still pending:
- In-progress work (with current state)
- Blocked items (with blockers)
- Next steps identified during session

### Step 3: Note Key Decisions (30 sec)

Record any architectural or design decisions made:
- What was decided
- Why (brief rationale)
- Alternatives considered

### Step 4: Update Roadmap + Changelog (1 min)

If a roadmap exists:
- Mark completed items
- Add new items discovered
- Adjust priorities if needed

**Changelog maintenance (for projects with split roadmap/changelog):**
If the project has both a `ROADMAP-INFRA.md` (or similar active roadmap) and a `CHANGELOG.md`:
1. Scan the roadmap for any items completed this session
2. Remove completed items from the roadmap
3. Add them to `CHANGELOG.md` under a new session heading (or append to today's existing heading)
4. Format: `## Session N (YYYY-MM-DD) — Brief Theme` followed by `- [x] Item` lines

This keeps the roadmap clean (active items only) and the changelog as the historical record.

**Status-line trackers (for roadmaps that carry `> status:` or `> ws-status:` lines):**
If the repo's roadmap has entries with lines of the form
`> status: STAGE · prio: P · waiting on: WHO · next: ...` (any tracked level; `ws-status`
is a coarser workstream level and follows the same rules):
1. **Reconcile first.** If the tracker block names a mirror (e.g. a Notion database link
   in its header), fetch the mirror's rows BEFORE writing anything and diff them against
   the repo lines. A field that differs where the repo line was NOT touched this session
   is a mirror-side edit: adopt it into the repo line and note the adoption in the
   session log. A field where BOTH sides changed is a true conflict: show both values
   and ask, never silently pick. A mirror row with NO repo line is a new entry: adopt
   it as a new repo line. A repo line whose mirror row was deleted is a removal
   request: confirm before dropping the repo line (regenerating it unasked reverses a
   human's delete). Page PROSE around the databases belongs to the mirror side: never
   rewrite it during regeneration, and touch it only on an explicit ask, fetch-first.
2. Update the line for every activity this session touched (stage, prio, waiting-on,
   next; the allowed values are defined beside the lines in that roadmap).
3. Regenerate the mirror's rows from the now-reconciled lines: one row per entry, field
   for field, stamp today in the mirror's Updated field, and fetch the rows back to
   verify. The repo stays the arbiter and the record; the mirror is where teammates and
   you may edit between sessions.

### Step 5: Git Status Check

```bash
git status
```

**If uncommitted changes exist:**
1. List what's uncommitted
2. Ask user: "Want me to commit these changes before wrapping?"
3. If yes, create commit with session summary
4. If no, note that changes are intentionally uncommitted

This step covers the SESSION'S work product only. Do not push here — wrap-up artifacts (learnings, HANDOVER, session log) don't exist yet. Step 12 commits those and pushes everything, always last.

### Step 6: Extract Learnings (`/compound`)

Run the compound learning extraction. This reviews the session for:
- **Corrections**: Wrong assumptions, surprises, unexpected behavior
- **Patterns**: Approaches that worked well and should be reused
- **Decisions**: Design choices worth remembering the rationale for
- **Domain insights**: Facts about the world (not the tools) learned this session

For each learning:
1. Categorize it (correction / pattern / decision / domain)
2. Determine scope: project-local only, or also globally useful?
3. Append to this project's `learnings.md` using the typed format. **Read `~/.claude/references/learnings-format.md` first** unless you already have this session; it is lazy-loaded, not resident, so nothing else puts the format in context
4. If globally useful, also write a `learning_<slug>.md` topic file to `~/.claude/projects/<your-home-project>/memory/` AND its MEMORY.md index line (both, same turn — /compound has the enforcement details)

If the session was purely mechanical (applying known patterns, no new ground), skip this step. But check: "Did we discover anything about HOW to do this more effectively?" — that's a pattern worth capturing even if nothing went wrong.

### Step 6.25: File World Knowledge to the Brain Vault

/compound covers what changes Claude's behavior. This step covers what the user would read themselves. Ask:

- Did this session produce **research findings** (market facts, tool comparisons, dated snapshots)? → `brain/research/YYYY-MM-DD-slug.md`
- Did it settle a **cross-project or business-level decision** with non-obvious rationale? → append to `brain/decisions.md`
- Did it teach something about a **domain, org, or person** worth a wiki page update? → `brain/topics/` or `brain/people/`

Read `brain/CLAUDE.md` (the router) before writing; follow its frontmatter and filing test. When unsure where something goes, dump it to `brain/inbox/` rather than dropping it. If nothing qualifies, say so and move on — most coding sessions produce nothing for the vault, and that is fine.

### Step 6.5: Update Project Memory

Check the project's memory system at `~/.claude/projects/<escaped-project-path>/memory/`.

1. **If MEMORY.md exists**: Review it against what happened this session.
   - Any key facts that changed? (e.g., project status, phase, blockers resolved)
   - Any new gotchas discovered that should be in a topic file?
   - Any topic files now stale or wrong?
   - Update what's outdated. Don't bloat — if it's a one-off debugging detail, skip it.
2. **If MEMORY.md doesn't exist**: Create it now using `~/.claude/templates/MEMORY-TEMPLATE.md` as a starting point. Fill in Quick Reference and Key Facts from what you know.
3. **Quick staleness scan**: If any topic file content contradicts what you learned this session, fix it.

**Rule of thumb:** Only update memory with facts that would save time in a future session. Don't log transient state like "currently on branch X" — that's what git status is for.

4. **Commit memory changes.** `~/.claude` is a git repo and git history is the rollback story for bad memory edits. Scope the commit to memory paths only:

```bash
cd ~/.claude && git add projects/*/memory 2>/dev/null
git diff --cached --quiet || git commit -m "memory: session updates ($(basename "$CLAUDE_PROJECT_DIR" 2>/dev/null || echo session))"
```

This commits ALL projects' accumulated memory changes (not just this project's) — memory writes from other sessions pile up otherwise. Skip silently if nothing is staged. Do not add non-memory paths (settings, skills, plugins) — those need deliberate commits.

### Step 7: Session Workflow Audit + Skip Protocol

Review what skills were run vs. what should have been run:

```markdown
## Session Workflow Audit

### Skills Run
| Skill | Completed | Notes |
|-------|-----------|-------|
| /grill-me | ✅ | Extracted requirements for X |
| /pre-implement | ✅ | Planned feature X, pre-mortem verdict: proceed |
| /compound | ⚠️ Partial | Captured one learning |

### Skills Skipped (with reasons)
| Skill | Reason | Risk |
|-------|--------|------|
| /pre-implement | "Task was simple" | Monitor for unexpected failures |

### Anti-Pattern Check
- [ ] Any copy-paste without comprehension?
- [ ] Any debugging by mutation?
- [ ] Any happy path tunnel vision?
- [ ] Any skipped hardening?
```

**Skip Protocol for skipped skills:**
1. State risk: "Skipping X risks the Timer Feature pattern."
2. Was there justification? ("What makes this safe to skip?")
3. If justified, document the justification and risk in the session log.
4. Flag skipped skills as risks to monitor going forward.

**If any skills were skipped or anti-patterns detected, note them in the session log.**

### Step 7.5: Write HANDOVER.md

Write (overwrite) `HANDOVER.md` in the project root. This is the quick-read file the next session uses for immediate context. Keep it under 30 lines.

```markdown
# Handover

**Goal**: [What we were working on]

**Status**:
- [Done items]
- [In-progress items with current state]
- [Remaining items]

**Decisions made**:
- [Decision + why]

**What to avoid**:
- [Failed attempts, dead ends]

**Next step**:
- [Specific — the next session should be able to act on this without asking "what does that mean?"]
```

`/session-start` reads this file (Step 0.5) to bootstrap the next session — that's why it's load-bearing.

### Step 8: Architecture Decision Check

If significant technical decisions were made this session, ask:

> "Any architectural decisions worth a formal ADR?"

**When to create an ADR:**
- Decision affects project architecture or structure
- Sets precedent for future development
- Involves significant trade-offs
- Would be non-obvious to a future developer

**If yes**, create `docs/decisions/ADR-NNN-[slug].md`:

```markdown
# ADR-NNN: [Decision Title]

## Status
Accepted

## Context
[Why was this decision needed?]

## Decision
[What was decided?]

## Alternatives Considered
[What other options were evaluated?]

## Consequences
[Positive and negative implications]

## Date
YYYY-MM-DD
```

If no `docs/decisions/` folder exists, create it (or use `.claude/decisions/`).

---

### Step 9: Save Session Log File

**REQUIRED** - Write the session summary to the work-logs folder:

```markdown
# Session Log: YYYY-MM-DD

**Duration**: ~X hours
**Phase**: [Current project phase]

## Goals
- [What you set out to do]

## Accomplished
- [Completed item 1]
- [Completed item 2]

## Decisions Made
- **[Decision]**: [Rationale]

## Workflow Compliance
| Skill | Status | Notes |
|-------|--------|-------|
| /pre-implement | ✅ | [or ❌ with reason] |
| /grill-me | N/A | Requirements were clear |
| /compound | ✅ | |

### Skipped Skills (Risks to Monitor)
- /pre-implement (and its pre-mortem step) skipped: Monitor for [specific risk]

## Blockers
| Blocker | Status | Notes |
|---------|--------|-------|
| [Item] | [Status] | [Details] |

## Next Session
**Start with**: [Most important next task]
**Context needed**: [Any setup or reading]
**Risks from this session**: [Any skipped skills to revisit]

## Files Changed
- [file1] (new/updated)
- [file2] (updated)

## References
- [Relevant links]
```

### Step 10: Update Work-Logs README (if exists)

If `.claude/work-logs/README.md` exists:
- Add new session to "Recent Sessions" list
- Update "Quick Status Check" section

### Step 11: Sync Project-Root Docs (if big-enough change)

Check the project root for `README.md`, `CHANGELOG.md`, or `ROADMAP.md`. If any exist AND this session contains a "big-enough change," sync them.

**What counts as "big-enough"** (any one of these triggers a sync):
- New feature, mode, command, or top-level capability added
- Architecture or data-model change
- New entity onboarded (new person, new project, new integration, new env)
- New config file or major schema change
- Public API / CLI surface change (new flags, new endpoints)
- Folder structure reorganization
- Dependency added/removed/upgraded across major version
- Workflow or convention change a future reader needs to know

**What does NOT trigger** (skip the sync):
- Bug fixes localized to one file
- Test additions only
- Comment/docstring edits
- Internal refactor with no API change
- Single-line config tweaks
- Typo fixes

**How to sync:**

1. Decide trigger: review the session's "Files Changed" list and "Accomplishments" against the big-enough rubric above. If unsure, ask the user: *"Big-enough change for README/docs sync? (y/n)"*
2. If yes, check each doc for freshness and update it inline:
   - **README.md**: update relevant sections (Quick Start, structure, profiles, gotchas) to reflect the change. Bump the "Last updated" footer.
   - **CHANGELOG.md**: add an entry under today's date in conventional format.
   - **ROADMAP.md**: mark items shipped, surface new follow-ups, update "in progress" section.
3. Show the user the diff before saving.
4. If no trigger, log it: *"Skipped doc sync, change too small."* in the wrap-up output.

This step keeps human-facing docs current as part of every wrap-up; there is no separate doc-sync skill to run.

### Step 12: Final Commit + Push (always last; added 2026-07-13)

Nothing this skill wrote may be left uncommitted. After Steps 6-11:

1. **Commit the wrap-up artifacts** in the project repo: `learnings.md`, `HANDOVER.md`, the session log, any README/CHANGELOG/ROADMAP edits from Step 11. Conventional message, e.g. `wrap-up: session log, learnings, fresh HANDOVER (<theme>)`.
2. **Commit any brain vault writes** from Step 6.25 (`git -C ~/Documents/projects/brain add -A && commit`).
3. **Push every repo this session committed to** (project repo, brain, ~/.claude), IF the current branch already tracks a remote (`git rev-parse --abbrev-ref @{u}` succeeds). This is the off-machine backup step — solo doc repos (home, brain, claude-config) otherwise accumulate local-only history.

Push guardrails:
- Plain `git push` only. Never `--force`, never merge, never create remotes, branches, or upstreams.
- Code repos on a feature branch: push the feature branch; the PR flow stays manual per git-workflow.md.
- No upstream configured, or push fails (auth, network)? Note it in the session log and move on — never block the wrap.
- Verify with `git status -sb` per repo: each should read `## main...origin/main` with no ahead/behind marker (or the feature-branch equivalent).

---

## Output Format (to screen)

After saving the file, display a summary:

```markdown
## Session Wrap-Up: [Project Name]

**Date**: YYYY-MM-DD
**Saved to**: .claude/work-logs/YYYY-MM/YYYY-MM-DD_session-NN.md

### Accomplished
- [Completed item 1]
- [Completed item 2]

### Next Session
**Start with**: [Most important next task]

### Git Status
- Branch: `main`
- Uncommitted: Yes/No
- Committed this session: [commit hash if applicable]
```

---

## Integration with Other Skills

| Before Wrap-Up | Consider Running |
|----------------|------------------|
| Code changes | Commit first, or wrap-up will offer |

Note: README/CHANGELOG/ROADMAP freshness is handled inline by Step 11 when a big-enough change is detected. No separate skill to run.

**Note:** This skill does NOT auto-commit project code — it asks first (Step 5). The one exception is `~/.claude` memory paths (Step 6.5.4), which commit automatically because they're Claude-curated state, not user work product.

---

## Quick Mode

If in a rush, still save a minimal log file:

```markdown
# Session Log: YYYY-MM-DD

**Done**: [1 sentence]
**Next**: [1 sentence]
**Blockers**: [None / brief description]
```

---

## Tips

- **Be specific**: "Fixed auth bug" → "Fixed token refresh loop in useAuth hook"
- **Capture context**: Future you won't remember why you stopped mid-task
- **Note blockers**: If stuck, document exactly where and why
- **Always save**: Even quick sessions deserve a log entry
- **Check git**: Don't leave uncommitted work overnight without intention
