---
name: architecture-review
description: Periodic codebase health check. Reviews project structure, dependencies, code patterns, and infrastructure. Identifies tech debt and recommends improvements including branch protection and CI setup. Use when user says "review the architecture", "is this codebase healthy", "check for tech debt", "what should I refactor", or periodically for maintenance.
---

# Architecture Review

A comprehensive health check for your codebase. Run periodically to catch tech debt early and ensure best practices are in place.

## When to Use

- Starting work on an inherited codebase
- Quarterly health check on active projects
- Before major refactoring
- When `/session-start` flags missing protections
- After significant feature additions

## The Review Checklist

### 1. Project Structure Analysis

Check how the codebase is organized:

```bash
# Get directory structure (depth 3)
find . -type d -not -path '*/node_modules/*' -not -path '*/.git/*' | head -30

# Count files by type
find . -type f -not -path '*/node_modules/*' | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10
```

**Evaluate:**
- [ ] Clear separation of concerns (components, utils, hooks, etc.)
- [ ] Consistent naming conventions
- [ ] No deeply nested folders (>4 levels is a smell)
- [ ] Test files colocated or in dedicated `__tests__` folder

### 2. Dependency Health

Check package.json and dependencies:

```bash
# Check for outdated packages
npm outdated 2>/dev/null | head -20

# Check for security vulnerabilities
npm audit 2>/dev/null | tail -20

# Count dependencies
jq '.dependencies | length' package.json 2>/dev/null
jq '.devDependencies | length' package.json 2>/dev/null
```

**Evaluate:**
- [ ] No critically outdated dependencies (major versions behind)
- [ ] No known security vulnerabilities
- [ ] Reasonable number of dependencies (<50 production deps)
- [ ] Dev dependencies properly separated

### 3. Code Quality Indicators

Look for common code smells:

```bash
# Large files (>500 lines)
find . -name "*.ts" -o -name "*.tsx" | xargs wc -l 2>/dev/null | sort -rn | head -10

# TODO/FIXME comments
grep -r "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" . 2>/dev/null | wc -l

# Console.log statements (should be minimal in production code)
grep -r "console.log" --include="*.ts" --include="*.tsx" . 2>/dev/null | wc -l

# Any files (type checking disabled)
grep -r ": any" --include="*.ts" --include="*.tsx" . 2>/dev/null | wc -l
```

**Evaluate:**
- [ ] No files >500 lines (should be split)
- [ ] TODOs are tracked in issues, not just comments
- [ ] Minimal console.log in production code
- [ ] Minimal use of `any` type

### 4. Test Coverage

Assess testing health:

```bash
# Test file count
find . -name "*.test.*" -o -name "*.spec.*" | wc -l

# Source file count (excluding tests)
find . -name "*.ts" -o -name "*.tsx" | grep -v test | grep -v spec | wc -l

# Run tests with coverage if available
npm test -- --coverage 2>/dev/null | tail -20
```

**Evaluate:**
- [ ] Test files exist for critical paths
- [ ] Coverage >50% on core business logic
- [ ] Tests are actually running in CI

### 5. Infrastructure & Process Maturity

Check project infrastructure:

| Check | How | Recommended Action |
|-------|-----|-------------------|
| **Git hooks** | `ls .husky/` or `cat package.json \| grep husky` | Add pre-commit hooks |
| **CI/CD** | `ls .github/workflows/` | Add GitHub Actions |
| **Branch protection** | `gh repo view --json defaultBranchRef,branchProtectionRules` | Enable protection |
| **PR template** | `ls .github/PULL_REQUEST_TEMPLATE.md` | Add template |
| **Linting** | `cat package.json \| grep eslint` | Add ESLint config |
| **Type checking** | `cat tsconfig.json` | Enable strict mode |

## Branch Protection Setup

If branch protection is missing and the project meets criteria:

### When to Add Branch Protection

Add branch protection when ANY of these are true:
- Project is deployed to production
- Repository is public
- Has CI/CD pipeline configured
- Multiple contributors

### How to Enable

**Option 1: GitHub CLI (Recommended)**

```bash
# Enable basic protection on main branch
gh api repos/{owner}/{repo}/branches/main/protection -X PUT \
  -H "Accept: application/vnd.github+json" \
  -f "required_status_checks[strict]=true" \
  -f "required_status_checks[contexts][]=test" \
  -f "enforce_admins=false" \
  -f "required_pull_request_reviews[required_approving_review_count]=0" \
  -f "restrictions=null"
```

**Option 2: GitHub Web UI**

1. Go to repo Settings > Branches
2. Add rule for `main` branch
3. Enable:
   - [x] Require status checks to pass
   - [x] Require branches to be up to date
   - [ ] Require pull request reviews (optional for solo dev)

### Recommended Settings for Solo Developer

| Setting | Value | Reason |
|---------|-------|--------|
| Require status checks | Yes | Prevents broken merges |
| Require up-to-date branches | Yes | Catches integration issues |
| Require PR reviews | No | Solo dev doesn't need self-review |
| Include administrators | No | You need escape hatch for emergencies |

## Output Format

```markdown
## Architecture Review: [Project Name]

**Review Date**: YYYY-MM-DD
**Overall Health**: Good / Needs Attention / Critical

### Structure
- **Organization**: [Good/Fair/Poor] - [Notes]
- **File sizes**: [X files over 500 lines]
- **Nesting depth**: [Max depth found]

### Dependencies
- **Total**: X production, Y dev
- **Outdated**: X packages
- **Vulnerabilities**: X critical, Y high, Z moderate

### Code Quality
- **TODO/FIXME count**: X
- **Console.log count**: X (should be 0 in production)
- **Any types**: X occurrences

### Test Coverage
- **Test files**: X
- **Source files**: Y
- **Ratio**: X/Y (Z%)
- **Coverage**: [X% if available]

### Infrastructure
| Component | Status | Action |
|-----------|--------|--------|
| CI/CD | Present/Missing | [Action if missing] |
| Branch protection | Present/Missing | [Action if missing] |
| Pre-commit hooks | Present/Missing | [Action if missing] |
| PR template | Present/Missing | [Action if missing] |
| Linting | Present/Missing | [Action if missing] |

### Priority Actions

**Critical** (do now):
1. [Action item]

**High** (this week):
1. [Action item]

**Medium** (this month):
1. [Action item]

### Commands to Run

```bash
# Set up branch protection
gh api repos/{owner}/{repo}/branches/main/protection -X PUT ...

# Add missing PR template
mkdir -p .github && cat > .github/PULL_REQUEST_TEMPLATE.md << 'EOF'
...
EOF

# Fix vulnerabilities
npm audit fix
```
```

## Quick Review Mode

For a fast check, focus on:

1. `npm audit` - Security issues
2. `npm test` - Tests passing
3. `gh repo view` - Branch protection status

## Maintenance Schedule

| Frequency | What to Check |
|-----------|---------------|
| Every session | Tests pass, no new lint errors |
| Weekly | Outdated dependencies |
| Monthly | Full architecture review |
| Quarterly | Deep dependency audit, refactoring assessment |

## Integration with Other Skills

| This Skill Found | Run Next |
|------------------|----------|
| Low test coverage | `/tests` |
| Complex implementation needed | `/pre-implement` |
| Documentation gaps | `/docs` |
