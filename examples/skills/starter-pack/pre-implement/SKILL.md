---
name: pre-implement
description: Planning workflow before implementing any non-trivial build — code, skills, doc pipelines, or audit/probe tools. Use when starting work on a new feature, bug fix, skill, or significant change. Forces research and design before building, and includes a required pre-mortem step (imagine the shipped solution failed; surface risks, wrong assumptions, and failure modes while course corrections are still cheap).
---

# Pre-Implementation Planning

Research first, design second, build third. Applies to code, skills, doc pipelines, and audit tools alike — "production" below means wherever the thing runs for real (a repo, a teammate's machine, a shared doc someone else reads).

## When to Use

Run `/pre-implement` before any task that takes more than ~30 minutes, touches more than 2-3 files, involves external services, has unclear requirements, or could be built more than one way.

**Skip for:** typo fixes, single-line changes, debugging probes, tasks explicitly defined with no ambiguity. When in doubt, run it.

## Step 0: Consume What Already Exists

Do not re-ask what's already decided.

- **Grill record?** Check `brainstorms/` for a `/grill-me` record on this task. Its decisions are inputs, not open questions. Only surface a question if the record is silent or contradicts the repo.
- **Prior plan?** If a `plans/` dir for this task exists from an earlier session, a plan is a point-in-time snapshot — **re-validate it against the current repo before executing** (files it names still exist, assumptions still hold, nothing shipped in between). Never execute a stale plan on trust.

## Prerequisites

- **State/sync/real-time involved?** Map the state up front: where each piece lives, what writes it, how other components learn it changed, what happens when copies disagree. Diagram it if complex — before designing, not during implementation.
- **Unfamiliar library/API?** Read the official docs first. Note update/merge semantics, rate limits, auth quirks, documented gotchas.
- **Building a checker, probe, linter, or audit step?** Read `~/.claude/references/control-testing.md` first. An unvalidated negative reads as proof; every check needs a positive control.

## Phase 1: Understand

1. **What exactly needs to happen?** One-sentence description, acceptance criteria, edge cases.
2. **What already exists?** Search the codebase and the archive repos for related code and precedents. Similar patterns beat green-field designs.
3. **What are the dependencies?** External services, libraries, documented gotchas.
4. **What else does this touch?** Other components that interact with it; what happens when they fail or slow down.

## Phase 2: Design

5. **Approach + trade-offs.** If more than one viable approach, table them:

   | Approach | Pros | Cons | What You Give Up |
   |----------|------|------|------------------|

   Name the chosen one and why the trade-off is acceptable.
6. **Files to change.** List them. Pseudocode any complex logic.
7. **Failure handling.** Bad input, external service down, partial completion.
8. **Revert path.** How do we undo this if it's wrong? If it writes to someone else's system (Drive, Notion, Linear, a shared repo), the house rule applies: move-map + revert path before executing, verify by querying back.
9. **What proves it works?** Define the checks before building. For a skill, that's a `test-cases.md` battery you run it against; for code, test cases including error and edge paths; for a pipeline, a known-answer run.

## Phase 3: Pre-Mortem and Confirmation

10. **Pre-mortem (required).** Imagine it's 3 months out and this failed badly. Work backwards:
    - Top 3-5 failure modes. Sweep: data integrity (runs twice, partial completion, races), external dependencies (slow, down, changed shape, expired credentials), scale, edge cases, security, operations (how would we even know it broke?).
    - Every assumption the plan makes, and what happens if each is wrong. **Verify the risky ones empirically before building** — a 5-minute test against real data beats ship-and-watch.
    - For each high-impact risk: a cheap course correction now (mitigation, monitoring signal, or rollback path).
    - Verdict: safe to proceed / proceed with required mitigations / redesign.

    A solution that "feels too easy" is the strongest signal to slow down here.

11. **Review.** Aligns with existing patterns? Simplest thing that works? All phases answered?
12. **Confirm.** Present the plan — including the pre-mortem verdict — to the user before building.

## Output: Persist the Plan

Write the plan to `plans/active/<task-name>/` in the project root. Two tiers:

**Default — single `plan.md`** covering everything in one file:

```markdown
# Plan: [Task Name]

## Problem
[One sentence. Grill record: brainstorms/... if one exists]

## Approach
[Chosen approach + why; trade-off table if there was a real choice]

## Files to Change
| File | Change | Description |
|------|--------|-------------|

## Pre-Mortem
- Failure modes: ...
- Risky assumptions + empirical checks run: ...
- Verdict: [safe / proceed with mitigations / redesign]

## Proof
[Test cases / battery / known-answer run that shows it works]

## Progress
- [ ] ...   ← keep current; this is what a resumed session reads first
```

**Escalate to three files** (`strategy.md` / `findings.md` / `progress.md`) only when the work will span multiple sessions or run in an autonomous loop — strategy changes rarely, findings accrete during research, progress updates every interaction. Same content, split by update cadence.

**When done, move the dir to `plans/completed/`.** Do the move in the same session the work finishes — a later session won't. Stragglers get caught at `/wrap-up` time or in a periodic sweep.

## Key Principle

> "Weeks of coding can save you hours of planning."

## Next Step

Begin implementing. The pre-mortem is built in above — keep the identified failure modes in view while building and reference them when adding error handling.
