---
name: pre-implement
description: Planning workflow before implementing any non-trivial feature. Use when starting work on a new feature, bug fix, or significant code change. Forces research and design before coding.
---

# Pre-Implementation Planning

This skill enforces a disciplined approach to implementation: **research first, design second, code third**.

## When to Use

Run `/pre-implement` before starting ANY task that:
- Takes more than 30 minutes
- Touches more than 2-3 files
- Involves external services (APIs, databases, third-party libs)
- Has unclear requirements
- Could be implemented multiple ways

## Prerequisites Check

Before running this skill, verify:

| If task involves... | Run first |
|---------------------|-----------|
| Unfamiliar library/API | `/learn` |

If these weren't run, stop and run them now.

## The Pre-Implementation Checklist

### Phase 1: Understand the Problem

Before writing any code, answer these questions:

1. **What exactly needs to happen?**
   - [ ] Can you describe the feature in one sentence?
   - [ ] What are the acceptance criteria?
   - [ ] What edge cases exist?

2. **What already exists?**
   - [ ] Search codebase for related code
   - [ ] Check if similar patterns exist
   - [ ] Review relevant documentation

3. **What are the dependencies?**
   - [ ] What external services are involved?
   - [ ] What libraries/packages are needed?
   - [ ] Are there documented gotchas? (READ THE DOCS)

4. **Systems Thinking: What else does this touch?**
   - [ ] What other components interact with this?
   - [ ] What happens when those components fail or slow down?
   - [ ] Draw the system context if complex

### Phase 2: Design the Solution

5. **State Management (if applicable)**
   - [ ] What state does this feature need?
   - [ ] Where will it live? (local, context, database)
   - [ ] What changes it?
   - [ ] How do other components know when it changes?
   - [ ] What happens if state gets out of sync?

6. **What's the approach?**
   - [ ] Draw a state diagram if state management is involved
   - [ ] List the files that need to change
   - [ ] Write pseudocode for complex logic

7. **Trade-off Analysis**

   | Approach | Pros | Cons | What You Give Up |
   |----------|------|------|------------------|
   | Option A | ... | ... | ... |
   | Option B | ... | ... | ... |

   **Chosen approach:** [Option] because [trade-off is acceptable given context]

8. **What could go wrong?**
   - [ ] What happens if external service fails?
   - [ ] What happens on bad input?
   - [ ] What happens on network issues?

9. **Reversibility: How do we undo this?**
   - [ ] If this breaks in production, how quickly can we roll back?
   - [ ] Can we feature flag this?
   - [ ] Is there a gradual rollout path?
   - [ ] What's the escape hatch?

10. **What tests will prove it works?**
    - [ ] Write test cases BEFORE implementing
    - [ ] Include happy path and error cases
    - [ ] Include edge cases identified in step 1

### Phase 3: Validate the Plan

11. **Review the plan**
    - [ ] Does this align with existing patterns in the codebase?
    - [ ] Is this the simplest solution that works?
    - [ ] Are there any obvious issues?
    - [ ] Did we answer all the self-check questions?

12. **Get confirmation**
    - [ ] Present the plan to the user
    - [ ] Confirm approach before coding

## Output Format

After running this checklist, **persist the plan to disk** and output it to the user.

### File Structure

Create a directory under `plans/active/{task-name}/` (in the project root) with three files:

1. **`strategy.md`** — The plan itself. Updated rarely, only when approach fundamentally changes.
2. **`findings.md`** — Research discoveries, gotchas, docs references. Updated during research phases.
3. **`progress.md`** — What's done, what's next, blockers. Updated every interaction.

This allows autonomous agents in loops to pick up where the previous iteration left off.

### strategy.md template

```markdown
## Pre-Implementation Plan: [Feature Name]

### Problem Statement
[One sentence description]

### Existing Code Review
- **Related files**: [list]
- **Similar patterns**: [list]
- **Dependencies**: [list]

### Proposed Approach
[Description of the solution]

### Files to Change
| File | Change Type | Description |
|------|-------------|-------------|
| path/to/file.ts | Modify | Add X function |

### Risk Assessment
| Risk | Mitigation |
|------|------------|
| [What could fail] | [How to handle] |

### Test Cases
1. [Happy path test]
2. [Error case test]
3. [Edge case test]

### Questions for User
- [Any clarifications needed?]
```

### findings.md template

```markdown
## Findings: [Feature Name]

### Research Notes
- [What you learned from reading docs, code, etc.]

### Gotchas
- [Surprising behavior, edge cases discovered]

### Relevant Code
- [File paths and snippets that matter]
```

### progress.md template

```markdown
## Progress: [Feature Name]

### Status: [NOT STARTED | IN PROGRESS | BLOCKED | DONE]

### Completed
- [ ] ...

### Next Steps
- [ ] ...

### Blockers
- (none)
```

When the task is complete, move the directory from `plans/active/` to `plans/completed/`.

## Example Usage

**User**: "Add a webhook handler that retries failed deliveries"

**Before `/pre-implement`** (what NOT to do):
- Jump in and start coding the retry logic
- Discover race conditions with concurrent deliveries mid-implementation
- Spend hours debugging
- Revert everything

**After `/pre-implement`** (correct approach):
1. Research the webhook provider's retry semantics and idempotency guarantees
2. Discover that duplicate deliveries are possible during retries
3. Design state management with idempotency keys to handle this
4. Write test for "when delivery fails, retry queue should process in order"
5. THEN implement

## Key Principle

> "Weeks of coding can save you hours of planning."

The time spent planning is always less than the time spent debugging a bad implementation.

## When to Skip

You can skip this for:
- Typo fixes
- Single-line changes
- Adding console.log for debugging
- Tasks explicitly defined with no ambiguity

When in doubt, run the checklist. It takes 10 minutes and saves hours.
