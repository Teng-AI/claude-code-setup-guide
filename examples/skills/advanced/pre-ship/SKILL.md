---
name: pre-ship
description: Production readiness checklist before deploying. Checks the gap between "it works" and "production-ready". REQUIRED before any deploy to production.
---

# Pre-Ship Checklist

"It works" ≠ "Production-ready"

This checklist bridges the gap. Run it before EVERY production deploy.

## The Production Gap

| "It Works" (Dev) | Production-Ready | This Checklist Verifies |
|------------------|------------------|-------------------------|
| Happy path works | Errors handled gracefully | Error handling section |
| Works locally | Works for 1000 concurrent users | Scale section |
| Works today | Works after 6 months | Time section |
| You understand it | Others can understand it | Comprehension section |
| Manual deploy | Automated deploy | Deployment section |
| Users find bugs | Tests find bugs | Testing section |

## Prerequisites Check

Before running this checklist, verify these were completed:

| Skill | Required If... | Completed? |
|-------|----------------|------------|
| `/pre-implement` | Task was non-trivial | [ ] |
| `/harden` | Feature has external deps | [ ] |
| `/tests` | Feature has logic | [ ] |
| `/docs` | Files were changed | [ ] |

**If any required skills were skipped, note them below. They're risks.**

## The Pre-Ship Checklist

### 1. Error Handling

- [ ] **API failures** show user-friendly errors (not stack traces)
- [ ] **Network issues** handled (offline, timeout, slow connection)
- [ ] **Invalid data** doesn't crash the app (validation exists)
- [ ] **Auth failures** redirect appropriately (not blank screen)
- [ ] **Error boundaries** catch React crashes (if applicable)

**Test:** Disconnect network and try core flows. What happens?

### 2. Scale

- [ ] **No N+1 queries** (check database calls in loops)
- [ ] **Pagination** for large lists (not loading 10,000 items)
- [ ] **Rate limiting** considered for APIs
- [ ] **Caching** for expensive operations
- [ ] **Bundle size** checked (no huge imports)

**Test:** What happens with 10x the expected data/users?

### 3. Time

- [ ] **Auth tokens** have refresh logic (won't expire and break)
- [ ] **Caches** have invalidation (won't serve stale data forever)
- [ ] **Scheduled jobs** handle failures (won't silently stop)
- [ ] **Data accumulation** considered (tables won't grow unbounded)
- [ ] **Dependencies** are pinned (won't break on auto-update)

**Test:** What happens 6 months from now without any changes?

### 4. Understandability

- [ ] **Code reviewed** by at least one other person
- [ ] **Critical logic** has comments explaining "why"
- [ ] **README** updated with any new setup steps
- [ ] **CHANGELOG** documents what changed
- [ ] **Non-obvious behavior** documented

**Test:** Could a new developer understand this in 6 months?

### 5. Deployment

- [ ] **CI/CD** runs tests on every PR
- [ ] **Build passes** (no warnings treated as errors)
- [ ] **Environment variables** documented and set
- [ ] **Database migrations** are reversible (if applicable)
- [ ] **Rollback plan** exists and documented

**Test:** What's the rollback procedure if this breaks prod?

### 6. Monitoring

- [ ] **Errors are logged** (not swallowed silently)
- [ ] **Key metrics** are tracked (if applicable)
- [ ] **Alerts** set up for critical failures
- [ ] **Health check** endpoint exists (if applicable)

**Test:** How would you know if this broke in production?

### 7. Security (Quick Check)

- [ ] **No secrets** in code or logs
- [ ] **Input sanitized** where it touches database/HTML
- [ ] **Auth required** for protected endpoints
- [ ] **CORS/CSP** configured appropriately

For thorough security review, run `/security-check`.

### 8. User Experience

- [ ] **Loading states** for async operations
- [ ] **Error messages** are helpful (not "Something went wrong")
- [ ] **Empty states** are designed (not just blank)
- [ ] **Mobile/responsive** works (if applicable)
- [ ] **Accessibility** basics covered (if applicable)

## Output Format

```markdown
## Pre-Ship: [Feature/Release Name]

### Prerequisites
| Skill | Status |
|-------|--------|
| /pre-implement | ✅ Completed |
| /harden | ✅ Completed |
| /tests | ✅ Completed |
| /docs | ⚠️ Skipped (no doc changes needed) |

### Checklist Results

#### Error Handling
- [x] API failures handled
- [x] Network issues handled
- [x] Invalid data validated
- [x] Auth failures redirect
- [ ] Error boundaries — N/A (not React)

#### Scale
- [x] No N+1 queries
- [x] Pagination implemented
- [ ] Rate limiting — TODO: Add before launch
- [x] Caching in place
- [x] Bundle size checked (142kb gzipped)

#### Time
- [x] Token refresh logic
- [x] Cache invalidation
- [ ] Scheduled jobs — N/A
- [x] Data cleanup plan
- [x] Dependencies pinned

#### Understandability
- [x] Code reviewed by @teammate
- [x] Complex logic commented
- [x] README updated
- [x] CHANGELOG updated
- [x] Architecture decision documented

#### Deployment
- [x] CI runs tests
- [x] Build passes
- [x] Env vars documented
- [ ] Migrations — N/A
- [x] Rollback: Revert commit, redeploy

#### Monitoring
- [x] Errors logged to Sentry
- [x] Key metrics in dashboard
- [x] PagerDuty alert for errors >1%
- [x] Health check endpoint

#### Security
- [x] No secrets in code
- [x] Input sanitized
- [x] Auth on all endpoints
- [x] CORS configured

#### UX
- [x] Loading states
- [x] Helpful error messages
- [x] Empty states designed
- [x] Responsive tested
- [x] Basic a11y (labels, contrast)

### Gaps Found
| Gap | Risk | Action |
|-----|------|--------|
| No rate limiting | API abuse possible | Add before public launch |

### Rollback Plan
1. Revert PR #123
2. Deploy previous version
3. Verify with smoke test

### Verdict
- [x] Ship it — all critical items pass
- [ ] Fix gaps first — blocking issues found
- [ ] Needs redesign — fundamental problems
```

## Quick Pre-Ship (Emergency)

If you're in a rush, at minimum verify:

```
[ ] Tests pass
[ ] Errors don't crash app
[ ] Rollback plan exists
[ ] Someone else looked at the code
```

This is the bare minimum. Full checklist is strongly preferred.

## Integration with Other Skills

```
Development complete
    ↓
/harden → Error handling added
    ↓
/tests → Test coverage
    ↓
/docs → Documentation synced
    ↓
/pre-ship (THIS SKILL) → Production readiness
    ↓
/security-check → If security-sensitive
    ↓
Deploy
```

## When to Skip

Never skip for production deploys.

You can do a lighter check for:
- Staging/preview deploys
- Internal tools with limited users
- Hotfixes (but review after)

Even then, at minimum verify tests pass and rollback exists.

## Post-Ship

After deploying:
1. Watch error rates for 15-30 minutes
2. Verify key flows work in production
3. Check monitoring dashboards
4. Be ready to rollback if needed

The deploy isn't done until you've verified it's working.
