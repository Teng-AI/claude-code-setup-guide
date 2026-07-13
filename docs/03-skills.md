# Skills

> **Revision note (July 2026).** A transcript audit of the live config found the code-project chain skills (/learn, /harden, /test-gaps, /docs-sync, /pre-ship, /debug, /fresh-eyes, /refactor, /pre-mortem) had zero to two uses in 90 days once the work shifted from code to knowledge/ops. They were archived with re-add triggers, and /pre-mortem was folded into /pre-implement as a required step. The catalog below now leads with the knowledge/ops workflow the live config actually runs; the code chain remains shipped and documented under "Code-Project Chain" because the skills are sound for code-heavy work. The meta-lesson travels with them: prune skills against measured usage, and archive rather than delete so a trigger can bring them back.

## What Are Skills?

Skills are slash commands backed by `SKILL.md` prompt files. When you type `/skill-name` in a Claude Code conversation, Claude loads the corresponding `SKILL.md` file and follows its content as instructions.

Think of skills as reusable, composable prompts that encode a specific workflow. Instead of remembering exactly how to phrase a request every time, you define it once in a `SKILL.md` file and invoke it by name. This turns ad-hoc prompting into a repeatable process.

## SKILL.md Anatomy

Every skill file has two parts: YAML frontmatter and a markdown body.

```
---
name: skill-name
description: What this skill does (shown in autocomplete)
model: (optional) override model for this skill
---

# Skill Title

Instructions for Claude when this skill is invoked...
```

**Frontmatter fields:**

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | The slash command name (e.g., `pre-implement` becomes `/pre-implement`) |
| `description` | Yes | Short description shown in autocomplete when you start typing `/` |
| `model` | No | Override the default model for this skill (e.g., use a faster model for simple tasks) |

**Markdown body:** This is the actual prompt content. When you invoke the skill, Claude receives this text as instructions. It can include headers, lists, code blocks, conditional logic, templates -- anything you would put in a prompt.

## How to Install a Skill

Create a `SKILL.md` file in the global skills directory:

```
~/.claude/skills/{skill-name}/SKILL.md
```

For example, to install a skill called `pre-implement`:

```
~/.claude/skills/pre-implement/SKILL.md
```

That is all it takes. The next time you start a Claude Code session, the skill will be available.

## How to Invoke a Skill

Type `/skill-name` in your Claude Code conversation. Claude will load the `SKILL.md` content and follow its instructions.

```
You: /pre-implement

Claude: [Runs through the pre-implementation checklist defined in the skill]
```

Skills appear in autocomplete when you type `/`, so you do not need to memorize exact names.

## Project-Level Skills

Skills can also live inside a specific project:

```
{project-root}/.claude/skills/{skill-name}/SKILL.md
```

Project-level skills override global skills with the same name and are only available when working in that project. This is useful for project-specific workflows, such as a deploy skill that targets a particular hosting provider or a test skill that uses a specific testing framework.

**Precedence order:**
1. Project-level skills (checked first)
2. Global skills (fallback)

## How to Create Your Own

You can write a `SKILL.md` from scratch, or use the `/create-skill` skill to generate one interactively. The skill creator walks you through defining the name, description, and prompt body, then writes the file for you.

## Best Practices

**Keep skills focused.** One skill should do one thing. If you find yourself adding "and also do X" to a skill, that is a sign it should be two skills. A skill named `test-and-deploy` is doing too much.

**Stay under 500 lines.** Long skills become hard to maintain and can dilute Claude's attention. If a skill is growing past 500 lines, break it into smaller skills that can be composed together.

**Include examples of expected output.** Showing Claude what the result should look like is more effective than describing it abstractly. Add a section like "Example Output" with a concrete sample.

**Write clear, imperative instructions.** Skills are prompts. Use direct language: "List all files that changed" rather than "You might want to consider listing files."

**Use headers to organize sections.** Claude responds well to structured prompts. Break your skill into logical sections with markdown headers.

**Test incrementally.** Invoke your skill a few times and refine the wording based on what Claude produces. Small changes to phrasing can significantly change output quality.

**Add a "Next Step" section.** End each skill with a concrete handoff that tells Claude which skill to suggest next. This creates automatic chaining so the user does not need to remember the workflow sequence. For example, `/harden` ends with "Next Step: Run `/test-gaps` to cover the error handling added above."

---

## Skills Catalog

All skills organized by workflow phase. The starter pack is the core loop the live config runs daily; the advanced sets extend it.

---

### Core Workflow (Starter Pack)

