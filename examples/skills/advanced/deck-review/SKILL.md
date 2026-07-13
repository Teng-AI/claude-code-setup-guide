---
name: deck-review
description: Review an investor pitch deck across positioning, narrative flow, consistency/detail, and overall fundability. Use when the user says "review this deck", "thoughts on this investor deck", "deck review", "critique my pitch deck", "is this deck ready to send", "review my pitch", or attaches/points at a pitch deck PDF and asks for feedback. Say "quick" / "gut check" for the lightweight mode. Not for design-only critique or non-investor docs.
argument-hint: [path-to-deck.pdf] [quick]
---

# Investor Deck Review

Skeptical-investor review of a pitch deck. The reader persona is a seed/pre-seed VC associate deciding whether to pass — not a supportive friend. Every finding must cite a slide number.

## Modes

- **full** (default): all passes, full output format.
- **quick** (user says "quick", "gut check", "fast look"): still read every page, then one combined pass. Output only: Verdict, top 5 findings (any dimension, severity order), "If you only do three things". Cross-check headline numbers only; skip the full number table and completeness check.

## Steps

1. **Read the entire deck first.** PDFs over 10 pages need paginated reads — read ALL pages including the appendix before forming any opinion. Note the page count and confirm you read every page. Appendix content counts: duplication between appendix and main deck is itself a finding.

2. **Identify the ask and calibrate the bar.** Find the raise amount and stage (pre-seed / seed / A). The bar differs: pre-seed can fly on team + thesis; seed needs proof someone pays; A needs metrics. All verdicts are relative to this bar — state it explicitly. Two sub-checks:
   - **Raise math:** does raise ÷ implied burn ≈ stated runway, and do the funded milestones unlock the *next* round? "$3M → 10 customers" only works if 10 customers is a Series A story.
   - **Send vs. present:** ask (or infer) whether this deck is emailed cold or presented live. A send deck must carry the argument in text; a presented deck should be sparser. Judge density findings against the right one.

3. **Pass 1 — Pitch & positioning.** Answer these, citing slides:
   - What is the one-line thesis? Is it stated crisply anywhere, or assembled by the reader?
   - Wedge vs. platform: does the deck lead with a specific, winnable wedge or a horizontal vision? Horizontal-first is usually backwards for early stage — investors fund wedges and believe arcs.
   - Is the claimed moat *earned* (exists today: access, relationships, live data) or *aspirational* (data flywheel that starts after scale)? Flag moats that are asserted repeatedly but never mechanistically defended.
   - Named-competitor defense: pick the closest funded competitor in the deck and ask "why can't they copy this in a quarter?" If the deck has no answer, that's a finding.
   - Does the product claim (e.g., full autonomy) outrun the trust/adoption reality of the target buyer?
   - Business model: is pricing logic stated anywhere? A target ARR without a pricing mechanism is an assertion.
   - Team slide: founder-market fit evidence, and who's conspicuously missing for what the deck promises.

4. **Pass 2 — Narrative flow.** Map the slide order against the story spine (problem → why now → solution → proof → market → competition → team → ask). Then:
   - Where does proof/traction sit, and is there any? Distinguish real traction (signed, live, paying) from soft language ("discussions underway", "identified leads").
   - Count repetitions: how many slides make the same argument? Repetition where evidence should be reads as filler covering a traction gap.
   - Which slides could be cut with zero information loss? Name them.
   - Any slide aimed at the wrong audience (deep technical architecture in an investor deck)?

5. **Pass 3 — Detail & consistency sweep.** This is mechanical — build the artifacts, don't eyeball:
   - **Number table:** list every quantitative claim (TAM/SAM/SOM, market sizes, lead counts, ARR targets, percentages) with its slide number. Cross-check every number that appears more than once. Mismatches here are the single most credibility-damaging defect.
   - **Within-slide contradictions:** headers vs. table rows on the same slide.
   - Typos, truncated sentences, grammar (subject-verb), spelling-variant inconsistency (labour/labor), miscapitalized brand names.
   - Credibility-poisoning footnotes ("estimates per ChatGPT", "source: internal guess") — these silently discredit every other number.
   - Comparison-table self-owns: does the company's own column show ❌/red on any row? Clever framing loses to visual scan.
   - **Third-party exposure:** named customers/prospects, attributed quotes, revenue estimates for other companies. Decks circulate — would any slide damage a relationship or leak strategy if forwarded to the named party or a competitor?

6. **Pass 4 — Overall assessment.**
   - **Partner-meeting test:** list the ~5 questions this deck forces an investor to ask, and mark each as preempted, dodged, or unaddressed. A deck that triggers questions it doesn't answer gets passed on.
   - Deliver the verdict per the output format: what round this deck can and cannot raise as-is, and the single highest-leverage addition.

## Output Format

```markdown
## Verdict
[2-3 sentences. What the deck is, what it can raise as-is, the one structural gap.]

## Positioning
[Findings with slide cites. What's working — keep short. Then what would make an investor hesitate, ordered by severity.]

## Flow
[Story-spine gaps, redundancy count, slides to cut, proof placement.]

## Consistency & Detail
[Number mismatches first (table if 3+), then typos/footnotes/self-owns. Every item: slide number.]

## Questions this deck will trigger
[~5 investor questions, each marked: preempted / dodged / unaddressed.]

## Prioritized Fixes
### P0 — Fix before anyone sees this
### P1 — Materially strengthens the pitch
### P2 — Polish

## If you only do three things
[The three highest-leverage fixes, one line each.]
```

## Gotchas

- **Don't be encouraging by default.** The failure mode is a review that's 60% praise. Cap "what's working" at 3 items; spend the words on what gets the deck passed on.
- **Don't skip the number cross-check because the deck "looks professional."** One reviewed deck had 3 contradictions (two different TAM figures, SAM ranges that disagreed, lead counts that conflicted on the same slide) despite polished design. Always build the number table.
- **Don't treat "pilot discussions" or "identified leads" as traction.** Call out soft-traction language explicitly — investors read it as zero.
- **Don't review only mechanics when positioning is broken, or only positioning when the ask is imminent.** Cover all four dimensions every time; the prioritized list handles emphasis.
- **Don't accept a claimed data moat at face value.** "Every interaction makes it smarter" is in every AI deck. Ask what the moat is *before* the flywheel spins.
- **Don't forget the ask slide.** A 2x raise range ($2M–$4M) or milestones without numbers is a finding, not background.
- **Don't stop reading at the "Thank You" slide.** Appendix slides carry findings (duplication, buried proof, contradictions).

## Completeness Check
- [ ] Every page read, including appendix (state page count)
- [ ] Stage/bar stated explicitly, verdict calibrated to it
- [ ] Number table built; every repeated figure cross-checked
- [ ] Closest funded competitor named and the "copy it in a quarter" question answered or flagged
- [ ] Every finding cites a slide number
- [ ] Partner-meeting questions listed, each marked preempted/dodged/unaddressed
- [ ] P0/P1/P2 list present; P0 items are all send-blockers
- [ ] "If you only do three things" section present
(Quick mode: skip this checklist — only Verdict, top 5 findings, and three things are required.)
