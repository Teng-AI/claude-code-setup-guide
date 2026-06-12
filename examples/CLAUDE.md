# [YOUR NAME] - Claude Code Configuration

## TL;DR

**Who:** [YOUR ROLE]. Growth areas: [YOUR GROWTH AREAS].

**Core workflow:** `/session-start` → `/learn` (if unfamiliar) → `/state-audit` (if stateful) → `/pre-implement` → `/pre-mortem` → implement → `/harden` → `/test-gaps` → `/docs-sync` → `/wrap-up`

**Golden rule:** The [YOUR PAST MISTAKE] happened when we skipped [STEP]. Don't skip [STEP].

**Dates:** Always check today's date from the system environment before writing dates. Don't assume the year.

---

## Profile

- **Name:** [YOUR NAME]
- **Background:** [YOUR BACKGROUND], [YOUR EXPERIENCE]
- **Location:** [YOUR LOCATION]
- **Strengths:** [YOUR STRENGTHS]
- **Growth Areas:** [YOUR GROWTH AREAS]

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
- Check separation of concerns and state management

### Context-Specific
- Pasted code >15 lines → "Did you write this? Run `/comprehend`?"
- Bug report / failing test → Investigate autonomously (read logs, trace code, form hypothesis). Fix directly if < 5 lines and localized. For anything larger, present hypothesis + proposed fix before changing code.

---

## Writing Style

Applies to ALL output: chat responses, documents, emails, commit messages, code comments — everything.

**Banned:** delve, crucial, tapestry, landscape, pivotal, foster, underscore, vibrant, intricate, "serves as a testament", "in today's [X]", em dashes for emphasis, rule of three lists, sycophantic openers

**Do:** Simple verbs, specific examples, varied sentence length, have opinions

---

## Session Tracking

Track throughout session: current task, skills run vs. skipped (with reasons), debugging attempts and hypotheses. Flag gaps at key transitions (feature done, commit, deploy, wrap-up).

---

## Automation

Workflow is enforced by hooks in `settings.json` and skill chaining. Follow the "Next Step" at the bottom of each skill output. If a hook fires a warning, follow its guidance.

---

## The 7 Questions (always ask before major changes)

1. What else does this touch?
2. What are 3 ways this could fail?
3. Can I describe this in one sentence without "and"?
4. What am I giving up with this approach?
5. Where does state live? What changes it?
6. What's my hypothesis?
7. How quickly can I undo this?

---

## References (loaded on demand)

See @references/learnings-format.md for learnings.md format and rules
See @references/project-setup-checklist.md for new project setup
See @references/git-workflow.md for branch strategy and commit conventions
See @references/notion-api.md for Notion API direct calls (bypassing MCP limitations)
See @references/tools.md for installed CLI tools (gws, gh, firebase, vercel, gcloud)
See @references/cowork-skill-design.md for Co-Work token budgets, context management, and skill sizing
<!-- plaud-skills:start -->
Plaud MCP skills moved to `~/.claude/skills/plaud-*/SKILL.md` on 2026-06-11 (lazy-loaded). Start with `plaud-shared` for auth, tools, and error handling.
<!-- plaud-skills:end -->
