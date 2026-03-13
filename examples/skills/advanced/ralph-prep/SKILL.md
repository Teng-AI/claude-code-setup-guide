---
name: ralph-prep
description: Optimize and validate prompts for Ralph Loop. Transforms vague task descriptions into structured, iteration-friendly prompts with clear completion criteria. Run before any /ralph-loop to maximize success rate.
---

# Ralph Prep

Transform a raw task idea into a Ralph-optimized prompt with clear completion criteria, self-verification loops, and appropriate safety settings.

> "Success depends on **operator skill**, not just model capability." — Ralph Wiggum philosophy

## When to Use

Run `/ralph-prep` before ANY Ralph loop to:
- Validate your prompt has clear completion criteria
- Add self-verification patterns
- Get recommended `--max-iterations` and `--completion-promise` values
- Split complex tasks into phases
- Catch common mistakes that cause infinite loops or failures

## The Problem with Raw Prompts

| Raw Prompt Problem | What Goes Wrong |
|-------------------|-----------------|
| "Build a todo API" | No success criteria — when is it "done"? |
| "Fix the bug" | No verification — how does Claude know it's fixed? |
| "Make it better" | Subjective — runs forever |
| "Implement auth" | Too broad — no phases, no checkpoints |

## The Ralph Prep Process

### Step 1: Task Classification

First, determine if the task is a good fit for Ralph:

**GREEN LIGHT (Use Ralph):**
- [ ] Has objectively verifiable success criteria (tests pass, endpoint returns X, etc.)
- [ ] Can run unattended
- [ ] Benefits from iteration
- [ ] Has automatic verification (test suite, linter, type checker)

**YELLOW LIGHT (Use with caution):**
- [ ] Success criteria exists but is complex
- [ ] Requires some human judgment
- [ ] No existing test suite (but one could be written)

