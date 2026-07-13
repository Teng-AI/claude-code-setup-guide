---
name: refactor
description: Systematic refactoring checklist for cleaning up code safely. Use when user says "clean this up", "refactor this", "this code is messy", "improve code quality", or before/after major feature work.
---

# Refactor

A systematic approach to cleaning up code without breaking things.

## When to Use

- Code feels messy or hard to understand
- Before adding features to tangled code
- After rapid prototyping ("make it work" → "make it right")
- When you keep having bugs in the same area
- Technical debt paydown

## The Golden Rule

**Refactoring = changing structure WITHOUT changing behavior.**

If you're adding features or fixing bugs, that's not refactoring. Do those separately.

## Pre-Refactor Checklist

Before touching anything:

```
□ Tests exist and pass (or write them first)
□ You understand what the code does
□ You have a clear goal (not just "make it better")
□ Changes are committed (clean starting point)
```

**No tests? Write them first.** Refactoring without tests is risky.

## Refactoring Process

### Step 1: Identify the Problem

What specifically is wrong?

| Smell | Symptom | Self-Check | Typical Fix |
|-------|---------|------------|-------------|
| **Does too much** | Function handles multiple concerns | Can't describe without "and" | Split by responsibility |
| **Long function** | >30 lines, hard to follow | Needs scrolling to read | Extract smaller functions |
| **Deep nesting** | 3+ levels of if/for | Hard to trace logic | Early returns, extract logic |
| **Duplicate code** | Same logic in multiple places | Copy-paste detected | Extract shared function |
| **God object** | One class/file does everything | File is huge, touches many concerns | Split by responsibility |
| **Unclear naming** | `data`, `temp`, `x` | Can't understand without context | Rename to intent |
| **Magic numbers** | `if (status === 3)` | Number meaning unclear | Named constants |
| **Long parameter list** | 4+ params | Function signature is unwieldy | Use options object |
| **Feature envy** | Function uses another object's data heavily | Lots of `other.x`, `other.y` | Move function to that object |
| **Unclear state ownership** | Multiple things change same state | "Who owns this?" unclear | Single owner pattern |

**The #1 Smell: Separation of Concerns Violation**

Apply this test to every function:
> "Can I describe what this function does in ONE sentence WITHOUT using 'and'?"

- ❌ "This function fetches user data AND formats it for display AND updates the cache"
- ✅ "This function fetches user data from the API"

If you need "and", the function does too much. Split it.

### Step 2: Plan the Change

```markdown
**What**: [Specific refactoring to apply]
**Why**: [What problem it solves]
**Risk**: [What could break]
**Test**: [How to verify it still works]
```

### Step 3: Small Steps

**One change at a time:**
1. Make one small refactoring
2. Run tests
3. Commit if green
4. Repeat

**Never:**
- Refactor multiple things at once
- Refactor and add features in same commit
- Continue if tests fail

### Step 4: Verify

After refactoring:
```
□ All tests still pass
□ Behavior is identical
□ Code is measurably better (not just different)
□ You can explain why it's better
```

## Common Refactorings

### Extract Function
```typescript
// Before
function processOrder(order) {
  // 50 lines of validation
  // 30 lines of calculation
  // 20 lines of formatting
}

// After
function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order);
  return formatOrder(order, total);
}
```

### Early Return
```typescript
// Before
function getDiscount(user) {
  if (user) {
    if (user.isPremium) {
      if (user.years > 5) {
        return 0.2;
      } else {
        return 0.1;
      }
    } else {
      return 0;
    }
  } else {
    return 0;
  }
}

// After
function getDiscount(user) {
  if (!user) return 0;
  if (!user.isPremium) return 0;
  if (user.years > 5) return 0.2;
  return 0.1;
}
```

### Replace Magic Numbers
```typescript
// Before
if (order.status === 3) { ... }

// After
const ORDER_STATUS = { PENDING: 1, PROCESSING: 2, COMPLETE: 3 };
if (order.status === ORDER_STATUS.COMPLETE) { ... }
```

### Options Object
```typescript
// Before
function createUser(name, email, age, role, team, startDate) { ... }

// After
function createUser({ name, email, age, role, team, startDate }) { ... }
```

## Anti-Patterns

### 1. Refactoring Without Tests
❌ "I'll just clean this up real quick..."
✅ Write tests first, then refactor

### 2. Big Bang Refactor
❌ Rewriting entire modules at once
✅ Small incremental changes

### 3. Refactoring During Feature Work
❌ "While I'm here, let me also clean up..."
✅ Separate commits: refactor first, then feature

### 4. Subjective "Improvements"
❌ "I think this style is better"
✅ Measurable improvement (less code, clearer names, fewer branches)

## Output Format

```markdown
## Refactoring Plan: [Area/File]

### Current Problems
1. [Smell]: [Where and why it's a problem]
2. [Smell]: [Where and why it's a problem]

### Proposed Changes
| Change | Type | Risk |
|--------|------|------|
| [Description] | Extract function | Low |
| [Description] | Rename | Low |

### Execution Order
1. [ ] [First change] → test
2. [ ] [Second change] → test
3. [ ] [Third change] → test

### Success Criteria
- [ ] All tests pass
- [ ] [Specific improvement metric]
```

## When NOT to Refactor

- No tests and no time to write them
- You don't understand what the code does
- It works and you're not touching it soon
- Deadline pressure (refactor after, not during)
- Purely aesthetic preference
