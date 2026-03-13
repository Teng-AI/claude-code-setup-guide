---
name: docs
description: Sync documentation with code changes
---

# /docs - Documentation Sync

When invoked, ensure documentation matches the current state of the code. Update existing docs. Do not create new documentation unless there is a clear gap.

## Steps

### 1. Identify What Changed

- Run `git diff` (staged and unstaged) to see current changes.
- Run `git diff HEAD~1` if a recent commit was just made.
- List the files and functions that changed.
- Categorize: new feature, changed behavior, removed feature, config change, API change.

### 2. Identify Affected Documentation

Check each of these and note which ones need updates:

| Doc Type | Where to Look | Update When |
|----------|--------------|-------------|
| README | Project root | Setup steps, usage, or architecture changed |
| API docs | Inline JSDoc/docstrings, OpenAPI specs | Function signatures, endpoints, params changed |
| Code comments | In changed files | Logic changed but comment still describes old behavior |
| CHANGELOG | Project root | Any user-facing change |
| Config docs | .env.example, config READMEs | New env vars, changed defaults |
| Type definitions | .d.ts, interfaces | Types changed |

### 3. Update Each Affected Doc

**README updates:**
- Keep it concise. Don't add sections that duplicate code comments.
- Update setup instructions only if dependencies or steps changed.
- Update usage examples only if the API or CLI interface changed.

**Code comment updates:**
- Remove comments that describe WHAT the code does (the code should be readable).
- Keep comments that describe WHY -- business rules, non-obvious decisions, workarounds.
- Delete stale comments that describe old behavior. A wrong comment is worse than no comment.

**CHANGELOG updates:**
- Use Keep a Changelog format if the project already uses it.
- Categorize: Added, Changed, Deprecated, Removed, Fixed, Security.
- Write entries from the user's perspective, not the developer's.

**API documentation:**
- Update function/method docstrings when signatures change.
- Update parameter descriptions when behavior changes.
- Add @deprecated tags rather than silently removing docs for old APIs.

### 4. Verify Accuracy

- Read each updated doc section and confirm it matches the actual code behavior.
- Check for broken links or references to renamed files/functions.
- If docs reference example output, verify the examples are still correct.

### 5. Stage Doc Changes

- Stage documentation changes alongside the code changes they relate to.
- Documentation and code should be in the same commit so they stay in sync.

## Rules

- **Never create docs that aren't needed.** A codebase with no README is better than one with a misleading README.
- **Update existing docs first.** Don't add a new ARCHITECTURE.md when the README already has an architecture section.
- **Delete stale docs.** Outdated documentation is actively harmful.
- **Don't document the obvious.** If the code is clear, a comment adds noise.
- **Match the project's existing style.** If the README is minimal, keep it minimal. If it's detailed, be detailed.

## Output Format

```
## Documentation Updates

### Updated
- [file]: [what was updated and why]

### No Update Needed
- [file]: [why it's still accurate]

### Created (if any)
- [file]: [justification for why a new doc was necessary]

### Deleted (if any)
- [file]: [why it was removed -- stale, misleading, duplicated]
```
