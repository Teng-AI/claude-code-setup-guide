---
name: debug
description: Structured debugging workflow for any issue. Use when stuck on an error, unexpected behavior, or something that "should work but doesn't". Helps isolate root cause systematically instead of random guessing.
---

# Debug

A systematic approach to finding and fixing bugs. Stop guessing, start isolating.

## STOP: Before You Touch Anything

**Before making ANY code change, answer these questions:**

1. **What's your hypothesis?** (Not "I'll try X" but "I believe X is causing Y because Z")
2. **What evidence supports this hypothesis?**
3. **How will you test it?** (What result confirms or disproves it?)

If you can't answer these, you're about to debug by mutation. STOP.

## Mutation Mode Warning Signs

If any of these are true, you're in mutation mode:
- [ ] You're changing things "to see what happens"
- [ ] You've made 3+ changes without writing down hypotheses
- [ ] You're making multiple changes between test runs
- [ ] You can't explain why your current change should help
- [ ] You feel frustrated or like you're guessing

**If 2+ of these are true → Run `/fresh-eyes` immediately.**

## When to Use

- Error messages you don't understand
- Code that "should work" but doesn't
- Unexpected behavior
- Intermittent/flaky issues
- Before spending 30+ minutes randomly trying things

## The Debugging Process (Scientific Method)

### Step 1: Reproduce Reliably

**Before anything else, can you make it happen consistently?**

```
□ Can you reproduce the bug?
□ What are the exact steps?
□ Does it happen every time or intermittently?
□ What's the minimal reproduction case?
```

If you can't reproduce it, you can't fix it confidently.

### Step 2: Gather Evidence

**What do you actually know vs. assume?**

```bash
# Check error messages/logs
# Look at network requests
# Check console output
# Review recent changes
git diff HEAD~5
```

Write down:
- **Exact error message** (copy-paste, don't paraphrase)
- **Where it occurs** (file, line, function)
- **When it started** (after what change?)
- **What you expected** vs. **what happened**

### Step 3: Form a Hypothesis

Based on evidence, what's your best guess?

```markdown
**Hypothesis**: [What you think is wrong]
**Evidence**: [What supports this]
**Test**: [How to verify/disprove]
```

**Good hypothesis**: "The API returns null when user has no profile, and we're not handling that case"

**Bad hypothesis**: "Something is broken somewhere"

### Step 4: Isolate the Problem

Narrow down where the bug lives:

```
□ Is it frontend or backend?
□ Is it in my code or a dependency?
□ Does it happen in all environments or just one?
□ Does it happen for all users or specific cases?
```

**Binary search technique:**
1. Add a log/breakpoint halfway through the flow
2. Is the data correct at that point?
3. If yes → bug is downstream. If no → bug is upstream
4. Repeat until you find the exact location

### Step 5: Test Your Hypothesis

**One change at a time.**

```markdown
**Test**: [What you're trying]
**Expected**: [What should happen if hypothesis is correct]
**Actual**: [What actually happened]
**Conclusion**: [Confirmed/Disproved/Inconclusive]
```

If disproved, form a new hypothesis. Don't keep trying variations of a wrong idea.

### Step 6: Fix and Verify

Once you find the root cause:

1. **Fix the actual cause**, not the symptom
2. **Verify the fix** solves the original problem
3. **Check for side effects** — did you break anything else?
4. **Add a test** to prevent regression

## Debugging Checklist

### Quick Checks (Do These First)
```
□ Is it actually running your latest code? (save, rebuild, refresh)
□ Are there typos? (variable names, paths, URLs)
□ Is the data what you think it is? (console.log it)
□ Are you looking at the right environment?
□ Did you check the browser console / server logs?
```

### Common Culprits
```
□ Null/undefined where you expected a value
□ Async timing issues (race conditions)
□ Wrong data type (string vs number, array vs object)
□ Stale cache (browser, build, dependencies)
□ Environment variables not set/wrong
□ Off-by-one errors
□ Case sensitivity (URLs, file names, keys)
```

### Environment Issues
```
□ Different behavior in dev vs prod?
□ Works on your machine but not others?
□ Works in one browser but not another?
```

## Output Format

When debugging, document as you go:

```markdown
## Debug Log: [Brief description]

### The Problem
**Expected**: [What should happen]
**Actual**: [What happens instead]
**Error**: [Exact error message if any]

### Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [Bug occurs]

### Investigation

#### Hypothesis 1: [Description]
- Evidence: [What made you think this]
- Test: [What you tried]
- Result: ❌ Disproved / ✅ Confirmed

#### Hypothesis 2: [Description]
- Evidence: [...]
- Test: [...]
- Result: [...]

### Root Cause
[What was actually wrong]

### Fix
[What you changed]

### Prevention
[Test added / Guard added / etc.]
```

## Anti-Patterns to Avoid

### 1. Debugging by Mutation (THE BIG ONE)
❌ Changing things "to see what happens"
❌ "Let me just try changing this..."
❌ Multiple changes between test runs
❌ No hypothesis, just vibes
❌ Can't explain why the change should help

✅ One hypothesis → One change → One test
✅ If wrong, REVERT and form new hypothesis
✅ Document each attempt
✅ Explain WHY each change should work

**This is the #1 cause of wasted debugging time.**

### 2. Fixing Symptoms
❌ "I'll just add a null check here"
✅ Ask: "Why is it null in the first place?"

### 3. Assuming You Know
❌ "It must be X because..."
✅ Verify with evidence before concluding

### 4. Going Too Deep Too Fast
❌ Immediately diving into complex scenarios
✅ Start with the simplest possible reproduction

### 5. Not Taking Notes
❌ Trying to remember what you've tried
✅ Write down each hypothesis and result

### 6. Not Reverting Failed Attempts
❌ Leaving failed changes in place while trying more things
✅ Revert after each failed hypothesis before trying the next

## When to Escalate

Consider `/fresh-eyes` or asking for help when:
- You've been stuck for 30+ minutes
- You've tested 3+ hypotheses with no progress
- You're starting to try random things
- The same "fix" keeps not working

## Integration with Other Skills

```
Stuck debugging? → /debug (this skill)
Still stuck after 30 min? → /fresh-eyes
Firebase-specific? → /debug-firebase
```
