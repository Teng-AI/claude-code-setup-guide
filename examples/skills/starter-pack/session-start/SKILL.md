---
name: session-start
description: Standardized session kickoff routine. Run at the start of each coding session to understand project state, check for issues, and pick the right task.
---

# Session Start

A quick orientation routine to run at the beginning of each coding session. Gets you up to speed and focused in under 5 minutes.

## When to Use

Run `/session-start` when:
- Starting a new coding session
- Returning to a project after a break
- Switching between projects
- Unsure what to work on next

## The Session Start Checklist

### Step 0: Check Memory (15 seconds)

Before anything else, check if this project has a memory system:

1. **Find the project's memory directory**: `~/.claude/projects/<escaped-project-path>/memory/`
   - The escaped path replaces `/` with `-` (e.g., `-Users-jane-Documents-projects-myapp`)
2. **If MEMORY.md exists**: Read it. Skim topic files for staleness.
   - If any topic file hasn't been updated in 30+ days and the project is active, flag: "Memory may be stale — review after session"
3. **If MEMORY.md does NOT exist**: Bootstrap it.
   - Read the project's CLAUDE.md (or README.md if no CLAUDE.md)
   - Create the memory directory and a MEMORY.md using the template at `~/.claude/templates/MEMORY-TEMPLATE.md`
   - Fill in Quick Reference (test/dev/deploy commands) and Key Facts from what you can learn from the codebase
   - Add 1-3 topic files if the project has enough complexity (architecture, gotchas, etc.)
   - Tell the user: "Created memory for this project. Review and correct anything wrong."
4. **Also check**: Does `learnings.md` exist in the project root? If not and this is an active project, create an empty one with the standard header.
5. **Scan learnings.md**: Read this project's `learnings.md`. Note entries from the last 30 days — these are "hot" learnings most likely to be relevant. Hold them for Step 0.75.

### Step 0.5: Read Handover (10 seconds)

Check for `HANDOVER.md` in the project root:
- **If it exists**: Read it. This is the previous session's state — what was done, what's next, what to avoid.
- Display key points under a "Last Session" heading in the output.
- This file is written by `/wrap-up`, so it reflects the last properly-closed session.
- If it's missing, the previous session ended without `/wrap-up` — fall back to recent commits and `.claude/work-logs/` for context.
- If it's clearly stale (references work that's already been completed per git log), note that.

### Step 0.75: Surface Relevant Learnings (15 seconds)

Match past learnings to the current session's likely work:

1. **Identify the task**: From HANDOVER.md "Next step", or from the user's opening message.
2. **Check project learnings**: Scan this project's `learnings.md` for entries relevant to the task. Match by keywords, technology, or domain. Prioritize entries from the last 30 days.
3. **Check global learnings**: Read the home project memory index at `~/.claude/projects/<your-home-project>/memory/MEMORY.md`. Scan any `learning_*` topic files whose names or descriptions match the current task's domain.
4. **Check other project learnings** (lightweight): If the task involves a technology that another project has learnings about, the global `learning_*` topic files are the cross-project bridge — don't read every project's learnings.md directly.

**Output (under a "Relevant Learnings" heading):**
- List 0-3 most relevant past learnings, one-line summary each
- If none are relevant, omit this section entirely
- Format: `- [type] from [source]: [one-line summary]`

**Example:**
```
### Relevant Learnings
- [pattern] from client-project: Notion API needs direct curl for headings/callouts — MCP only supports paragraphs and bullets
- [correction] from this project: Bot improvises to "fix" missing state — use explicit negative instructions
```

This step is read-only — it surfaces, it doesn't create or modify anything.

### Step 1: Orient (30 seconds)

Identify the project context:

```bash
# What project am I in?
pwd
git remote -v

# What branch am I on?
git branch --show-current

# Any uncommitted work?
git status
```

### Step 2: Check Project Health (1 minute)

Quick health checks:

1. **Tests passing?**
   ```bash
   npm test 2>&1 | tail -20
   ```

