---
name: loose-ends
description: Sweep the current conversation for unresolved items and list them ranked. Use when the user says "loose ends", "/loose-ends", "what's outstanding", "what did we leave open", "anything unresolved", "what am I forgetting", "did we drop anything", "what suggestions did you make that I didn't answer", or returns from a tangent asking where things stand. Not for cross-session state (that's HANDOVER.md / session-start) and not for reviewing a task tracker.
---

# Loose Ends

List what's still open in THIS conversation so nothing gets forgotten after a tangent. Recall-only: no file writes, no task creation, no fixes — just the list.

## Steps

1. Re-read the whole conversation, oldest to newest. Collect candidates in four buckets:
   - Suggestions or recommendations Claude made that got no decision ("worth doing X", "you may want to...", "I'd recommend...")
   - Questions either side asked that never got answered
   - Items the user explicitly deferred ("later", "not now", "let's come back to that")
   - Problems surfaced but not acted on (errors, stale data, warnings, flagged risks)
2. Check the session task list (TaskList) for open items and merge them in.
3. Drop anything that was resolved later in the conversation — a tangent often resolves an earlier item implicitly. Verify each candidate against everything that came AFTER it.
4. Drop anything already captured somewhere durable this session (HANDOVER.md, memory, Notion, a commit, a spawned task chip) — note it as "tracked" instead of listing it as open.
5. Rank what's left: things blocking current work first, then decisions waiting on the user, then nice-to-haves.
6. Output the list. If empty, say "Nothing outstanding" and name where the resolved items landed.

## Output Format

Numbered list, most important first. One line of context each plus what resolving it looks like:

1. **Short label** — one-line context; what resolving it looks like (decide / answer / do).
...
~~Struck items~~ — resolved or tracked, with where (one line, only if useful).

## Gotchas

- Don't list items the user already resolved with a terse reply ("done", "n/a", "skip") — terse answers count as decisions.
- Don't pad the list to look thorough. Two real items beat six stale ones; an empty list is a valid answer.
- Don't include long-horizon dated items that are already tracked elsewhere (calendar, ROADMAP, scheduled task) — those aren't loose, they're parked. Mention them only if the date is within ~2 weeks.
- Don't turn the sweep into action. Resolving items is a follow-up the user asks for, not part of this skill.
