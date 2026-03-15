# Getting Started with Claude Code

## Prerequisites

Install Claude Code following the [official documentation](https://docs.anthropic.com/en/docs/claude-code/overview). This guide assumes you have `claude` installed and working.

---

## Key Concepts

- **CLAUDE.md (Instruction Files):** Markdown files that give Claude persistent instructions about you, your workflow, and your rules. See [Writing Your Global CLAUDE.md](#writing-your-global-claudemd) below.
- **Skills (Slash Commands):** Custom commands like `/pre-implement` that Claude executes by reading a `SKILL.md` file in `~/.claude/skills/`. See [Skills](03-skills.md) for details.
- **Hooks (Pre/Post Tool Triggers):** Shell commands that run automatically before or after Claude uses a tool. See [Hooks](04-hooks.md) for details.
- **Memory (Persistent Cross-Session Knowledge):** Project-specific context and memory files that persist between conversations under `~/.claude/`. See [Memory](05-memory-system.md) for details.

---

## Directory Structure

```
~/.claude/
  CLAUDE.md                  # Global instructions (loaded every session)
  settings.json              # Global settings (model, hooks, features)
  settings.local.json        # Local overrides, gitignored (permissions, personal prefs)
  skills/                    # Slash command definitions
    session-start/
      SKILL.md
    pre-implement/
      SKILL.md
    harden/
      SKILL.md
    ...
  references/                # Reference docs Claude can access on demand
  templates/                 # Reusable templates (PR templates, issue templates, etc.)
  agents/                    # Custom agent definitions
  projects/                  # Per-project memory and tasks (auto-managed by Claude)
  memory/                    # Persistent memory files
```

---

## How Claude Code Reads Instructions: Load Order

When you start a conversation, Claude Code loads instructions in this order:

1. **Global CLAUDE.md** (`~/.claude/CLAUDE.md`) -- loaded first, applies everywhere.
2. **Project CLAUDE.md** (`.claude/CLAUDE.md` in the current repo) -- loaded second, can override or extend global instructions.
3. **Conversation context** -- anything you say in the current session, including skill invocations and tool outputs.

Later sources take precedence. If your global CLAUDE.md says "use conventional commits" but a project CLAUDE.md says "use semantic commits," the project-level instruction wins for that project.

This layering means you can set universal preferences once (in the global file) and fine-tune per project without repeating yourself.

---

## Writing Your Global CLAUDE.md

Your global `CLAUDE.md` file (`~/.claude/CLAUDE.md`) is a set of persistent instructions that Claude reads at the start of every conversation. It tells Claude who you are, how you want it to behave, what workflow gates to enforce, and what patterns to watch for.

Without it, Claude starts every session with zero context about you. You end up repeating the same instructions and correcting the same behaviors over and over.

See [`../examples/CLAUDE.md`](../examples/CLAUDE.md) for a complete, annotated example. Copy it and fill in your details.

### Section-by-Section Breakdown

What each section does and why it exists:

- **TL;DR** -- Quick reference summary so Claude can orient without reading the whole file. Include your identity, core workflow steps, and one "golden rule" anchored to a specific past mistake.
- **Profile** -- Your experience level, strengths, and growth areas. Helps Claude calibrate how much to explain and where to push back harder.
- **Active Projects** -- One-line descriptions of what you are working on. Gives Claude context for cross-project references.
- **Automation** -- Short note that workflow is enforced by hooks in `settings.json` and skill chaining. Hooks handle the enforcement that CLAUDE.md tables used to handle manually. Each skill's "Next Step" section chains to the next skill in the workflow.
- **Default Behaviors: Debugging** -- Rules like "one change at a time" and "state a hypothesis first" that prevent scatter-shot debugging.
- **Default Behaviors: Review Mode** -- Sets the tone for code review (e.g., skeptical, not encouraging).
- **Default Behaviors: Context-Specific** -- Situational interventions like suggesting `/comprehend` for pasted code or autonomous investigation for bug reports.
- **Writing Style** -- Banned words and preferred style. Banning specific words is more effective than saying "write naturally."
- **Session Tracking** -- Asks Claude to maintain a mental checklist of tasks, skills run, and debugging attempts during the session.
- **Learnings Log** -- Points Claude to `learnings.md` for persistent mistake tracking. See [Project Setup](06-project-setup.md) for format details.
- **Project Setup Checklist** -- Standardizes how new projects are initialized. See [Project Setup](06-project-setup.md).
- **Git Workflow** -- Branching strategy and commit rules. Prevents Claude from pushing to main or using non-standard commits.

### Tips: What to Include vs. Leave Out

**Include:** workflow preferences, coding style rules, growth areas, references to specific past mistakes, debugging philosophy, review tone.

**Leave out:** passwords and API keys (use env vars), things that change daily (use conversation context), obvious instructions ("write working code"), long reference docs (put in `~/.claude/references/` instead).
