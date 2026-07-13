---
name: fresh-eyes
description: Reset when stuck in a rabbit hole. Summarizes what's been tried, identifies why it's failing, and proposes a completely different approach. Use when debugging for 30+ minutes or going in circles.
---

# Fresh Eyes Reset

A structured way to break out of unproductive loops and approach a problem from scratch.

## When to Use

Run `/fresh-eyes` when:
- You've been debugging the same issue for 30+ minutes
- The conversation has gotten long and tangled
- You keep trying variations of the same failing approach
- You feel frustrated or like you're going in circles
- You've lost track of what's been tried

## The Fresh Eyes Process

### Step 1: Summarize the Goal

State in one sentence what we're trying to accomplish.

> "We're trying to [X] so that [Y]."

### Step 2: List What's Been Tried

Create a table of attempts and outcomes:

| Attempt | Approach | Result | Why It Failed |
|---------|----------|--------|---------------|
| 1 | [Description] | [Outcome] | [Root cause] |
| 2 | [Description] | [Outcome] | [Root cause] |
| ... | ... | ... | ... |

### Step 3: Identify Patterns

Look across all attempts and ask:
- What assumptions are we making in ALL approaches?
- Is there a common failure point?
- Are we solving the right problem?
- What have we NOT tried?

### Step 4: Challenge the Premise

Ask these questions:
- **Is this actually necessary?** Could we achieve the goal differently?
- **Are we fighting the framework?** Maybe the "right" way isn't what we're doing.
- **What would a senior engineer do?** Step back and reconsider the architecture?
- **What would we do if we had to start over?** (Sometimes you should.)

### Step 5: Propose a Different Approach

Suggest an approach that:
- Doesn't share assumptions with previous attempts
- Addresses the identified root cause pattern
- Is simpler if possible

### Step 6: Decision Point

Present options to the user:
1. **Try the new approach** in this conversation
2. **Start a fresh session** with a clean summary
3. **Take a break** and revisit later (sometimes the best option)
4. **Ask for help** - pair with someone or post the question somewhere

## Output Format

```markdown
## Fresh Eyes Reset

### Goal
[One sentence: what we're trying to do]

### What's Been Tried
| # | Approach | Result |
|---|----------|--------|
| 1 | ... | ... |

### Pattern Analysis
- **Common assumption**: [What we keep assuming]
- **Recurring failure point**: [Where things break]
- **Unexplored direction**: [What we haven't tried]

### Root Cause Hypothesis
[What I think is actually going wrong]

### Proposed New Approach
[Completely different strategy that addresses the root cause]

### Recommendation
[ ] Try new approach here
[ ] Start fresh session with this context
[ ] Step away and revisit
```

## Key Principles

### Sunk Cost is Real
You've invested time in the current approach. That's irrelevant. The question is: what's the best path forward FROM HERE?

### Frustration is a Signal
When you feel stuck, that's valuable information. It usually means:
- The problem is harder than expected
- You're missing context or information
- The approach fundamentally doesn't work

### Starting Over Can Be Faster
A 30-minute conversation that's stuck will often take another 30 minutes to unstick. A fresh 15-minute conversation with the lessons learned is often faster.

## Example

**Stuck situation**: "We've tried 4 ways to sync the timer state with Firebase and none work correctly."

**Fresh eyes reveals**: All 4 approaches assumed Firebase `update()` does deep merges. It doesn't. The fix isn't a better sync strategy—it's restructuring the data model.

**New approach**: Flatten the state structure so `update()` works as expected.

## When Fresh Eyes Isn't Enough

If fresh eyes still doesn't help:
- The problem might require knowledge you don't have (time to research or ask)
- The problem might be a bug in a dependency (time to check issues/forums)
- The problem might need a completely different technology choice