2. **Build working?**
   ```bash
   npm run build 2>&1 | tail -10
   ```

3. **Any lint errors?**
   ```bash
   npm run lint 2>&1 | tail -10
   ```

If any of these fail, **fix them first** before starting new work.

### Step 3: Check for Missing Protections (30 seconds)

Quick flags for project maturity:

| Check | Command | Flag If Missing |
|-------|---------|-----------------|
| Has CI? | `.github/workflows/` exists | "Consider adding CI" |
| Has branch protection? | `gh repo view --json defaultBranchRef` | "Consider enabling branch protection on main" |
| Has tests? | `find . -name "*.test.*"` | "Add test coverage" |

Only flag, don't block. These are reminders, not blockers.

### Step 4: Review Context (2 minutes)

Check what needs to be done:

1. **Project roadmap** (if exists)
   ```bash
   # Check for roadmap files
   cat ROADMAP.md 2>/dev/null || cat FUTURE_FEATURES.md 2>/dev/null || echo "No roadmap found"
   ```

2. **Recent work logs** (if exists)
   ```bash
   # Check for recent session logs
   ls -la .claude/work-logs/ 2>/dev/null | tail -5
   ```

3. **Open issues/PRs**
   ```bash
   gh issue list --limit 5
   gh pr list --limit 5
   ```

4. **Recent commits** (what was last worked on)
   ```bash
   git log --oneline -5
   ```

### Step 5: Pick a Task (1 minute)

Based on the context gathered, suggest:

1. **Fix first**: Any failing tests, build errors, or lint issues
2. **Continue**: Incomplete work from last session (check git status, work logs)
3. **Next up**: High priority items from roadmap/issues
4. **Quick wins**: Small tasks that can be done in <30 min

## Output Format

```markdown
## Session Start: [Project Name]

### Memory
- **MEMORY.md**: Found / Created / Missing
- **Topic files**: 3 loaded
- **Staleness**: OK / "architecture.md not updated in 45 days"

### Relevant Learnings (from Step 0.75)
- [type] from [source]: [one-line summary]
- *(or omit section if nothing relevant)*

### Last Session (from HANDOVER.md)
- **Goal**: [What was being worked on]
- **Status**: [Where it left off]
- **Next step**: [What the previous session said to do next]
- *(or "No HANDOVER.md found" if missing)*

### Project State
- **Branch**: `feature/xyz`
- **Uncommitted changes**: Yes/No
- **Tests**: Passing / X failing
- **Build**: Passing / Failing

### Flags
- [ ] No branch protection (enable on GitHub when ready)
- [ ] No CI pipeline
- [x] Tests exist

### Recent Context
- **Last commit**: "feat: add user login" (2 days ago)
- **Open PRs**: 1 - "Add dashboard feature"
- **Open issues**: 3

### Suggested Focus

**Immediate** (fix first):
- [ ] Fix 2 failing tests in `auth.test.ts`

**Continue** (from last session):
- [ ] Complete dashboard feature (PR #12)

**Next up** (from roadmap):
- [ ] Add user settings page
- [ ] Implement password reset
```

## Quick Mode

If you're in a hurry, run just the essentials:

```bash
git status && npm test
```

This tells you:
1. Where you left off (uncommitted changes)
2. If everything still works (tests pass)

## Next Step

Pick your task, then run `/pre-implement` if it's non-trivial (>30 min, multi-file, or unclear).

## Integration with Other Skills

| After Session Start | Run If... |
|---------------------|-----------|
| `/notion-review` | Deciding what to work on across projects |
| `/pre-implement` | Starting a non-trivial task |

## Tips

- **Keep a work log**: End each session with notes on what you did and what's next
- **Commit before switching**: Don't leave uncommitted changes when switching projects
- **Trust the process**: 5 minutes of orientation saves hours of confusion

## Skip When

- Quick one-off fixes (typos, hotfixes)
- You were literally just working on this project
- Emergency production issues (fix first, orient later)
