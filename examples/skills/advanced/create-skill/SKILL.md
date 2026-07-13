---
name: create-skill
description: Create new Claude Code skills. Use when the user says "create a skill", "make a skill", "new skill", "build a skill", "set up a slash command", or "automate [task] as a skill".
---

# Create Skill

Build Claude Code skills through a short interview, then generate the right-sized skill for the job.

## Step 1: Interview

Ask these three questions (adapt phrasing to the conversation, don't read them like a form):

1. **What's the task?** What does this skill do, and what does it produce?
2. **What does good output look like?** Ask for an example or description of the ideal result.
3. **What goes wrong?** When you (or Claude) do this task manually, what gets messed up?

If the user already explained the task in conversation, don't re-ask what you already know. Fill in the gaps.

## Step 2: Decide location

- **Global** (personal, all projects): `~/.claude/skills/<skill-name>/SKILL.md`
- **Project** (team, this repo): `.claude/skills/<skill-name>/SKILL.md`

Ask the user if unclear. Default to global for personal workflows.

## Step 3: Write the description

The description is the most important line. It controls when the skill triggers.

Rules:
- Lead with trigger phrases: `Use when the user says "[phrase]", "[alternate]", "[edge case]"`
- Write in third person (it injects into the system prompt)
- Include near-miss phrases that SHOULD trigger it
- Be specific and loud — vague descriptions get skipped

After writing it, mentally test: name 3 phrases that should trigger it, 2 that shouldn't. Adjust if the boundaries are fuzzy.

## Step 4: Write the skill body

Scale the skill to match the complexity surfaced in the interview.

### Always include

```markdown
## Steps
[Numbered steps. Tight and specific for structured/fragile tasks.
 Loose and directional for creative/exploratory tasks.]
```

### Include if the interview surfaced failure modes

```markdown
## Gotchas
[What will Claude get wrong? Write as "Don't X — because Y" or
 "You'll want to X — do Y instead". Seed from the interview,
 keep adding after every use.]
```

### Include if the skill produces structured output

```markdown
## Output Format
[Show a literal template of the expected output — headers, structure,
 length constraints. Show, don't describe.]

## Completeness Check
- [ ] [Verifiable minimums, not vibes]
- [ ] [e.g., "At least 3 failure modes identified"]
- [ ] [e.g., "All claims reference specific file:line"]
```

### Include if Claude keeps taking shortcuts

```markdown
## Rationalizations to Reject
- [Specific to this skill's domain, not generic "be thorough"]
- [e.g., "This code appears safe" — without citing specific lines]
```

## Step 5: Decide if supporting files are needed

Most skills work as a single SKILL.md. Add files only when you hit a specific problem:

| Signal | What to add |
|--------|-------------|
| Claude gets the output format wrong | `examples/good-output.md` — full gold-standard example |
| SKILL.md exceeds 400 lines | Move domain knowledge to `references/` |
| Skill needs to run scripts | `scripts/` — executed via Bash, never loaded into context |
| Output needs a rigid structure | `templates/output-template.md` |

Reference supporting files via markdown links so Claude knows they exist:
```markdown
For the expected output format, see [examples/good-output.md](examples/good-output.md)
```

One-level-deep rule: SKILL.md links to files. Files never link to other files.

### Full structure (use only what you need)

```
my-skill/
├── SKILL.md                  # Core instructions (required, <500 lines)
├── references/               # Domain knowledge, loaded on demand
├── examples/                 # Calibration for Claude's output
│   └── good-output.md        # Complete gold-standard output
├── templates/                # Structures Claude fills in
└── scripts/                  # Executables (run, never loaded into context)
```

## Step 6: Write and deliver

1. Create the skill directory and write SKILL.md
2. Add any supporting files identified in Step 5
3. Tell the user the invocation command: `/skill-name`
4. Close with: **"After first use — did you use the output directly or edit it? If you're editing, tell me what was wrong and we'll improve the skill."**

## Frontmatter Reference

Most skills need only `name` and `description`. Add these only when they serve a purpose:

| Field | When to use | Example |
|-------|-------------|---------|
| `disable-model-invocation: true` | Skill has side effects (deploys, commits, sends messages) | Prevents auto-triggering |
| `allowed-tools` | Skill should only read, not write | `[Read, Grep, Glob, Agent]` |
| `argument-hint` | Skill accepts parameters | `[issue-number]` |
| `effort` | Control reasoning depth | `low` for status checks, `max` for planning |
| `model` | Use a different model | `haiku` for fast/cheap tasks |
| `context: fork` | Run in fresh context without conversation history | Independent research tasks |
| `agent` | Pair with context:fork | `Explore`, `Plan`, `general-purpose` |

## Gotchas (for this skill)

- Don't over-build. If the interview reveals a simple task with no failure modes, produce a lean skill — just steps, no gotchas/checklist/templates.
- Don't add sections "just in case." Every section should trace back to something the user said in the interview.
- Don't write descriptions that summarize — write descriptions that trigger.
- Don't use generic gotchas like "be thorough" or "check your work." Every gotcha should name the specific thing that goes wrong.
