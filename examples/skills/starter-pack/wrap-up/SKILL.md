---
name: wrap-up
description: End-of-session documentation and handoff routine
---

# /wrap-up - Session Wrap-Up and Handoff

When invoked, produce a session summary that a future session can pick up from. This is the last thing to run before ending a session.

## Steps

### 1. Summarize What Was Accomplished

- List each task or feature that was completed.
- Note the files that were changed (provide paths).
- Mention any commits made and their messages.

### 2. Note Incomplete Work and Blockers

- List anything that was started but not finished.
- For each incomplete item, note:
  - What's done so far.
  - What remains.
  - Any blockers or decisions that need to be made.
- If there are open questions that need answers before continuing, list them.

### 3. Update learnings.md

- Review the session for any corrections or surprises.
- If the user corrected an assumption, a library behaved unexpectedly, or debugging revealed something non-obvious, append an entry to `learnings.md`.
- If no corrections occurred, skip this step.

### 4. List Suggested Next Steps

- Based on what was accomplished and what remains, suggest 3-5 concrete next steps.
- Order them by priority or logical sequence.
- Be specific: "Write tests for the auth middleware in src/middleware/auth.ts" is better than "Add tests."

### 5. Audit Skipped Skills

Review the session for workflow gates that should have been triggered:

- Was an unfamiliar library used? Was `/learn` run?
- Was error handling addressed? Was `/harden` run?
- Were docs updated? Was `/docs` run?
- Is this going to production? Was `/pre-ship` run?

For each skipped skill:
- Note what was skipped.
- Note whether skipping was justified (and what the justification was).
- Flag any that should be run before the next deploy.

## Output Format

```
## Session Summary - [DATE]

### Completed
- [Task 1]: [brief description, key files changed]
- [Task 2]: [brief description, key files changed]

### Incomplete / In Progress
- [Task]: [what's done, what remains, blockers]

### Learnings Added
- [learning title] (or "None this session")

### Next Steps
1. [Specific actionable step]
2. [Specific actionable step]
3. [Specific actionable step]

### Skipped Skills
- [Skill]: [justified/unjustified] - [reason or recommendation]
(or "All required skills were run")

### Open Questions
- [Question that needs an answer before proceeding]
(or "None")
```

## Rules

- Always produce the summary even if the session was short.
- Be honest about what was skipped. The point is to catch gaps, not to look good.
- Next steps should be actionable by someone with no context beyond this summary and the codebase.
- If `learnings.md` does not exist yet and there were corrections, create it.
