---
name: refactor
description: Systematic refactoring with safety checks
---

# /refactor - Safe, Incremental Refactoring

When invoked, perform a refactoring using small, reversible steps with test verification at each step. Never refactor and add features at the same time.

## Steps

### 1. Ensure Tests Exist

Before changing any code, verify there are tests covering the code you're about to refactor.

- If tests exist and pass: proceed.
- If tests exist but fail: fix them first. Do not refactor broken code.
- If no tests exist: write them first. You need a safety net before restructuring. The tests should capture current behavior, even if that behavior has bugs (fix bugs in a separate step).

### 2. Identify the Specific Improvement

Name the exact problem. Vague refactors lead to scope creep.

Common refactoring targets:
- **Extract function** -- a block of code does a distinct thing and should be named.
- **Inline function** -- a function adds indirection without clarity.
- **Rename** -- a name is misleading or unclear.
- **Split file** -- a file has grown to contain unrelated concerns.
- **Reduce complexity** -- deeply nested conditionals, long parameter lists, god objects.
- **Remove duplication** -- the same logic exists in multiple places (only if it's truly the same concept, not coincidentally similar code).
- **Improve types** -- `any` types, missing interfaces, stringly-typed values.

State it in one sentence: "Extract the validation logic from `handleSubmit` into a `validateOrder` function."

### 3. Plan the Steps

Break the refactor into the smallest possible changes. Each step should:
- Be independently committable.
- Leave the code in a working state.
- Be easy to revert without affecting other steps.

Example plan for "split a large file":
1. Identify which functions belong together.
2. Create the new file with the extracted functions.
3. Update imports in the original file.
4. Update imports in all consumers.
5. Remove the functions from the original file.
6. Verify.

### 4. Execute One Step at a Time

For each step:
1. Make the change.
2. Run the tests.
3. If tests pass: continue to the next step.
4. If tests fail: **revert immediately** and figure out what went wrong before trying again.

### 5. Verify the Result

After all steps are complete:
- Run the full test suite.
- Verify the behavior is identical (refactoring changes structure, not behavior).
- Review the diff: is the code actually clearer, or did the refactor just move complexity around?

## Rules

1. **Tests first.** No safety net, no refactor.
2. **One step at a time.** Each step should compile and pass tests.
3. **Revert on failure.** If a step breaks tests, undo it completely before investigating.
4. **Never combine refactoring with feature work.** Refactor in one commit, add the feature in the next. Mixing them makes both harder to review and harder to revert.
5. **Don't refactor what you don't understand.** If you can't explain what the code does, read it until you can before restructuring it.
6. **Refactoring is not rewriting.** If you're deleting everything and starting over, that's a rewrite, not a refactor. Rewrites need their own planning process.

## Output Format

```
## Refactor: [one-sentence description]

### Pre-conditions
- Tests: [pass/wrote N new tests/fixed N failing tests]
- Code smell: [specific problem being addressed]

### Steps Taken
1. [Step]: [result - pass/revert]
2. [Step]: [result - pass/revert]

### Result
- Tests: [all passing / N tests, N passing]
- Behavior: [unchanged / describe any intentional changes]
- Files changed: [list]
```
