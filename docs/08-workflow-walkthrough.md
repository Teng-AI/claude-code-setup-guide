# Workflow Walkthrough: End-to-End Example

This walkthrough follows a realistic scenario from start to finish. The task: add a user notification feature to an existing Next.js project with user accounts. You need to integrate a notifications API, build a preferences UI, and wire it all together.

---

## Step 1: Start the Session

**Run:** `/session-start`

```
Git: on branch main, clean working tree, last commit 2h ago
Build: passing | Tests: 47 passing, 0 failing
Learnings: 12 entries loaded (last: 2026-03-10)
Roadmap: User notifications is next (priority 1 for v1.2)
```

Saves you from starting work on a broken build or dirty working tree.

---

## Step 2: Research the Unfamiliar API

**Run:** `/learn notifications API`

```
Concepts: Channels configured per-user; events sent to central endpoint; templates defined server-side
Gotchas: Rate limit 100 req/min (need queuing), HMAC-SHA256 webhook verification, strict template variables (400 on missing)
Patterns: Use a NotificationService wrapper, queue bulk sends, store preferences in your own DB
Saved to: docs/learning-notes/notifications-api.md
```

---

## Step 3: Plan the Implementation

**Run:** `/pre-implement`

```
> What else does this touch? User settings page, user model, API routes, email service, env vars
> 3 ways this could fail? API down during burst, silent DB write failure, broken email templates
> One sentence: "Send notifications to users based on their stored preferences."
> Where does state live? Preferences in PostgreSQL (user changes via UI), queue in memory (risk: lost on restart)
> How to undo? Feature flag. Disable flag, no data loss.

Plan: NotificationService wrapper, notification_preferences table, /api/notifications/preferences endpoint, PreferencesPanel component, ENABLE_NOTIFICATIONS feature flag
Saved to: strategy.md
```

---

## Step 4: Implement the Feature

With the plan from Step 3, write the code. Claude follows the strategy document, references learning notes from Step 2 (respects rate limits, validates template variables), and builds the service, types, migration, API route, and UI component.

---

## Step 5: Harden the Code

**Run:** `/harden`

```
Error handling: Retry with backoff on API errors, input validation with zod schemas, try/catch on template assembly
Input validation: Email format check, event_type enum validation, request body schema
UI states: Loading, error, empty, success states; disabled submit during API calls
Resilience: Circuit breaker (opens after 5 failures), DB-backed queue fallback at 1000 items
8 files modified.
```

This is where the happy-path prototype becomes production-worthy code.

---

## Step 6: Write Tests

**Run:** `/tests`

```
Unit: NotificationService.test.ts (14 tests) -- send, retry, circuit breaker, rate limiting
Unit: PreferencesPanel.test.tsx (8 tests) -- render states, save, validation
Integration: preferences.test.ts (6 tests) -- GET/PUT, invalid input, auth checks
Coverage: 89% on new code. Gap: circuit breaker half-open transition (noted in test file).
28 tests across 3 files.
```

---

## Step 7: Sync Documentation

**Run:** `/docs`

```
README.md: Added Notifications section, documented feature flag and env vars
CHANGELOG.md: Added entry under [Unreleased]
docs/api.md: Documented /api/notifications/preferences with request/response examples
.env.example: Added NOTIFICATION_API_KEY and NOTIFICATION_API_URL
4 files updated.
```

---

## Step 8: Pre-Ship Check

**Run:** `/pre-ship`

```
[PASS] Error handling, scale, time, understandability, deployment, security
[FLAG] Monitoring: No alerting for notification delivery failures. Add log-based alert for circuit breaker opens.
[FLAG] Queue durability: In-memory queue loses items on restart. Consider defaulting to DB-backed queue.
Decision: GO with flags noted. Address monitoring before enabling for all users.
```

---

## Step 9: Wrap Up the Session

**Run:** `/wrap-up`

```
Completed: User notification feature (ROADMAP.md item 1/3 for v1.2)
Skills used: session-start, learn, pre-implement, harden, tests, docs, pre-ship (none skipped)
Learnings added: Notification API returns 400 for missing template variables -- always validate first
Follow-up: Alerting for circuit breaker, evaluate DB-backed queue default, push notifications (v1.3)
Commit: feat: add user notification system with preferences UI
```

---

## Key Takeaways

- Each skill builds on the previous one. Learning notes inform the plan, the plan shapes implementation, hardening catches gaps, tests verify hardened code, pre-ship catches operational concerns.
- You do not need every skill every time. A quick bug fix might only need `/session-start` and `/wrap-up`. Match rigor to risk.
- The workflow prevents the most common engineering mistakes: shipping without planning, skipping error handling, deploying without checks.
- Start with `/session-start`, `/pre-implement`, and `/wrap-up`. Add `/harden` and `/tests` once those are habitual. Build incrementally.
