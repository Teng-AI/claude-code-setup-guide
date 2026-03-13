---
name: skill-creator
description: Create new Claude Code skills with proper structure. Use when the user asks to create a skill, make a skill, or set up automation for a specific task.
---

# Skill Creator

When creating a new skill, follow this structure:

## Location
- **Global skills** (personal, all projects): `~/.claude/skills/<skill-name>/SKILL.md`
- **Project skills** (team, this repo only): `.claude/skills/<skill-name>/SKILL.md`

## Template

```yaml
---
name: skill-name
description: Clear description of when to use this skill. Include trigger phrases users might say.
---

# Skill Name

[Instructions for Claude when this skill is activated]

## When to Use
[Conditions that should trigger this skill]

## Steps
1. [First action]
2. [Second action]
3. [etc.]

## Important Notes
- [Constraints or special considerations]
```

## Best Practices
1. Keep description specific - it's used for semantic matching
2. Keep SKILL.md under 500 lines
3. Use referenced files for detailed documentation
4. One skill = one focused capability
