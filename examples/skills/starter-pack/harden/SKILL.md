---
name: harden
description: Add error handling, validation, and logging after a feature works. Prevents "skipping the boring parts" anti-pattern. Run after feature works, before tests.
---

# Harden

The feature works on the happy path. Now make it production-ready.

**"Skipping the boring parts" is the #4 anti-pattern.** This skill ensures you don't.

## When to Use

Run `/harden` when:
- Feature works on happy path but has no error handling
- Before writing tests (testing unhardened code misses failure cases)
- After implementing anything with external dependencies
- When you realize you skipped error handling
- Before any code review

## Prerequisites

- Feature works on happy path (manually verified)
- `/pre-mortem` was run (failure modes identified)

If `/pre-mortem` wasn't run, quickly identify: "What are 3 ways this could fail?"

## The Hardening Checklist

### 1. Error Handling

Review failure modes from `/pre-mortem` and add handling for each:

| Failure Mode | Handling Required |
|--------------|-------------------|
| API returns error | Try/catch, show user-friendly message |
| API is slow (>5s) | Timeout, loading indicator |
| API is down | Retry logic, fallback, or clear error |
| Network offline | Detect, queue or show offline state |
| Invalid data returned | Validation, safe defaults |
| Rate limited | Backoff, user notification |

**For each external call, ask:** "What happens when this fails?"

```typescript
// ❌ Unhardened
const data = await fetchUser(id);
return data.name;

// ✅ Hardened
try {
  const data = await fetchUser(id);
  if (!data || !data.name) {
    return 'Unknown User';
  }
  return data.name;
} catch (error) {
  console.error('Failed to fetch user:', { id, error });
  throw new UserFetchError('Unable to load user data');
}
```

### 2. Input Validation

At system boundaries (user input, API responses, function parameters):

```typescript
// ❌ Unhardened
function processOrder(order) {
  return order.items.map(item => item.price * item.quantity);
}

// ✅ Hardened
function processOrder(order) {
  if (!order) throw new ValidationError('Order is required');
  if (!Array.isArray(order.items)) throw new ValidationError('Order items must be an array');
  if (order.items.length === 0) return [];

  return order.items.map(item => {
    const price = Number(item.price) || 0;
    const quantity = Math.max(0, Math.floor(Number(item.quantity) || 0));
    return price * quantity;
  });
}
```

**Validation checklist:**
- [ ] Required fields present?
- [ ] Correct data types?
- [ ] Within valid ranges?
- [ ] Safe from injection? (if user input)

### 3. Logging

Add logging for future debugging:

```typescript
// Entry/exit of critical functions
console.log('Starting payment processing:', { orderId, amount });

// Errors with context (not just message)
console.error('Payment failed:', {
  orderId,
  amount,
  error: error.message,
  stack: error.stack
});

// State transitions
console.log('Order status changed:', { orderId, from: oldStatus, to: newStatus });
```

**Logging checklist:**
- [ ] Critical function entry/exit
- [ ] Errors with full context
- [ ] State transitions
- [ ] External API calls and responses

### 4. UI States (if applicable)

Every async operation needs:

| State | Implementation |
|-------|----------------|
| **Loading** | Spinner, skeleton, disabled button |
| **Error** | Error message, retry option |
| **Empty** | Helpful empty state, not blank |
| **Offline** | Clear indicator, queued actions |

```typescript
// ❌ Unhardened
{data.map(item => <Item {...item} />)}

// ✅ Hardened
{isLoading && <Spinner />}
{error && <ErrorMessage message={error} onRetry={refetch} />}
{!isLoading && !error && data.length === 0 && <EmptyState />}
{!isLoading && !error && data.map(item => <Item {...item} />)}
```

### 5. Edge Cases

Review edge cases from `/pre-implement`:

- [ ] Empty arrays/objects
- [ ] Null/undefined values
- [ ] Very large inputs
- [ ] Concurrent operations
- [ ] Rapid user actions (double-click, spam)

## Output Format

After hardening, document what was added:

```markdown
## Hardening Summary: [Feature Name]

### Error Handling Added
| Failure Mode | Handling |
|--------------|----------|
| API failure | Try/catch with user-friendly error toast |
| Invalid response | Validation with safe defaults |

### Input Validation Added
| Input | Validation |
|-------|------------|
| orderId | Required, must be string |
| amount | Required, must be positive number |

### Logging Added
- Payment processing entry/exit
- Error logging with full context

### UI States Added
- [x] Loading spinner
- [x] Error state with retry
- [x] Empty state

### Edge Cases Handled
- [x] Empty cart returns early
- [x] Double-click prevention on submit

### Ready for Testing
- [ ] Run `/tests` to cover these cases
```

## Common Hardening Patterns

### API Call
```typescript
async function fetchWithHardening(url) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 5000);

  try {
    const response = await fetch(url, { signal: controller.signal });
    clearTimeout(timeout);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new Error('Request timed out');
    }
    throw error;
  }
}
```

### Form Submission
```typescript
const [isSubmitting, setIsSubmitting] = useState(false);

async function handleSubmit(e) {
  e.preventDefault();
  if (isSubmitting) return; // Prevent double-submit

  setIsSubmitting(true);
  setError(null);

  try {
    await submitForm(data);
    onSuccess();
  } catch (error) {
    setError(error.message);
  } finally {
    setIsSubmitting(false);
  }
}
```

## Integration with Other Skills

```
/pre-mortem → Identifies failure modes
    ↓
Implement feature (happy path)
    ↓
/harden → Adds error handling for failure modes (THIS SKILL)
    ↓
/tests → Tests both happy path AND failure cases
```

## When to Skip

You can skip `/harden` for:
- Pure utility functions with no external dependencies
- Prototype/throwaway code
- Code that already has comprehensive error handling

When in doubt, run the checklist. Production bugs from missing error handling are expensive.
