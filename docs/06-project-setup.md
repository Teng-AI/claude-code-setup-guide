# Project Setup

Every project you use with Claude Code benefits from a small amount of upfront configuration. This section covers the key files -- per-project `CLAUDE.md` and `learnings.md` -- along with templates, references, and a checklist for getting a new project ready.

## Per-Project CLAUDE.md

**Location:** `{project-root}/.claude/CLAUDE.md`

While your global `CLAUDE.md` at `~/.claude/CLAUDE.md` holds personal preferences and workflow rules that apply everywhere, the per-project `CLAUDE.md` holds context specific to one codebase. Claude reads both at conversation start, with the project-level file layering on top of the global one.

### What to Include

- **Project description.** One paragraph on what this project does and who it is for.
- **Tech stack.** Frameworks, languages, databases, and major libraries in use.
- **Key commands.** Build, test, lint, deploy, and other frequent operations.
- **Architecture overview.** High-level structure: where code lives, how services communicate, data flow.
- **Coding conventions.** Project-specific rules like "use named exports" or "all API responses follow this shape."
- **Team-specific rules.** PR review process, branch naming, commit message format, deployment gates.

Do not repeat anything from your global `CLAUDE.md`. Duplication creates drift.

### Example Structure

```markdown
# Project Name

## Overview

[One paragraph describing what this project does and who uses it.]

## Tech Stack

- Frontend: [framework]
- Backend: [framework]
- Database: [database]
- Hosting: [platform]

## Commands

- `npm run dev` -- start dev server
- `npm test` -- run tests
- `npm run build` -- production build
- `npm run lint` -- run linter
- `npm run deploy` -- deploy to staging

## Architecture

[Key architectural decisions and patterns.]

## Conventions

[Project-specific coding rules.]
```

Keep it to one page. If it is longer than a single screen, it probably includes things that belong elsewhere.

## learnings.md

**Location:** `{project-root}/learnings.md`

An append-only log of corrections and discoveries specific to one project. When Claude makes a wrong assumption and you correct it, that correction gets recorded here so it is not repeated in future sessions. Claude reads it at session start. If the file does not exist when Claude needs to record a correction, it creates it automatically.

### Format

```markdown
## [YYYY-MM-DD] Short title

**Wrong assumption:** What you thought was true
**Reality:** What's actually true
**Impact:** How this changes future work
```

One learning per block, 3-4 lines each, append only.

## Templates

**Location:** `~/.claude/templates/`

Templates are reusable document formats that Claude follows when creating PRs, documentation, or other structured output. Claude checks this directory for a matching template when generating structured documents and follows it instead of improvising a format.

### Example: Pull Request Template

The most common template is a PR template that covers summary, type of change, self-review checklist, testing notes, and PR hygiene. A good PR template keeps reviews focused and ensures nothing gets missed.

See [`../examples/PULL_REQUEST_TEMPLATE.md`](../examples/PULL_REQUEST_TEMPLATE.md) for a complete PR template.

### How to Add Your Own Templates

Create a `.md` file in `~/.claude/templates/` with a descriptive name (e.g., `DESIGN_DOC_TEMPLATE.md`). Use placeholder text in brackets to indicate where Claude should fill in content. No registration step is needed -- any `.md` file in the directory is available automatically.

## References

**Location:** `~/.claude/references/`

References are domain-specific documentation files that Claude can consult when working on related tasks. They fill the gap between Claude's general knowledge and the specific gotchas and patterns that matter for your stack.

### Example: Firebase Realtime Database Reference

A file like `firebase-rtdb.md` might cover:

- **`set()` vs `update()`** -- `set()` replaces the entire node, while `update()` merges at the top level only. Nested objects within an `update()` call still replace entirely, which surprises most people.
- **Transactions** -- `transaction()` can run multiple times if there is a conflict. Your transaction function must be pure (no side effects) because Firebase may retry it.
- **Offline capabilities** -- Firebase queues writes locally and syncs when reconnected. This means `set()` calls "succeed" immediately even when offline, which can mask connectivity issues.
- **Security rules** -- Rules cascade. A `read: true` at a parent node grants read access to all children, and there is no way to revoke it at a deeper path.

### When to Create a Reference

Create a reference when:

- A technology has non-obvious gotchas (like the Firebase nested update behavior above).
- You have accumulated hard-won knowledge about an API that is not well-documented or frequently misunderstood.
- You find yourself repeatedly correcting Claude about the same technology-specific detail.

Do not create a reference for general documentation Claude already knows, information that changes frequently, or project-specific patterns that belong in `CLAUDE.md`.

When writing references, lead with the gotchas, include code examples for tricky patterns, and keep it concise -- a reference is a cheat sheet, not a tutorial. Update it as you encounter new edge cases.

### How to Add Your Own References

Create a `.md` file in `~/.claude/references/` named after the technology (e.g., `stripe-webhooks.md`). Focus on gotchas, common errors, and patterns -- assume Claude already knows the basics.

## Project-Level Hooks

Some workflow reminders only make sense in specific projects. For example, a Firebase/state-audit reminder would be noisy in a project that does not use Firebase. Place these in `{project}/.claude/settings.json` instead of the global settings.

Example: a project-level UserPromptSubmit hook that reminds about `/state-audit` when Firebase or sync keywords appear:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "prompt=$(echo \"$USER_PROMPT\" | tr '[:upper:]' '[:lower:]'); if echo \"$prompt\" | grep -qE 'firebase|firestore|realtime|sync|real-time|websocket|state.?manag'; then echo 'State/sync work detected. Consider running /state-audit before implementing.'; fi; exit 0"
          }
        ]
      }
    ]
  }
}
```

Keep hookify rule templates in `~/.claude/templates/hookify/` and copy them into new projects during scaffolding.

## Project Setup Checklist

- [ ] `.claude/CLAUDE.md` with project context (start here -- highest impact)
- [ ] `learnings.md` for correction tracking (can start empty)
- [ ] Pre-commit hooks (Husky + linter/type checker at minimum)
- [ ] `ROADMAP.md` or `FUTURE_FEATURES.md` for priorities
- [ ] `CHANGELOG.md` for notable changes
- [ ] GitHub Actions CI for tests, linting, and builds
- [ ] Project-level hooks copied from `~/.claude/templates/hookify/` (if applicable)

Start with `CLAUDE.md` and `learnings.md`, then add the rest as the project matures.
