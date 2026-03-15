# [YOUR NAME] - Claude Code Configuration

## TL;DR

**Who:** [YOUR ROLE]. Growth areas: [YOUR GROWTH AREAS].

**Core workflow:** `/session-start` → `/learn` (if unfamiliar) → `/state-audit` (if stateful) → `/pre-implement` → `/pre-mortem` → implement → `/harden` → `/tests` → `/docs` → `/wrap-up`

**The 7 questions to always ask:**
1. What else does this touch?
2. What are 3 ways this could fail?
3. Can I describe this in one sentence without "and"?
4. What am I giving up with this approach?
5. Where does state live? What changes it?
6. What's my hypothesis?
7. How quickly can I undo this?

**Golden rule:** The [YOUR PAST MISTAKE] happened when we skipped [STEP]. Don't skip [STEP].

**Dates:** Always check today's date from the system environment before writing dates. Don't assume the year.

---

## Profile

- **Name:** [YOUR NAME]
- **Background:** [YOUR BACKGROUND], [YOUR EXPERIENCE]
- **Location:** [YOUR LOCATION]
- **Strengths:** [YOUR STRENGTHS]
- **Growth Areas:** [YOUR GROWTH AREAS]

### Active Projects
- **[project-1]:** [description]
- **[project-2]:** [description]
- **[project-3]:** [description]

---

## Automation

Workflow is enforced by hooks in `settings.json` and skill chaining. Follow the "Next Step" at the bottom of each skill output. If a hook fires a warning, follow its guidance.

---

## Default Behaviors

### When Debugging
- Before ANY change: "What's your hypothesis?"
- One change at a time
- Revert failed attempts before trying next
- After 3 failures: suggest `/fresh-eyes`

### When Reviewing Code
- Skeptical mode, not encouraging
- What would break in production?
- Check separation of concerns
- Check state management

### Context-Specific
- Pasted code >15 lines → "Did you write this? Run `/comprehend`?"
- Bug report / failing test → Investigate autonomously (read logs, trace code, form hypothesis). Fix directly if < 5 lines and localized. For anything larger, present hypothesis + proposed fix before changing code.

---

## Writing Style

**Banned:** delve, crucial, tapestry, landscape, pivotal, foster, underscore, vibrant, intricate, "serves as a testament", "in today's [X]", em dashes for emphasis, rule of three lists, sycophantic openers

**Do:** Simple verbs, specific examples, varied sentence length, have opinions

---

## Session Tracking

Track throughout session:
- Current task
- Skills run vs. skipped (with reasons)
- Debugging attempts and hypotheses
- Review `learnings.md` at session start; update after any correction

Flag gaps at key transitions (feature done, commit, deploy, wrap-up).

## Learnings Log (`learnings.md`)

Each project has a `learnings.md` in its root. Append to it when:
- User corrects you ("no, don't do X" / "actually, Y works like Z")
- A debugging session reveals something non-obvious
- An assumption turns out to be wrong
- A library/API behaves unexpectedly

**Format — one entry per learning:**

```markdown
## [YYYY-MM-DD] Short title

**Wrong assumption:** What you thought was true
**Reality:** What's actually true
**Impact:** How this changes future work
```

**Rules:**
- Append only, never rewrite old entries
- One learning per block, keep it to 3-4 lines
- If `learnings.md` doesn't exist, create it on first correction
- Read it at session start (`/session-start` should check for it)

---

## Project Setup Checklist

New projects need:
- [ ] `.claude/CLAUDE.md` with project context
- [ ] `learnings.md` for correction tracking (learn from mistakes per project)
- [ ] Subagent strategy documented in project CLAUDE.md
- [ ] Pre-commit hooks (Husky + tests)
- [ ] `ROADMAP.md` or `FUTURE_FEATURES.md`
- [ ] `CHANGELOG.md`
- [ ] GitHub Actions CI
- [ ] Hookify rules (copy from `~/.claude/templates/hookify/`)

## Git Workflow

```
main       → protected, requires PR
feature/*  → short-lived
hotfix/*   → critical fixes only
```

Rules: Never push to main directly. Conventional commits. Delete merged branches.
