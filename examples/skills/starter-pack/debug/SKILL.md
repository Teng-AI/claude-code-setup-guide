---
name: debug
description: Structured hypothesis-driven debugging workflow
---

# /debug - Hypothesis-Driven Debugging

When invoked, follow a structured debugging process. Never shotgun debug. One change at a time, always revert failed attempts.

## Steps

### 1. Reproduce the Bug

- Get the exact steps to reproduce.
- Confirm you can see the bug happen consistently.
- If it's intermittent, note the conditions and frequency.
- Capture the actual behavior vs. expected behavior in one sentence each.

### 2. Form a Hypothesis

Before touching any code, state a hypothesis:

> "I think [SYMPTOM] is happening because [CAUSE] in [LOCATION]."

A good hypothesis is:
- **Specific** -- names a file, function, or line.
- **Testable** -- you can verify it with one change or one log statement.
- **Falsifiable** -- you know what result would disprove it.

A bad hypothesis is:
- "Something is wrong with the state."
- "Maybe it's a timing issue."
- "Let me try changing a few things."

### 3. Test the Hypothesis with ONE Change

- Make exactly one change to test your hypothesis.
- This can be: adding a log/breakpoint, changing a value, adding a guard clause.
- Run the reproduction steps.
- Observe the result.

**If the hypothesis was correct:**
- Write the fix.
- Verify the fix resolves the bug.
- Check for regressions (run the test suite).
- Done.

**If the hypothesis was wrong:**
- REVERT the change immediately. Do not leave debug code in place.
- Record what you learned: "Hypothesis 1 disproved: [what you found instead]."
- Form a new hypothesis based on what you learned.
- Go back to step 2.

### 4. Escalation: After 3 Failed Hypotheses

If three hypotheses have been tested and disproved:

- Stop making changes.
- Suggest running `/fresh-eyes` to reset perspective.
- List all hypotheses tested and what was learned from each.
- Consider whether the bug is in a different layer than expected (e.g., not in the component but in the data source, not in the backend but in the network layer).

## Rules

1. **One change at a time.** Never make multiple changes between test runs.
2. **Always revert failed attempts.** Failed debug changes must not accumulate in the codebase.
3. **Never shotgun debug.** Changing multiple things "to see what happens" is not debugging, it's gambling.
4. **State your hypothesis out loud** before making any change. If you can't articulate what you expect to learn from a change, don't make it.
5. **Track what you've tried.** Maintain a running list of hypotheses and outcomes so you don't repeat yourself.

## Debugging Checklist

Before diving into code, check these common causes:

- [ ] Is the right version of the code running? (stale build, wrong branch, cached assets)
- [ ] Are environment variables set correctly?
- [ ] Is the data what you expect? (log inputs at the boundary)
- [ ] Did a recent change introduce this? (check `git log` and `git bisect`)
- [ ] Is this a known issue? (check issue tracker, error messages)

## Output Format

After each hypothesis cycle, report:

```
## Hypothesis [N]
**Hypothesis:** [statement]
**Test:** [what change was made]
**Result:** [what happened]
**Conclusion:** [confirmed/disproved, what was learned]
```

When the bug is fixed:

```
## Resolution
**Root cause:** [one sentence]
**Fix:** [what was changed and why]
**Regression check:** [tests passed / manual verification]
```
