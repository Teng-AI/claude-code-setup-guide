---
name: roadmap
description: Quick view of active priorities across all roadmaps. Shows what's in progress, what's next, and what's blocked.
---

# Roadmap Check

Quick snapshot of active work across all roadmaps. Skips completed items, focuses on what needs attention.

## When to Use

- "What should I work on?"
- "What's on my plate?"
- Mid-session priority check
- After completing a task, to pick the next one

## Workflow

### Step 1: Read All Roadmaps

Read any roadmap files in the current project:
- `ROADMAP.md`
- `ROADMAP-INFRA.md`
- `FUTURE_FEATURES.md`

### Step 2: Filter to Active Items

Show ONLY items that are:
- `Not started` or `In progress` or `Blocked` or have no status marker
- In "Now" or "Next" priority sections
- Upcoming phases with unfinished items
- Ideas / backlog items (unchecked `- [ ]` entries)

Skip:
- Items marked `Done`
- Parking Lot / trigger-based items (unless user asks with `/roadmap all`)
- Completed checkboxes `[x]`

### Step 3: Display Summary

Format as a compact, scannable list grouped by source:

```markdown
## Roadmap Status

### Project (ROADMAP.md)
**Now**
- Feature A — In progress
- Feature B — Blocked (waiting on API access)

**Next**
- Feature C — Not started
- Feature D — Not started

**Ideas / Backlog**
- [ ] Potential feature E (M, ~4-6h)
- [ ] Potential feature F (S, ~1-2h)
```

### Step 4: Recommend Next Action

Based on what's active, suggest what to work on:
- Prioritize items in "Now" sections
- Flag blocked items and what unblocks them
- If nothing is urgent, suggest the highest-impact unstarted item

Keep the recommendation to 1-2 sentences.

## Arguments

- `/roadmap` -- Show active items only (default)
- `/roadmap all` -- Include parking lot and completed items
