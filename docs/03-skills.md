# Skills

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

You can write a `SKILL.md` from scratch, or use the `/skill-creator` skill to generate one interactively. The skill creator walks you through defining the name, description, and prompt body, then writes the file for you.

## Best Practices

**Keep skills focused.** One skill should do one thing. If you find yourself adding "and also do X" to a skill, that is a sign it should be two skills. A skill named `test-and-deploy` is doing too much.

**Stay under 500 lines.** Long skills become hard to maintain and can dilute Claude's attention. If a skill is growing past 500 lines, break it into smaller skills that can be composed together.

**Include examples of expected output.** Showing Claude what the result should look like is more effective than describing it abstractly. Add a section like "Example Output" with a concrete sample.

**Write clear, imperative instructions.** Skills are prompts. Use direct language: "List all files that changed" rather than "You might want to consider listing files."

**Use headers to organize sections.** Claude responds well to structured prompts. Break your skill into logical sections with markdown headers.

**Test incrementally.** Invoke your skill a few times and refine the wording based on what Claude produces. Small changes to phrasing can significantly change output quality.

**Add a "Next Step" section.** End each skill with a concrete handoff that tells Claude which skill to suggest next. This creates automatic chaining so the user does not need to remember the workflow sequence. For example, `/harden` ends with "Next Step: Run `/tests` to cover the error handling added above."

---

## Skills Catalog

All skills organized by workflow phase.

---

### Session Management

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/session-start` | Standardized session kickoff with health checks and context loading. | At the start of every session. | Beginner |
| `/wrap-up` | End-of-session documentation and handoff routine. | At the end of every session. | Beginner |
| `/onboard` | Get up to speed on an unfamiliar codebase quickly. | When joining a new project. | Intermediate |

---

### Planning

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/pre-implement` | Pre-implementation planning with the 7 questions, state management analysis, and trade-offs. | Before any non-trivial feature. | Beginner |
| `/pre-mortem` | Imagine the solution already failed and surface risks before they happen. | For high-stakes features (payments, auth, production data). | Intermediate |
| `/learn` | Research an unfamiliar domain or library before building with it. | Before using a new API or framework. | Intermediate |
| `/state-audit` | Audit state management before implementing. Prevents sync bugs. | Before any feature involving state, real-time data, or Firebase. | Intermediate |

---

### Implementation

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/harden` | Add error handling, validation, and logging after the happy path works. | After "it works" and before writing tests. | Beginner |
| `/comprehend` | Walk through code line-by-line before using or modifying it. | Before modifying unfamiliar code. | Intermediate |
| `/refactor` | Systematic refactoring with safety checks. | When cleaning up code. | Intermediate |

---

### Quality

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/tests` | Analyze test coverage gaps and write missing tests. | After implementation. | Beginner |
| `/code-reviewer` | Review code for correctness, security, and performance. | Before committing. | Intermediate |
| `/debug` | Structured, hypothesis-driven debugging workflow. | When something breaks. | Beginner |
| `/fresh-eyes` | Reset perspective when stuck in a debugging rabbit hole. | After 3 or more failed debug attempts. | Intermediate |

---

### Deployment

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/pre-ship` | Production readiness checklist. | Before deploying. | Intermediate |
| `/docs` | Sync documentation with code changes. | Before committing. | Beginner |
| `/git-workflow` | Standard git operations with conventional commits. | For all git work. | Beginner |
| `/nextjs-deploy` | Next.js preview and deploy workflow. | When deploying Next.js apps. | Advanced |

---

### Specialized

| Skill | Description | When to Use | Level |
|-------|-------------|-------------|-------|
| `/debug-firebase` | Firebase-specific debugging patterns. | When debugging Firebase issues. | Advanced |
| `/security-check` | Security vulnerability scanner. | Before shipping features that handle user data. | Advanced |
| `/performance-audit` | Performance analysis for web apps. | When investigating slow pages or interactions. | Advanced |
| `/architecture-review` | Codebase health check and infrastructure maturity assessment. | During project planning or quarterly reviews. | Advanced |
| `/design-review` | Visual design review covering hierarchy, typography, color, and layout. | When reviewing UI changes. | Advanced |
| `/website-qa` | Website QA checker for links, responsive behavior, accessibility, and performance. | Before launching or after major UI changes. | Advanced |
| `/doc-write` | Write new documentation from scratch. | When creating docs for a new feature or project. | Intermediate |
| `/project-scaffolding` | Set up new projects with sensible defaults. | When starting a new project. | Intermediate |
| `/skill-creator` | Create new Claude Code skills interactively. | When building a custom skill. | Advanced |
| `/prompt-refiner` | Improve and optimize prompts. | When a prompt is not producing good results. | Advanced |
| `/humanizer` | Remove signs of AI-generated writing. | When polishing content for publication. | Advanced |
| `/ralph-prep` | Optimize prompts for Ralph Loop autonomous iteration. | When setting up autonomous workflows. | Advanced |
| `/roadmap` | Quick view of active priorities across projects. | When planning what to work on next. | Intermediate |
| `/business-thought-partner` | Strategic business advisor for product and business decisions. | When making business strategy decisions. | Advanced |

---

## Recommended Learning Path

**Stage 1: Starter Pack** -- session-start, pre-implement, harden, tests, debug, docs, git-workflow, wrap-up

**Stage 2: Add Planning** -- pre-mortem, learn

**Stage 3: Add Quality** -- code-reviewer, fresh-eyes, comprehend, refactor

**Stage 4: Specialized** -- pre-ship, security-check, performance-audit, plus others as needed
