---
name: fresh-eyes
description: Reset perspective when stuck in debugging rabbit hole
---

# /fresh-eyes - Perspective Reset

When invoked, stop the current debugging approach entirely and re-examine the problem from scratch. Use this when you've been going in circles: 3+ failed hypotheses, fixes that create new bugs, or a growing sense that you're looking in the wrong place.

## When to Use

- Three or more debug hypotheses have been tested and disproved.
- A fix in one place keeps breaking something in another place.
- You can't clearly explain what's going wrong.
- You're making changes "to see what happens" instead of testing specific hypotheses.
- The same error keeps reappearing after you think you've fixed it.

## Steps

### 1. Stop

Put down the code. Do not make another change. Do not add another log statement. Stop.

### 2. Restate the Original Problem

Answer these two questions in plain language:

- **What should happen?** (expected behavior)
- **What actually happens?** (observed behavior)

If you can't state these clearly, that itself might be the problem -- you may be debugging the wrong thing.

### 3. List All Current Assumptions

Write out every assumption you're making about:

- Where the bug is (which file, which function, which layer).
- What's causing it (state, timing, data, logic).
- What's working correctly (and therefore not worth investigating).
- What the correct behavior should be.

Be thorough. The bug is hiding behind one of these assumptions.

### 4. Challenge Each Assumption

For each assumption, ask: "How do I know this is true? Have I verified it, or am I assuming it?"

Common false assumptions:
- "This function is definitely returning the right value." (Did you log it?)
- "The data coming in is correct." (Did you inspect it at the boundary?)
- "This part works because it worked before." (Did something else change since then?)
- "The error message is accurate." (Error messages lie. Often.)
- "This code path is being executed." (Add a log at the top to confirm.)

### 5. Consider Different Angles

Ask yourself:

- **Wrong layer?** Could the bug be in the database, not the API? In the network, not the code? In the build, not the source?
- **Wrong timing?** Is it a race condition, stale data, or caching issue?
- **Wrong scope?** Are you looking at the right instance, the right environment, the right branch?
- **Different cause, same symptom?** Could something entirely unrelated produce the same error?
- **Is the test wrong?** Is the expected behavior actually correct?

### 6. Form a New Approach

Based on challenging your assumptions, identify:
- Which assumption was most likely wrong.
- What new hypothesis follows from correcting that assumption.
- What's the simplest way to test this new hypothesis.

Return to the `/debug` workflow with this new hypothesis.

## Output Format

```
## Fresh Eyes Reset

### Original Problem
- Expected: [what should happen]
- Actual: [what happens instead]

### Assumptions Challenged
- [Assumption 1]: [verified/unverified] - [how to verify if unverified]
- [Assumption 2]: [verified/unverified] - [how to verify if unverified]

### Previous Hypotheses (all disproved)
1. [Hypothesis]: [what was learned]
2. [Hypothesis]: [what was learned]
3. [Hypothesis]: [what was learned]

### New Direction
- Most likely false assumption: [which one]
- New hypothesis: [statement]
- Test plan: [how to verify with one change]
```

## Rules

- Do not skip any step. The value is in the process, not the speed.
- Be honest about what you've actually verified vs. what you've assumed.
- If after fresh-eyes you still can't form a good hypothesis, consider: is the problem well-defined? Can it be reproduced reliably? If not, focus on reproduction first.