**RED LIGHT (Don't use Ralph):**
- [ ] Subjective quality assessment ("make it look better")
- [ ] Requires human decisions mid-task
- [ ] Production debugging with real user data
- [ ] Time-sensitive (Ralph may iterate many times)
- [ ] No way to automatically verify success

### Step 2: Completion Criteria Analysis

Ask: **"How will Claude objectively know the task is complete?"**

| Criteria Type | Example | Reliability |
|---------------|---------|-------------|
| Tests passing | "npm test exits with 0" | High |
| Type check | "tsc --noEmit succeeds" | High |
| Lint passing | "eslint . has no errors" | High |
| Manual verification | "curl returns expected JSON" | Medium |
| Subjective | "code is clean" | Low — AVOID |

**Good completion criteria checklist:**
- [ ] Is it measurable? (not "works" but "returns 200 status")
- [ ] Is it objective? (not "looks good" but "passes accessibility audit")
- [ ] Can Claude verify it? (has command to run)
- [ ] Is it specific? (not "tests pass" but "all tests in /tests pass with >80% coverage")

### Step 3: Self-Verification Injection

Every Ralph prompt should include a verification loop:

```markdown
After each change:
1. Run [VERIFICATION_COMMAND]
2. If it fails, fix the issue before proceeding
3. Only move to the next step when verification passes
```

**Verification commands by task type:**

| Task Type | Verification Command |
|-----------|---------------------|
| API development | `curl -s localhost:3000/endpoint \| jq .` |
| TypeScript | `npx tsc --noEmit` |
| Tests | `npm test` |
| Linting | `npm run lint` |
| Build | `npm run build` |
| Full stack | `npm run build && npm test && npm run lint` |

### Step 4: Phase Breakdown (for complex tasks)

If the task takes >30 minutes or touches >5 files, break it into phases:

```markdown
## Phase 1: Foundation
- Set up project structure
- Install dependencies
- Verification: `npm install` succeeds

## Phase 2: Core Implementation
- Implement main logic
- Verification: unit tests pass

## Phase 3: Integration
- Wire up components
- Verification: integration tests pass

## Phase 4: Hardening
- Add error handling
- Verification: all tests pass including edge cases
```

### Step 5: Escape Hatch Configuration

**Always set `--max-iterations`:**

| Task Complexity | Recommended Max |
|-----------------|-----------------|
| Simple (1-2 files) | 5-10 |
| Medium (3-5 files) | 10-20 |
| Complex (6+ files) | 20-30 |
| Exploratory | 5 (fail fast) |

**Completion promise guidelines:**

| Phrase | When to Use |
|--------|-------------|
| `"DONE"` | Simple, clear tasks |
| `"All tests passing"` | TDD-style development |
| `"Build successful"` | Compilation-focused tasks |
| `"API verified working"` | API development |
| Custom phrase | Match what Claude would naturally say |

### Step 6: Output the Optimized Prompt

Generate a structured prompt using this template:

```markdown
## Task: [CLEAR_TITLE]

### Requirements
- [Specific requirement 1]
- [Specific requirement 2]
- [Specific requirement 3]

### Success Criteria
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Measurable criterion 3]

### Verification Loop
After each implementation step:
1. Run: `[VERIFICATION_COMMAND]`
2. If it fails, debug and fix before proceeding
3. Only continue when verification passes

### Phases (if complex)
1. [Phase 1]: [Goal] — Verify with: `[command]`
2. [Phase 2]: [Goal] — Verify with: `[command]`
3. [Phase 3]: [Goal] — Verify with: `[command]`

### Completion Signal
When ALL success criteria are met, output: <promise>[PHRASE]</promise>
```

## Output Format

After running `/ralph-prep`, output:

```markdown
## Ralph Prep Analysis

### Task Classification
- Fit for Ralph: [GREEN/YELLOW/RED]
- Reason: [Why this classification]

### Issues Found
- [ ] [Issue 1 and fix]
- [ ] [Issue 2 and fix]

### Optimized Prompt

[THE RESTRUCTURED PROMPT]

### Recommended Command

/ralph-loop:ralph-loop "[OPTIMIZED_PROMPT]" --completion-promise "[PHRASE]" --max-iterations [N]

### Warnings (if any)
- [Any risks or considerations]
```

## Examples

### Example 1: Vague API Task

**Input:** "Build a todo API"

**Output:**
```markdown
## Ralph Prep Analysis

### Task Classification
- Fit for Ralph: GREEN
- Reason: Has testable endpoints, can verify with curl

### Issues Found
- [x] No specific endpoints defined → Added CRUD endpoints
- [x] No data model specified → Added todo schema
- [x] No verification method → Added curl checks

### Optimized Prompt

## Task: Build a REST API for Todos

### Requirements
- Express.js server on port 3000
- Endpoints: GET/POST/PUT/DELETE /api/todos
- Todo schema: { id, title, completed, createdAt }
- Input validation on POST/PUT
- Proper error responses (400, 404, 500)

### Success Criteria
- [ ] GET /api/todos returns array
- [ ] POST /api/todos creates and returns new todo
- [ ] PUT /api/todos/:id updates and returns todo
- [ ] DELETE /api/todos/:id returns 204
- [ ] Invalid input returns 400
- [ ] Missing todo returns 404

### Verification Loop
After implementing each endpoint:
1. Run: `curl -s http://localhost:3000/api/todos | jq .`
2. Test the specific endpoint manually
3. Only proceed when endpoint works correctly

### Completion Signal
When all endpoints verified working, output: <promise>All endpoints verified working</promise>

### Recommended Command

/ralph-loop:ralph-loop "Build a REST API for Todos [full prompt above]" --completion-promise "All endpoints verified working" --max-iterations 15
```

### Example 2: Bug Fix Task

**Input:** "Fix the login bug"

**Output:**
```markdown
## Ralph Prep Analysis

### Task Classification
- Fit for Ralph: YELLOW
- Reason: Need to identify bug first, but can verify with tests

### Issues Found
- [x] Bug not specified → Need to identify first
- [x] No reproduction steps → Add investigation phase
- [x] No verification → Add test requirement

### Optimized Prompt

## Task: Investigate and Fix Login Bug

### Phase 1: Investigation
1. Read error logs and identify the bug
2. Create a failing test that reproduces the issue
3. Document the root cause

### Phase 2: Fix
1. Implement the fix
2. Verify the failing test now passes
3. Ensure no regression in other auth tests

### Success Criteria
- [ ] Root cause documented
- [ ] Failing test created
- [ ] Fix implemented
- [ ] All auth tests pass: `npm test -- --grep "auth"`

### Verification Loop
After each change:
1. Run: `npm test -- --grep "auth"`
2. If tests fail, debug before proceeding

### Completion Signal
When all auth tests pass, output: <promise>Auth tests passing</promise>

### Recommended Command

/ralph-loop:ralph-loop "Investigate and Fix Login Bug [full prompt above]" --completion-promise "Auth tests passing" --max-iterations 10

### Warnings
- Bug must be reproducible — if intermittent, Ralph may not converge
- Consider adding regression test to prevent future occurrence
```

### Example 3: Poor Fit Task

**Input:** "Make the UI look better"

**Output:**
```markdown
## Ralph Prep Analysis

### Task Classification
- Fit for Ralph: RED
- Reason: Subjective criteria, no automatic verification

### Issues Found
- [x] "Better" is subjective — no objective measure
- [x] UI quality requires human judgment
- [x] No automated verification possible

### Recommendation

DO NOT use Ralph for this task. Instead:

1. **Define specific, measurable goals:**
   - "Add consistent 16px padding to all cards"
   - "Implement dark mode toggle"
   - "Fix mobile responsiveness on screens <768px"

2. **Use human review:**
   - Make changes manually
   - Get feedback
   - Iterate based on feedback

3. **If you must automate:**
   - Run Lighthouse accessibility audit
   - Use visual regression testing
   - Define specific CSS changes needed

### Alternative Ralph-Friendly Reframe

If you can define specific changes:

/ralph-loop:ralph-loop "Implement dark mode: add CSS variables for colors, create theme toggle, ensure all components use variables" --completion-promise "Dark mode working" --max-iterations 10
```

## Quick Reference: Prompt Smells

| Smell | Problem | Fix |
|-------|---------|-----|
| "Make it work" | No success criteria | Define "working" as specific tests |
| "Improve X" | Subjective | List specific improvements |
| "Fix the bug" | Bug not identified | Add investigation phase |
| "Build X" (no specs) | No requirements | Add explicit requirements |
| "Clean up" | Vague scope | List specific changes |
| "Optimize" | No metric | Define target metric (e.g., <100ms) |

## Integration with Other Skills

```
/ralph-prep     → Optimize prompt (THIS SKILL)
    ↓
/ralph-loop     → Run the loop
    ↓
/ralph-loop:cancel-ralph  → Emergency stop if needed
```

## When to Skip

You can skip `/ralph-prep` if:
- Task is extremely simple (< 5 minute task)
- You've run this exact type of Ralph before
- Prompt already has all components (criteria, verification, phases)

When in doubt, run `/ralph-prep`. A 2-minute prep prevents a 2-hour infinite loop.
