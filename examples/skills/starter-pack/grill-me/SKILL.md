---
name: grill-me
description: Relentless one-question-at-a-time interview that extracts decisions from the user's head before building, checkpointing every answer to a brainstorms/ file. Use when the user says "grill me", "/grill-me", "interview me", "ask me questions about this plan", "pick my brain", "get this out of my head", "let's flesh this out before building", or brings a fuzzy idea/process that needs decisions extracted before planning or implementation. Not for attacking a decided position (that's /fool) and not for producing the technical plan itself (that's /pre-implement).
---

# Grill Me

Interview the user relentlessly about a plan, design, or process until you reach shared understanding. You ask, they decide, you write it down. The capture file is the source of truth, not chat memory.

Based on Matt Pocock's grill-me with Nate Herk's checkpoint upgrade.

## Setup (before the first question)

1. Check today's date from the system environment.
2. Create `brainstorms/{YYYY-MM-DD}-{topic-slug}.md` at the project root (create `brainstorms/` if missing). If run outside a project, ask where to save it.
3. Seed the file with this header:

```markdown
# {Topic} — Grill Session
Date: {date} | Goal: {one line}

## Key decisions

## Q&A log

## Open flags
```

4. Tell the user where the file lives, then ask Q1.

## Interview Method

- **One question at a time.** Wait for the answer before asking the next. Multiple questions at once is bewildering.
- **Recommend an answer with each question** so the user can confirm, correct, or redirect. If the options are enumerable, use AskUserQuestion with the recommended option first; otherwise ask in plain text.
- **Facts vs. decisions:** if a fact can be found by exploring the codebase, files, or docs, look it up instead of asking. The decisions are the user's — put each one to them and wait.
- **Walk the design tree.** Resolve upstream decisions before dependent details. When an answer opens a new branch, note it and come back.
- **If the user can't answer**, log it as an open flag with a likely owner and move on.
- Keep going until the important branches are covered or the user says stop.

## Checkpoint Rule

After **every** answer, before asking the next question:

1. Append one Q&A entry (format below).
2. Update **Key decisions** if the answer settled one.
3. Update **Open flags** if something new is unresolved.
4. If the answer contradicts an earlier entry, correct the earlier entry.

Never batch multiple answers into one write. The point is surviving context loss mid-interview.

### Q&A entry format

```markdown
### Q{n} — {topic}
- Asked: {question}
- Answer: {decision, facts, exact wording worth keeping}
- Flags: {open item → owner, or "None"}
```

## Finish

1. Re-read the capture file. Reconcile contradictions and duplicate flags.
2. Give a short recap: key decisions, what's still open, and the single best next step.
3. Route the next step:
   - Building a feature from this? → `/pre-implement` (feed it the brainstorm file)
   - This is a strategy or business bet? → `/fool` to attack it now that it's articulated
   - Documenting a process/SOP? → the brainstorm file is the raw material; offer to draft the doc
4. **Do not start implementing until the user confirms shared understanding.**

## Gotchas

- Don't fire off 3-4 questions in one message — one at a time, always.
- Don't hold answers in memory and write the file "at the end" — checkpoint after every single answer.
- Don't ask the user things `grep` can answer. Asking costs their time; looking it up costs nothing.
- Don't let your recommended answer become a leading question. If the user pushes back, their answer wins — capture it, don't relitigate.
- Don't drift into building mid-interview. Even if the answer makes the fix obvious, log it and keep grilling until the tree is walked.
- Don't assume the year when naming the file — read the date from the environment.