The daily loop: `/grill-me` (if the idea is fuzzy) -> do the work -> `/checkpoint` as you go -> `/wrap-up`. Run `/pre-implement` before anything non-trivial gets built.

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/session-start` | Standardized session kickoff with health checks and context loading. | At the start of every session. | Beginner |
| `/grill-me` | Relentless one-question-at-a-time interview that extracts decisions from your head, checkpointing every answer to a `brainstorms/` file. | When bringing a fuzzy idea or process that needs decisions extracted before planning. | Beginner |
| `/pre-implement` | Pre-implementation planning with research, design trade-offs, and a required pre-mortem step. | Before any non-trivial feature or change. | Beginner |
| `/checkpoint` | High-fidelity session save: writes a HANDOVER.md breadcrumb (state, next step, open decisions) and commits. | Before compacting, stepping away, or nearing the context limit mid-task. | Beginner |
| `/wrap-up` | End-of-session routine: session log, roadmap update, git check, learnings capture, handoff. | At the end of every session. | Beginner |
| `/compound` | Extract learnings from the session (corrections, patterns, decisions, domain insights) into `learnings.md` and memory. | After meaningful work, or anytime something is worth remembering. | Beginner |
| `/fool` | Structured devil's advocate for stress-testing decisions, strategies, and beliefs. | Before any high-stakes decision, or when you want holes poked in a plan. | Intermediate |
| `/humanizer` | Remove signs of AI-generated writing, calibrated against a measured voice profile. | When polishing content for sending or publication. Pairs with a PostToolUse hook that flags AI tells automatically. | Intermediate |

---

### Thinking and Communication

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/plain` | Re-explain the current technical topic in plain English, anchored in the live example in the conversation. | When jargon piles up or layered concepts blur together. | Beginner |
| `/show-me` | Build a visual (diagram, table, timeline, widget) to explain the current topic. Sibling of `/plain`: that one fixes the words, this one fixes the shape. | When an explanation involves 3+ interacting parts or a multi-step flow. | Beginner |
| `/deck-review` | Review an investor pitch deck across positioning, narrative flow, consistency, and fundability. | Before sending a deck, or when giving deck feedback. | Advanced |
| `/open` | Find and open a file by fuzzy name match. | When you know roughly what a file is called but not where it lives. | Beginner |

---

### Setup Maintenance

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/setup-audit` | Periodic audit of the whole Claude Code setup: CLAUDE.md bloat, settings security, permission accumulation, hook safety, memory hygiene, version drift. | Monthly, after version bumps, or before sharing a machine or config. | Advanced |
| `/tidy` | Refactor a folder of docs or notes: audit for drift, then consolidate and reorganize, preserving content and git history. | When a knowledge folder has accumulated duplication and rot. | Intermediate |
| `/create-skill` | Create new Claude Code skills interactively. | When building a custom skill. | Advanced |

---

### Code-Project Chain

Archived in the live config after a usage audit (see the revision note above), but shipped and maintained here because the chain is sound for code-heavy work.

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/learn` | Research an unfamiliar domain or library before building with it. | Before using a new API or framework. | Intermediate |
| `/harden` | Add error handling, validation, and logging after the happy path works. | After "it works" and before writing tests. | Beginner |
| `/test-gaps` | Analyze test coverage gaps and write missing tests. | After implementation. | Beginner |
| `/debug` | Structured, hypothesis-driven debugging workflow. | When something breaks. | Beginner |
| `/fresh-eyes` | Reset perspective when stuck in a debugging rabbit hole. | After 3 or more failed debug attempts. | Intermediate |
| `/refactor` | Systematic refactoring with safety checks. | When cleaning up code. | Intermediate |
| `/docs-sync` | Sync documentation with code changes. | Before committing. | Beginner |
| `/pre-ship` | Production readiness checklist. | Before deploying. | Intermediate |
| `/pre-mortem` | Imagine the solution already failed and surface risks before they happen. (Folded into `/pre-implement` in the live config; kept standalone here.) | For high-stakes features (payments, auth, production data). | Intermediate |
| `/git-workflow` | Standard git operations with conventional commits. | For all git work. | Beginner |

---

### Specialized (Legacy)

Older skills kept as construction references. Useful patterns, but not part of the maintained workflow.

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/onboard` | Get up to speed on an unfamiliar codebase quickly. | When joining a new project. | Intermediate |
| `/comprehend` | Walk through code line-by-line before using or modifying it. | Before modifying unfamiliar code. | Intermediate |
| `/code-reviewer` | Review code for correctness, security, and performance. | Before committing. | Intermediate |
| `/nextjs-deploy` | Next.js preview and deploy workflow. | When deploying Next.js apps. | Advanced |
| `/debug-firebase` | Firebase-specific debugging patterns. | When debugging Firebase issues. | Advanced |
| `/security-check` | Security vulnerability scanner. | Before shipping features that handle user data. | Advanced |
| `/performance-audit` | Performance analysis for web apps. | When investigating slow pages or interactions. | Advanced |
| `/architecture-review` | Codebase health check and infrastructure maturity assessment. | During project planning or quarterly reviews. | Advanced |
| `/design-review` | Visual design review covering hierarchy, typography, color, and layout. | When reviewing UI changes. | Advanced |
| `/qa` | QA test a web application: find bugs and fix them (diff-aware, full, or quick mode). | Before launching or after major UI changes. | Advanced |
| `/doc-write` | Write new documentation from scratch. | When creating docs for a new feature or project. | Intermediate |
| `/project-scaffolding` | Set up new projects with sensible defaults. | When starting a new project. | Intermediate |
| `/prompt-refiner` | Improve and optimize prompts. | When a prompt is not producing good results. | Advanced |
| `/ralph-prep` | Optimize prompts for Ralph Loop autonomous iteration. | When setting up autonomous workflows. | Advanced |
| `/project-roadmap` | Quick view of active priorities across projects. | When planning what to work on next. | Intermediate |
| `/business-thought-partner` | Strategic business advisor template (fill in your own business context). | When making business strategy decisions. | Advanced |

---

## Recommended Learning Path

**Stage 1: Core loop** -- session-start, pre-implement, wrap-up. Get the open-work-close rhythm habitual first.

**Stage 2: Capture and continuity** -- compound, checkpoint. This is where the setup starts paying rent: learnings persist and sessions hand off cleanly.

**Stage 3: Better inputs** -- grill-me before building, fool before deciding, humanizer before sending.

**Stage 4: Extend by domain** -- plain, show-me, deck-review, and the maintenance skills (setup-audit, tidy) as your setup grows. Add the code-project chain if your work is code-heavy.
