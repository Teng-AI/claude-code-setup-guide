---
name: pre-mortem
description: Imagine the solution already failed and surface risks
---

# /pre-mortem - Pre-Implementation Risk Analysis

When invoked, assume the feature has already been built and deployed -- and it caused a production incident. Work backwards to identify what went wrong.

## Framing

> "It's 2 weeks from now. This feature has caused a production incident. What went wrong?"

This inversion is deliberate. It's easier to imagine specific failures than to generically "think about risks." A pre-mortem surfaces problems that optimism hides.

## When to Use

- Before touching production data or databases.
- Before implementing payment or billing logic.
- Before changing authentication or authorization.
- Before any feature that handles sensitive user data.
- Before a major architectural change.
- Anytime the blast radius of a failure is high.

## Steps

### 1. List All Failure Modes

Brainstorm every way this could fail. Don't filter yet. Consider each category:

**Technical failures:**
- What if the database write partially fails?
- What if a network request times out or returns an unexpected response?
- What if concurrent users hit a race condition?
- What if the data is malformed, too large, or missing required fields?
- What if a third-party service goes down?
- What if the migration fails halfway through?

**Data failures:**
- What if existing data doesn't match the expected schema?
- What if there are edge cases in production data that don't exist in test data?
- What if a user has null/empty values where you expect data?
- What if the data volume is 10x what you tested with?

**User experience failures:**
- What if the user double-clicks or submits twice?
- What if the user navigates away mid-operation?
- What if the user has stale data in their browser/app?
- What if error messages expose internal details?

**Security failures:**
- What if an unauthorized user accesses this endpoint?
- What if input isn't sanitized?
- What if tokens or secrets are logged or exposed?
- What if rate limiting is missing?

**Operational failures:**
- What if you need to roll back this change?
- What if you need to fix data that was corrupted by this change?
- What if monitoring doesn't catch the failure quickly?

### 2. Rate Each Failure

For each failure mode, assess:

| Rating | Likelihood | Impact |
|--------|-----------|--------|
| High | Likely to happen within the first week | Data loss, security breach, financial impact |
| Medium | Could happen under certain conditions | Degraded experience, manual intervention needed |
| Low | Unlikely but possible | Minor inconvenience, easily recoverable |

### 3. Identify Preventable Failures

For each failure rated Medium or High in either dimension:
- Can this be prevented by code changes before deployment?
- Can this be detected quickly with monitoring or alerts?
- Can this be mitigated with a feature flag or rollback plan?

### 4. Add Mitigations

For each preventable failure, specify the concrete mitigation:

- **Validation**: input checking, schema validation, type guards.
- **Error handling**: try/catch, retries with backoff, graceful degradation.
- **Transactions**: database transactions, idempotency keys, compensation logic.
- **Monitoring**: alerts on error rates, latency spikes, data anomalies.
- **Rollback plan**: feature flags, database migration rollback scripts, manual data fix procedures.
- **Testing**: specific test cases that exercise the failure mode.

### 5. Decide on Blockers

Some risks are acceptable. Some are not. Decide:
- **Blocker**: must be mitigated before shipping. (e.g., potential data loss, security vulnerability)
- **Accept with monitoring**: ship it, but watch closely. (e.g., edge case that affects <1% of users)
- **Accept**: risk is low enough to not warrant action. (e.g., cosmetic issue under rare conditions)

## Output Format

```
## Pre-Mortem: [Feature Name]

### Failure Modes
| # | Failure | Category | Likelihood | Impact | Decision |
|---|---------|----------|-----------|--------|----------|
| 1 | [description] | [technical/data/UX/security/ops] | H/M/L | H/M/L | blocker/monitor/accept |

### Mitigations Required (Blockers)
- [Failure #]: [specific mitigation to implement]

### Mitigations Recommended (Monitor)
- [Failure #]: [monitoring or alerting to add]

### Rollback Plan
[How to undo this change if it goes wrong in production]

### Remaining Accepted Risks
- [Failure #]: [why it's acceptable]
```

## Rules

- Be pessimistic. The point is to find problems, not to reassure yourself.
- Every failure mode should be specific, not vague. "Something could go wrong with the database" is not useful. "A partial write could leave an order in a state where it has line items but no total" is useful.
- Blockers must be resolved before implementation proceeds. If a blocker can't be mitigated, reconsider the approach.
- A rollback plan is not optional. Every production change needs one.
