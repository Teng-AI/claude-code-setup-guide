# Memory System

## What Memory Is

Claude Code has a persistent, file-based memory system that lets it remember things across conversations. When you tell Claude something important -- your role, your preferences, a correction, an ongoing project constraint -- it can store that information in a memory file and retrieve it automatically in future sessions.

Memory is designed for durable context: things that are true across multiple conversations and that Claude cannot infer from the codebase alone.

## What Memory Is NOT

- **Not for ephemeral task details.** If something only matters for the current conversation, it does not belong in memory.
- **Not for things derivable from code.** If Claude can figure it out by reading your source files, tests, or git history, it should not be in memory. Storing redundant information creates staleness risk.
- **Not for things already in CLAUDE.md.** Memory and CLAUDE.md serve different purposes. Do not duplicate between them.

## Memory Location

- **Project-specific memory:** `~/.claude/projects/{project-path}/memory/`
  Scoped to one project, only loaded when working in that project's directory.
- **Global memory:** `~/.claude/memory/`
  Applies across all projects. Use for general preferences, role, or communication style.

Each memory directory contains a `MEMORY.md` file that serves as an index. Claude reads it automatically at conversation start. You do not need to maintain it manually.

## Memory Types

There are four types of memory, each serving a distinct purpose.

### 1. User

Information about you: role, expertise level, preferences, working style. Helps Claude tailor responses.

**Examples:**
- "I'm a backend engineer who primarily works in Python and Go."
- "I prefer explicit error handling over try/catch blocks."

### 2. Feedback

Corrections and guidance from you. The most important type for improving Claude's behavior over time.

**Examples:**
- "Don't use default exports in this codebase -- we use named exports everywhere."
- "Stop suggesting `any` types in TypeScript. Use `unknown` instead."

### 3. Project

Ongoing work context: active decisions, deadlines, constraints, architectural choices not yet captured in code.

**Examples:**
- "We are migrating from REST to GraphQL. New endpoints should use GraphQL."
- "The v2 launch deadline is March 30. Prioritize stability over new features."

### 4. Reference

Pointers to external resources: Linear boards, Slack channels, dashboards, documentation URLs.

**Examples:**
- "The design specs live in Figma at [URL]."
- "The CI/CD dashboard is at [URL]."

## Memory File Format

Each memory file uses Markdown with YAML frontmatter:

```markdown
---
name: memory-name
description: one-line description
type: user|feedback|project|reference
---

Content here...
```

The `name` field is a short identifier (kebab-case works well). The `description` is a one-line summary for quick scanning. The `type` field must be one of the four types listed above.

## When Claude Saves Memory Automatically

Claude saves memories when you say "remember this," correct Claude, share your role or background, or mention an external resource. It chooses the appropriate memory type based on content.

## When Claude Reads Memory

Claude reads `MEMORY.md` at the start of every conversation and consults specific memories when they are relevant to the current task or when you ask it to recall something.

## How to Manually Manage Memory

**Through Claude:**
- "Remember that we use Vitest, not Jest" -- creates the appropriate memory file.
- "Forget about the Redis decision" -- removes that memory.

**Direct file editing:**
- Navigate to the memory directory and create, edit, or delete `.md` files directly.
- Update `MEMORY.md` if you add or remove files manually.
