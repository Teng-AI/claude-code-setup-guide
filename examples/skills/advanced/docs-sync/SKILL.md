---
name: docs-sync
description: Unified documentation sync. Checks README, CHANGELOG, and ROADMAP against code changes. Run before commits to keep docs current. Use "deep" mode for thorough consistency checking across all docs.
---

# Documentation Sync

Keep documentation in sync with code. Run before commits or periodically for maintenance.

## Quick Reference

```
/docs-sync         → Quick sync (pre-commit)
/docs-sync deep    → Deep consistency check (periodic)
/docs-sync ship    → Sync docs + commit + push (checkpoint)
```

## When to Use

**Quick Mode (default):**
- Before committing
- After completing a feature
- When you've changed public APIs

**Deep Mode:**
- Before releases
- When docs might be stale
- After major refactors
- Periodically as maintenance

**Skip for:**
- Typo fixes
- Test-only changes
- Internal refactors

## Quick Mode Workflow

### Step 1: Check What Changed

```bash
git diff --name-only HEAD
git diff --cached --name-only
```

Identify:
- New files/directories → Update README structure
- Config changes (.env, etc.) → Update environment docs
- New dependencies → Update installation instructions
- API changes → Update API docs

### Step 2: Check Documentation Files

Find and review:
- `README.md` - Setup, features, structure
- `CHANGELOG.md` - Version history
- `ROADMAP.md` / `FUTURE_FEATURES.md` - Task tracking

### Step 3: Update Each File

#### README.md
- [ ] Setup instructions still accurate?
- [ ] Feature list matches implementation?
- [ ] Project structure matches reality?
- [ ] Environment variables documented?

#### CHANGELOG.md
Add entries under `[Unreleased]`:
- **Added**: New features
- **Changed**: Changes to existing functionality
- **Fixed**: Bug fixes
- **Removed**: Removed features

#### ROADMAP.md
- [ ] Move completed items to "Done"
- [ ] Add new items discovered during work
- [ ] Adjust priorities if needed

### Step 4: Report

```markdown
## Docs Sync Summary

### README
- ✅ Up to date (or list updates made)

### CHANGELOG
- Added: [entry]
- Fixed: [entry]

### ROADMAP
- Completed: [item]
- Added: [new item]

### Ready to Commit
All documentation synced!
```

## Ship Mode Workflow

Sync docs, commit, and push in one step. Use as a checkpoint after completing work.

### Step 1: Run Quick Mode (Steps 1-3 above)

Sync all documentation first — CHANGELOG, ROADMAP, README as needed.

### Step 2: Stage and Commit

```bash
git status
git diff --stat
git log --oneline -3
```

- Stage changed files by name (not `git add -A`)
- Do NOT stage files that likely contain secrets (.env, credentials, etc.)
- Write a concise commit message summarizing the changes (follow repo's commit style)
- End with `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
- Use a HEREDOC for the commit message

### Step 3: Push

```bash
git push
```

- If push fails (no remote, protected branch, etc.), report the error but keep the commit
- Do NOT force push

### Step 4: Report

```markdown
## Docs Ship Summary

### Docs Updated
- [list of doc changes]

### Committed & Pushed
- Commit: `abc1234`
- Branch: `main`
- Files: N changed

### Status: Shipped
```

## Deep Mode Workflow

For thorough consistency checking when docs may have drifted.

### Step 1: Find All Documentation

```bash
find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*"
```

### Step 2: Find Source of Truth

```bash
# Type definitions
find . -name "types*.ts" -o -name "*.d.ts"

# Configuration
find . -name "config.*"
```

### Step 3: Check for Discrepancies

| Check | What to Look For |
|-------|------------------|
| Type names | Doc uses old term, code uses new |
| Function signatures | Doc shows outdated parameters |
| Config values | Doc shows deprecated options |
| File paths | Doc references moved/deleted files |
| Constants/enums | Doc lists values that don't exist |

### Step 4: Report Discrepancies

```markdown
## Consistency Report

### Discrepancies Found

#### 1. [Category]
- **Location**: file.md:42
- **Doc says**: "old_value"
- **Code has**: "new_value"
- **Fix**: Replace "old_value" with "new_value"

### Files to Update
1. [file1.md] - 3 fixes needed
2. [file2.md] - 1 fix needed
```

### Step 5: Apply Fixes

For each discrepancy:
1. Show the exact change
2. Ask for confirmation
3. Apply the fix

## Common Patterns

### Pattern 1: Renamed Concept
```
Doc: "Each player has 4 flower tiles"
Code: type Category = 'dragon'  // was 'flower'
Fix: Find/replace in all docs
```

### Pattern 2: New Feature, No Docs
```
Code: export function newFeature() { ... }
Docs: (not mentioned)
Fix: Add documentation for new feature
```

### Pattern 3: Deleted Feature, Stale Docs
```
Code: // removed oldFeature()
Docs: "Use oldFeature() to..."
Fix: Remove or update stale references
```

## Output Format

```markdown
## Docs Sync: [Project Name]

**Mode**: Quick / Deep
**Files Checked**: X

### Changes Made
- [x] Updated README project structure
- [x] Added CHANGELOG entry for new feature
- [x] Marked roadmap item complete

### Discrepancies Fixed
| File | Issue | Status |
|------|-------|--------|
| README.md | Added new env var | ✅ Fixed |

### Manual Review Needed
- [ ] [Item requiring human decision]

### Status: Ready to Commit
```

## Best Practices

1. **Run before every commit** - Quick mode takes <1 minute
2. **Code is source of truth** - Docs follow code, not vice versa
3. **Fix immediately** - Stale docs compound quickly
4. **Deep check monthly** - Catch drift before it gets bad

## Next Step

Ready to commit. Deploying? Run `/pre-ship` first.

## Integration

```
After implementation → /docs-sync (quick)
Before release      → /docs-sync deep
Checkpoint          → /docs-sync ship
```
