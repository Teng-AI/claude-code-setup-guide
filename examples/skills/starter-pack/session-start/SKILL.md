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
| Has branch protection? | `gh repo view --json defaultBranchRef` | "Run `/architecture-review` to set up" |
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

### Project State
- **Branch**: `feature/xyz`
- **Uncommitted changes**: Yes/No
- **Tests**: Passing / X failing
- **Build**: Passing / Failing

### Flags
- [ ] No branch protection (run `/architecture-review` when ready)
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

## Integration with Other Skills

| After Session Start | Run If... |
|---------------------|-----------|
| `/pre-implement` | Starting a non-trivial task |
| `/architecture-review` | Flags show missing protections |
| `/tests` | Tests are sparse or failing |

## Tips

- **Keep a work log**: End each session with notes on what you did and what's next
- **Commit before switching**: Don't leave uncommitted changes when switching projects
- **Trust the process**: 5 minutes of orientation saves hours of confusion

## Skip When

- Quick one-off fixes (typos, hotfixes)
- You were literally just working on this project
- Emergency production issues (fix first, orient later)
