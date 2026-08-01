---
name: tighten
description: Compress one long document without losing information. Use when the user says "tighten this", "make this more concise", "cut this down", "this is too long", "condense this", "trim it without losing anything", "express the same content more concisely", "clean this up further", or hands over a doc that sprawls. Diagnoses WHY it's long before cutting, indexes every fact so nothing drops silently, then verifies. For a SINGLE document; use /tidy for a folder of docs, /humanizer for vocabulary and voice.
allowed-tools: [Read, Write, Edit, Grep, Glob, Bash, AskUserQuestion]
argument-hint: [path-to-doc]
---

# Tighten

Make a long document shorter without losing what it says. The guarantee is the point: if a fact
goes missing, this failed, however good the prose got.

## The trap to avoid first

Word-level trimming feels like progress and is almost never the answer. Cutting repeated
adjectives out of a 500-line document saves 20 lines. The reason a document is long is usually
structural, and structural fixes save 5-10x more while making it clearer.

**Diagnose before you cut.** If you find yourself grepping for filler words in step one, stop.

## Step 1: Diagnose the kind of long

Read the whole document first. Then name which of these it is. Most long documents are two.

| Kind | Tell | Fix |
|---|---|---|
| **Redundant** | The same fact appears in the evidence section, again in a decision, again in a question | Consolidate. One home, pointers everywhere else |
| **No entry point** | A busy reader can't find the ask without reading it all | **Add** a summary. Concision by adding words |
| **Wrong altitude** | Detail written for a reader who isn't the primary audience | Push it down to the child doc. Don't delete |
| **Genuinely dense** | Every paragraph carries new load-bearing information | **Leave it.** Say so and stop |

That last row is real. Not everything long is bloated, and a pass that always cuts is worse than
no pass. If the answer is "this is dense, it's fine," say that and offer the entry-point fix
instead.

## Step 2: Build the fact index

Before editing anything, enumerate every substantive claim and where it appears. A substantive
claim is a number, a decision, a named risk, a file reference, a commitment, a quote.

```
| Fact | Appears in |
|---|---|
| 756 of 779 prompts carry the public flag | §4, Start-here #1 |
| Corporate folder access can't be revoked | §4, Q3, Start-here #2 |
| 2 prompts already indexed by Google | §4, Q5, Q12 |
```

**Anything appearing twice or more is the entire job.** This index is also your safety net for
step 5, so write it down rather than holding it in your head.

Keep the index in the scratchpad, not in the user's repo.

## Step 3: Assign one home per fact

For each repeated fact, pick the single place a reader most needs it, and replace the others
with a pointer ("Section 4 has the detail").

Choosing the home:
- A fact that drives a decision lives with the decision, not in a general evidence dump
- A fact a reader needs before they can act lives in the summary
- A fact only an implementer needs lives in the child document

The evidence section is usually the loser. It tends to accumulate a full narrative for facts
that get re-narrated later where they're actually used.

## Step 4: Compress

In rough order of payoff:

1. **Collapse repeats to pointers** (step 3). Biggest lever by far.
2. **Turn repeated prose structure into a table.** If three paragraphs each say "here's an
   option, here's the target, here's today's number," that's a table with three rows.
3. **Push detail down a layer.** Code identifiers, SQL, file:line references, and API shapes
   usually belong in the attached PRD rather than the document the decision-maker reads.
4. **Cut the meta-narration.** "An earlier draft said X, which was wrong" earns its place only
   when the reader saw the earlier draft or the correction changes their decision.
5. **Then, and only then, tighten sentences.**

If the diagnosis included **wrong altitude**, do the audience rewrite as its own pass after the
cutting. Doing both at once is how facts go missing.

## Step 5: Verify nothing dropped

Not optional, and not by feel.

1. Re-derive the fact index from the new version.
2. Diff it against step 2's index.
3. Every fact that disappeared must be one you deliberately moved. Name where it went.
4. Run the structural check:

```bash
python3 ~/.claude/skills/tighten/scripts/check_tighten.py <before-file> <after-file>
```

It reports heading changes, cross-references that no longer resolve ("see section 7",
"question 4"), broken relative links, and the line delta. It checks structure, not meaning, so
step 1-3 of this list still needs your eyes.

## Step 6: Report and chain

Report the line delta **and** what the cut actually was. "509 to 436, and the cut was structural:
most facts appeared three times" tells the user something. "Removed 14%" doesn't.

Then offer `/humanizer` for the vocabulary and voice pass. Tighten handles structure; humanizer
handles prose. Running humanizer first wastes work, since half the sentences it polishes get
deleted.

## Gotchas

- **Don't open with a filler-word grep.** It's the smallest lever and it feels productive. Read
  the whole document and diagnose first.
- **Adding words can be the concision fix.** If a busy reader can't find the ask, a summary
  block at the top solves the real problem even though the file gets longer. Concision is
  time-to-answer, not word count.
- **Renumbering breaks cross-references.** Other documents cite "question 4" and "section 7". If
  removing an item would renumber a list, prefer keeping the numbers stable and marking items
  answered in place. Check with grep before you renumber anything.
- **Don't compress what the author workshopped, but do test it.** A deliberate slogan or a
  thesis line they rewrote by hand is exempt from *style* rules, never from the comprehension
  check. Ask yourself whether a first-time reader knows what it means. If a clever line needs a
  gloss, say so and offer a plain replacement. In the worked example the author asked what their
  own thesis line meant two turns after it survived the pass.
- **"Push, don't delete" has a limit.** If there's no child document to push to, you're deleting.
  Say so and get agreement rather than doing it quietly.
- **Superseded sections are a compression opportunity and a correctness bug.** A stale question
  list sitting beside a current one doesn't just add length, it gives the reader two answers.
  Delete it (git keeps it) and check nothing linked to it.
- **Before deleting a superseded file, read it.** It often carries one fact that never got
  carried forward. That fact is the most valuable thing in the pass.

## Rationalizations to reject

- "This section is important, so it should stay long." Importance argues for prominence, not
  length. Move it up, don't leave it sprawling.
- "I cut 15% of the words." Without a fact diff that's a claim, not a result.
- "The detail is useful." Useful to whom, and does a better home exist?
- "It reads better now." Not the assignment. It has to read better *and* say the same things.

## Completeness check

- [ ] Diagnosis named before any edit
- [ ] Fact index written to disk before editing, and re-derived after
- [ ] Every dropped fact accounted for by name and destination
- [ ] `check_tighten.py` run, cross-references and links resolve
- [ ] Report states what the structural cut was, not only the percentage
- [ ] `/humanizer` offered as the next pass

## Worked example

A real before-and-after from a 509-line roadmap doc:
509 lines to 436 while gaining a summary block, driven entirely by facts appearing three times.
It also shows the diagnosis going wrong first, which is the failure this skill exists to prevent.

## Related

| Skill | Scope |
|---|---|
| `/tidy` | A folder of docs. Cross-file duplication, orphans, broken links |
| `/humanizer` | Vocabulary, structure, voice. Run after this one |
| `/plain` | Explaining a concept in conversation, not editing a document |
