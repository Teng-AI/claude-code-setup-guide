---
name: git-workflow
description: Handle git operations including commits, branches, and pull requests. Use when the user asks to commit, create a PR, manage branches, or follow git best practices.
---

# Git Workflow

Standard git operations with consistent conventions.

## Commit Messages

Follow conventional commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change that neither fixes nor adds
- `perf`: Performance improvement
- `test`: Adding/updating tests
- `chore`: Maintenance tasks

### Examples
```
feat(auth): add OAuth2 login with Google
fix(cart): prevent negative quantity values
refactor(api): extract validation into middleware
```

## Branch Naming

```
<type>/<ticket-id>-<short-description>
```

Examples:
- `feat/ABC-123-user-authentication`
- `fix/ABC-456-cart-total-calculation`
- `chore/update-dependencies`

## Pull Request Template

```markdown
## Summary
[1-3 bullet points describing what this PR does]

## Changes
- [List of specific changes]

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] Edge cases considered

## Screenshots (if UI changes)
[Before/After if applicable]
```

## Common Operations

### Starting new work
```bash
git checkout main && git pull
git checkout -b feat/description
```

### Preparing to commit
```bash
git status
git diff --staged
git add -p  # Stage interactively
```

### Keeping branch updated
```bash
git fetch origin
git rebase origin/main
```

## Guidelines
- Commit early and often with atomic changes
- Never force push to shared branches
- Squash fixup commits before merging
- Write commit messages for future readers
