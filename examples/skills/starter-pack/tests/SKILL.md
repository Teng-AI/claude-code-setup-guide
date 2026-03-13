---
name: tests
description: Analyze test coverage gaps and write missing tests
---

# /tests - Test Coverage Analysis and Generation

When invoked, analyze the codebase for test coverage gaps and write missing tests.

## Steps

### 1. Run Existing Tests

- Detect the test runner (Jest, Vitest, pytest, Go test, etc.) from config files.
- Run the full test suite. Note any failures -- these must be fixed before writing new tests.
- If a coverage tool is configured, run it and note the coverage report.

### 2. Identify Untested Code Paths

- Compare source files against test files. Flag source files with no corresponding test file.
- Within tested files, look for:
  - Functions or methods with no test coverage.
  - Branches (if/else, switch, try/catch) that are never exercised.
  - Error handling paths that are never tested.
  - Edge cases: empty inputs, boundary values, null/undefined, concurrent access.

### 3. Prioritize by Risk

Rank untested code by risk, highest first:

1. **Critical path** -- auth, payments, data writes, user-facing API endpoints.
2. **State management** -- reducers, stores, caches, sync logic.
3. **Data transformation** -- parsers, serializers, formatters, validators.
4. **Business logic** -- rules, calculations, workflows.
5. **Utilities** -- pure helper functions (lowest risk but easiest to test).

### 4. Write Tests

For each gap, write tests following these guidelines:

**What to test:**
- Behavior and outcomes, not implementation details.
- Public API surface, not private internals.
- Each logical branch (happy path, error path, edge cases).
- Integration points between modules.

**What NOT to test:**
- Third-party library internals.
- Simple getters/setters with no logic.
- Framework boilerplate (e.g., Next.js page exports).
- UI layout details that change frequently.

**Test structure:**
- Use descriptive test names that read like specifications: "returns empty array when no items match filter".
- Arrange-Act-Assert pattern.
- One assertion per concept (multiple asserts are fine if they test the same behavior).
- Avoid test interdependence -- each test should run in isolation.

**Edge cases to always consider:**
- Empty inputs (empty string, empty array, null, undefined).
- Boundary values (0, -1, MAX_INT, empty collections).
- Invalid types (string where number expected, if dynamically typed).
- Concurrent or repeated calls.
- Network/IO failures (mock these).

### 5. Verify

- Run the full test suite including new tests.
- Confirm all tests pass.
- If coverage tooling exists, confirm coverage improved.
- Review new tests: are they testing behavior or implementation?

## Output Format

```
## Test Coverage Report

### Current State
- Test files: X
- Source files without tests: Y
- Estimated coverage: Z%

### Tests Written
- [file]: [what was tested] (N tests)
- ...

### Remaining Gaps
- [file/area]: [why it wasn't covered] (priority: high/medium/low)
```

## Rules

- Never modify existing passing tests unless they test implementation details that block a refactor.
- If existing tests are failing, fix them before writing new ones.
- Match the project's existing test style and conventions.
- Keep test files colocated with source or in the project's established test directory.
- If no test infrastructure exists, set it up first (install runner, create config, add npm script or Makefile target).
