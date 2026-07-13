---
name: pre-mortem
description: Before implementing, imagine the solution already failed in production. Surfaces risks, assumptions, and failure modes while it's still cheap to change course.
---

# Pre-Mortem Analysis

Imagine it's 3 months from now. The feature shipped, and it failed badly. What went wrong?

## When to Use

Run `/pre-mortem` before:
- Implementing anything that touches production data
- Making architectural decisions that are hard to reverse
- When a solution "feels too easy" (you're probably missing something)
- After planning, but before coding
- Before deploying significant changes

## The Pre-Mortem Process

### Step 1: State the Plan

Briefly describe what's about to be implemented:
- What does it do?
- How does it work?
- What systems does it touch?

### Step 2: Imagine Failure

**The scenario**: It's 3 months later. This feature has caused a major incident. The team is in a post-mortem meeting.

Now work backwards: **What went wrong?**

### Step 3: Identify Failure Modes

For each category, list specific ways this could fail:

#### Data Integrity Failures
- Could this corrupt or lose user data?
- What happens if it runs twice accidentally?
- What happens on partial completion?
- Are there race conditions?

#### External Dependency Failures
- What if the API is slow (>5s response)?
- What if the API is down?
- What if the API returns unexpected data?
- What if credentials expire?

#### Scale Failures
- What happens with 10x the expected load?
- What happens with very large inputs?
- What happens with many concurrent users?

#### Edge Case Failures
- What inputs haven't we considered?
- What user behaviors are unexpected?
- What timing issues could occur?

#### Security Failures
- Could this be exploited?
- Does it expose sensitive data?
- Are there injection risks?

#### Operational Failures
- How would we know if this breaks?
- Can we roll it back quickly?
- Do we have logs to debug issues?

### Step 4: Assess Assumptions

List every assumption the plan makes:

| Assumption | What if it's wrong? | How to verify |
|------------|---------------------|---------------|
| [X is always true] | [Consequence] | [How to check] |

### Step 5: Risk Matrix

Rate each failure mode:

| Failure Mode | Likelihood | Impact | Priority |
|--------------|------------|--------|----------|
| [Description] | Low/Med/High | Low/Med/High | P1/P2/P3 |

Focus on High-Impact items, regardless of likelihood.

### Step 6: Mitigation Plan

For P1 and P2 risks, define mitigations:

| Risk | Mitigation | When to Implement |
|------|------------|-------------------|
| [Risk] | [How to prevent/handle] | Before launch / Can defer |

## Output Format

```markdown
## Pre-Mortem: [Feature Name]

### The Plan
[Brief description of what we're implementing]

### Failure Scenarios

#### Most Likely Failures
1. [Failure mode with highest probability]
2. [Second most likely]
3. [Third most likely]

#### Highest Impact Failures
1. [Worst case scenario - even if unlikely]
2. [Second worst]
3. [Third worst]

### Assumptions at Risk
| Assumption | Risk if Wrong |
|------------|---------------|
| ... | ... |

### Required Mitigations (Do Before Launch)
- [ ] [Mitigation 1]
- [ ] [Mitigation 2]

### Recommended Mitigations (Do If Time Allows)
- [ ] [Mitigation 3]
- [ ] [Mitigation 4]

### Monitoring & Rollback
- **How to detect failure**: [Metrics/alerts to watch]
- **Rollback plan**: [How to undo if needed]

### Verdict
[ ] Safe to proceed
[ ] Proceed with required mitigations
[ ] Needs redesign - risks too high
```

## Key Questions to Always Ask

1. **What's the blast radius?** If this fails, what else breaks?
2. **Can we undo it?** Is there a rollback path?
3. **How will we know it's broken?** Do we have monitoring?
4. **What's the worst case?** Data loss? Security breach? Downtime?
5. **What are we assuming about external systems?** APIs, databases, third parties?

## Example

**Plan**: Add auto-save that writes to Firebase every 5 seconds.

**Pre-mortem reveals**:
- **Assumption**: User always has network → WRONG, mobile users go offline
- **Failure mode**: Rapid writes could hit Firebase rate limits
- **Failure mode**: If save fails silently, user loses work
- **Missing**: No conflict resolution if user opens two tabs

**Mitigations**:
- Add offline queue with retry
- Debounce writes, batch changes
- Show save status indicator
- Add last-write-wins with timestamp

## The Anti-Pattern This Prevents

The Timer Feature Pattern from your lessons learned:
- Jumped into coding
- Discovered Firebase `update()` behavior mid-implementation
- Spent hours debugging
- Had to revert

A pre-mortem would have asked: "What assumptions are we making about Firebase?" and caught this before any code was written.

## Next Step

Begin implementation. Reference the failure modes identified above during `/harden`.

## When to Skip

You can skip pre-mortem for:
- Purely local changes with no external dependencies
- Changes that are trivially reversible
- Exploratory/prototype code that won't ship

When in doubt, spend 5 minutes on a lightweight pre-mortem. It's the cheapest insurance you can buy.
