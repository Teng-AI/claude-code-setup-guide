---
name: loose-ends
description: Sweep the current conversation for unresolved items and list them ranked; with "ask" (`/loose-ends ask`), put each open decision to the user as a quick multiple-choice question instead. Use when the user says "loose ends", "/loose-ends", "what's outstanding", "what did we leave open", "anything unresolved", "what am I forgetting", "did we drop anything", "what suggestions did you make that I didn't answer", or returns from a tangent asking where things stand. Ask mode when they say "/loose-ends ask", "interview me on the open items", "ask me about what's open", "quick-fire the decisions", "just ask me". Lighter than /grill-me (no capture file, no follow-up branches). Not for cross-session state (that's HANDOVER.md / session-start).
---

# Loose Ends

List what's still open in THIS conversation so nothing gets forgotten after a tangent. Recall-only: no file writes, no task creation, no fixes — just the list. Ask mode (below) is the one exception: it turns the list into questions and acts on the answers.

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

## Ask Mode

Triggered by `ask` as the argument or by the ask-mode phrases in the description. Run Steps 1 to 5 as usual, then ask instead of listing.

1. Keep only items the user has to decide or approve. A "tracked" item from Step 4 stays in if it is still waiting on the user's decision (a report that lists the decision is not the decision). Look up facts yourself instead of asking. Items Claude can just do without a decision get one line after the questions; don't ask about them.
2. Ask with AskUserQuestion: one question per item, up to 4 per call, at most 2 calls (8 items). Past 8, ask the top 8 and list the rest.
3. Each question names the item and what the answer changes. Options: the recommended answer first, marked "(Recommended)", then one or two real alternatives, and "Later", which leaves it open. Put the material behind the item (file link, artifact link, the diff) in the question text or an option preview, since the user may not remember it.
4. No follow-up questions. If an answer opens a new decision, list it as a new loose end rather than asking it.
5. After the answers, give a short table: item, answer, what happens next. Then do what was approved, under the same rules as any other request (approving one settings change covers that change only). Items answered "Later" stay open; say so in one line.

## Gotchas

- Don't list items the user already resolved with a terse reply ("done", "n/a", "skip") — terse answers count as decisions.
- Don't pad the list to look thorough. Two real items beat six stale ones; an empty list is a valid answer.
- Don't include long-horizon dated items that are already tracked elsewhere (calendar, ROADMAP, scheduled task) — those aren't loose, they're parked. Mention them only if the date is within ~2 weeks.
- Don't turn the sweep into action. Resolving items is a follow-up the user asks for, not part of this skill. Ask mode is that request: act only on what the answers approved.
