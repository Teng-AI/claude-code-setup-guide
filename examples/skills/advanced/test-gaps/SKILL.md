---
name: test-gaps
description: Analyze test coverage gaps and write missing tests. Use after implementing features, before merging PRs, or when asked to add tests. Combines gap analysis with test generation.
---

# Tests

Analyze coverage gaps and generate tests to fill them. One workflow for all testing needs.

## Prerequisites Check

Before writing tests, verify:

| Prerequisite | Check | If Missing |
|--------------|-------|------------|
| Feature works on happy path | Manually tested | Fix bugs first |
| `/harden` was run | Error handling exists | Run `/harden` first |
| Failure modes identified | From `/pre-mortem` | Review what can fail |

**Testing unhardened code misses failure cases.** If `/harden` wasn't run and the feature has external dependencies, run it first.

## When to Use

- After implementing a feature (and running `/harden`)
- Before merging a PR
- When asked to "add tests" or "improve coverage"
- When a bug slips through to production
- Periodically to audit test health

## Workflow

### Step 1: Analyze Coverage

```bash
# Find source files
find src -name "*.ts" -o -name "*.tsx" | grep -v ".test." | grep -v ".spec."

# Find test files
find src -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts"
```

Map coverage:

| Source File | Test File | Status |
|-------------|-----------|--------|
| `lib/game.ts` | `__tests__/game.test.ts` | ❌ Missing |
| `lib/tiles.ts` | `__tests__/tiles.test.ts` | ✅ Exists |

### Step 2: Prioritize Gaps

| Priority | What to Test |
|----------|--------------|
| **Critical** | Core business logic, payments, auth |
| **High** | User-facing features, data mutations |
| **Medium** | Internal utilities, helpers |
| **Low** | Config, constants, types (skip these) |

### Step 3: Generate Tests

For each gap, write tests following these patterns:

#### Test Structure (AAA Pattern)
```typescript
describe('functionName', () => {
  it('should [behavior] when [condition]', () => {
    // Arrange - set up test data
    const input = { ... };

    // Act - call the function
    const result = functionUnderTest(input);

    // Assert - verify the result
    expect(result).toBe(expected);
  });
});
```

#### Test Categories (write all 4)
```typescript
describe('calculateTotal', () => {
  // 1. Happy path
  it('should calculate total for valid items', () => { ... });

  // 2. Edge cases
  it('should return 0 for empty cart', () => { ... });

  // 3. Error cases
  it('should throw for negative quantities', () => { ... });

  // 4. State transitions (if applicable)
  it('should update cart state after calculation', () => { ... });
});
```

### Happy Path Tunnel Vision Check

**STOP. After writing happy path tests, ask yourself:**

- [ ] What are the 3 failure modes from `/pre-mortem`? Did I test each?
- [ ] What happens with bad input? Empty input? Null input?
- [ ] What happens when external services fail?
- [ ] What would a malicious or confused user do?
- [ ] What timing/race conditions exist?

**If you only tested the success case, you have happy path tunnel vision.**

Run `/harden` if you haven't addressed failure modes in code yet.

### Step 4: Mock Dependencies

```typescript
// Mock external services at file top
jest.mock('@/firebase/config', () => ({
  db: { ref: jest.fn(), update: jest.fn() }
}));

jest.mock('./api');
const mockApi = api as jest.Mocked<typeof api>;

beforeEach(() => {
  mockApi.fetchData.mockResolvedValue({ id: 1 });
});
```

## Common Test Patterns

### Async Code
```typescript
it('should fetch user data', async () => {
  const user = await fetchUser(1);
  expect(user.name).toBe('John');
});
```

### Error Throwing
```typescript
it('should throw on invalid input', () => {
  expect(() => validate(null)).toThrow('Input required');
});

it('should reject with error', async () => {
  await expect(fetchUser(-1)).rejects.toThrow('Invalid ID');
});
```

### React Components
```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

it('should call onSubmit when form is valid', async () => {
  const onSubmit = jest.fn();
  render(<LoginForm onSubmit={onSubmit} />);

  await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');
  await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

  expect(onSubmit).toHaveBeenCalledWith({ email: 'test@example.com' });
});
```

## Output Format

```markdown
## Test Coverage Analysis: [Feature/Project]

### Coverage Summary
- Source files: X
- Test files: Y
- Coverage: Z%

### Critical Gaps
| File | Untested Functions | Priority |
|------|-------------------|----------|
| lib/game.ts | discardTile, submitCall | Critical |

### Generated Tests

#### lib/game.ts

\`\`\`typescript
describe('discardTile', () => {
  it('should remove tile from hand', () => { ... });
  it('should add tile to discard pile', () => { ... });
  it('should throw if tile not in hand', () => { ... });
});
\`\`\`

### Skipped (Low Priority)
- types.ts (type definitions only)
- config.ts (constants only)
```

## Principles

1. **Test behavior, not implementation** - What it does, not how
2. **One assertion per concept** - Keep tests focused
3. **Fast and isolated** - No dependencies between tests
4. **Meaningful coverage > 100%** - Focus on business logic

## Naming Convention

```
should [expected behavior] when [condition]
```

Examples:
- `should return empty array when input is null`
- `should throw ValidationError when email is invalid`
- `should redirect to dashboard when login succeeds`

## Next Step

Run `/docs-sync` to sync documentation before committing.

## Debugging Failing Tests

1. Read the error message carefully
2. Check if test is testing the right thing
3. Verify test data/mocks are correct
4. Run test in isolation: `it.only(...)`
5. Add console.logs or debugger
