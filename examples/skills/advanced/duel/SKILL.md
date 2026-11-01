---
name: duel
description: Blind cross-model check on a high-stakes decision. A fresh Claude analyst and Codex each answer from the same facts-only packet without seeing each other or the owner's position, swap once, then see the owner's position last. Use when the user says "duel this", "/duel", "debate this with Codex", "have Claude and Codex debate", "second opinion from another model", "have Codex weigh in", "get a cross-model check", or when /grill-me, /fool or /pre-implement offers it before a costly-to-reverse decision Claude helped shape (pricing, business model, a new bet, a vendor or data-model choice). Not for reviewing a code diff or memo (one codex read does that), not for poking holes in a position (that's /fool), not for taste or dialect calls.
---

# Duel

Two analysts from different model families answer the same question blind, swap once, and only then see what the owner already decided. The main thread moderates and never argues a side.

The value is the blind round 0 from a different family. Past one swap, debates drift into polite mutual concessions, so there is no round 2. The protocol came out of one hand-run pricing debate between the two models, then got scripted.

## Step 0: Gate (one message, then wait)

Run it only if all three hold. Otherwise say which failed and point to `/fool` or just deciding.
- **Stakes:** costly to reverse (money, a public commitment, months of work).
- **A real fork:** two or more defensible options, not a yes/no on one plan.
- **Independence matters:** Claude helped shape the current thinking, or the owner is leaning hard.

Then check Codex is usable: `codex --version` and `codex login status`. Tell the owner the cost: about 3 Codex calls at high reasoning (they count against the ChatGPT plan's limit) and 3 Claude subagents, roughly 15 to 30 minutes.

## Step 1: Build the run folder and packet

Folder: `<repo>/brainstorms/YYYY-MM-DD-<slug>-duel/` for repo work, your notes vault's `brainstorms/` for personal or strategic questions.

```
<run>/
├── owner.md        # the owner's position, if one exists. NEVER inside arena/ until Step 4
├── notes.md        # moderator only: who is A and B, leak check, timings
├── verdict.md      # Step 5
└── arena/          # the ONLY folder the analysts can read
    ├── packet.md   # from templates/packet.md
    ├── evidence.md # optional: research, cleaned
    └── rounds.md   # copied from templates/rounds.md
```

1. Write `arena/packet.md` from [templates/packet.md](templates/packet.md): the product or situation, the owner's goals, the owner's ideas and worries as inputs, an option menu, the questions every proposal must answer. **No recommendation and no proposal named anywhere.**
2. If research exists, copy it into `arena/evidence.md` and strip the researcher's synthesis and any proposal the research brief named. A brief that says "test our $2.99" leaks $2.99 into the facts.
3. If the owner holds a position (a `/grill-me` file, a Bet block, a stated lean), write it to `owner.md` as numbered decisions D1, D2, ...
4. **Leak check:** list the distinctive terms of the owner's position (prices, chosen option ids, quoted phrases) and grep `arena/` for each. Record the hits in `notes.md`. Rewrite until a hit is only a neutral option on the menu.
5. Copy [templates/rounds.md](templates/rounds.md) to `arena/rounds.md`.
6. Assign labels with a coin flip (`$((RANDOM % 2))`): which of Claude and Codex is A. Record it in `notes.md` only.

**STOP. Show the owner `arena/packet.md` (a clickable path) plus the leak-check result and wait for approval.** The packet decides the quality of everything after it.

## Step 2: Round 0, blind and in parallel

Send both in one message:
- **Codex:** `bash ~/.claude/skills/duel/scripts/codex-round.sh <run>/arena round0 <A|B>` with `run_in_background: true`. The script runs `codex exec` read-only inside `arena/`, writes `round0-<X>.md`, and fails loud on a stub.
- **Claude:** an Agent call, `subagent_type: general-purpose`, never a fork. Prompt: "You are Analyst <X>. Read packet.md, evidence.md (if present) and rounds.md in `<run>/arena/`. Use only files in that folder: no web, no other paths. Do Round 0 exactly as rounds.md describes and write it to `<run>/arena/round0-<X>.md`. Reply with one line when done."

Wait for both. Check each file exists and is over 1,500 bytes.

## Step 3: One swap

Same two calls with `swap` in place of `round0`; the Claude prompt names its own `round0-<X>.md` and the other's. Each re-reads its own round 0, reads the other's and writes `swap-<X>.md`: agreements, a disagreement table with arguments, a "Position changes" table, a revised proposal, and a list of **checkable facts** in dispute.

Then the moderator checks each disputed checkable fact at the source (web, repo, vault), and writes `arena/facts-checked.md`: the fact, the answer, the source. Facts get checked, never argued.

## Step 4: Final check (skip only if there is no owner.md and no facts-checked.md)

Copy `owner.md` into `arena/`, then run both analysts on `final`. Each says, per point where its revised proposal differs from the owner or from a checked fact: hold or defer, and the one-line reason. Output `final-<X>.md`.

## Step 5: Verdict

Write `verdict.md` from the analysts' own text. Every row quotes or cites A or B; the moderator adds nothing of its own except the labels.

```markdown
# Duel verdict: <question> (<date>)
**Overall: <label>.** <one line: what the owner should take from this>

| Decision point | A | B | Owner | Label | The argument that decides it |
|---|---|---|---|---|---|

## Arguments the owner had not considered
- <argument> (from A/B, round)

## Facts checked
- <fact>: <answer> (<source>)

## Position changes
| Who | Round | From | To | Because |
|---|---|---|---|---|

## Confidence shift
<did this make the owner's position stronger or weaker, and on which points>
```

Labels, per point and overall (the overall label is the most serious one present):

| Label | Meaning | Next |
|---|---|---|
| CONSENSUS | A and B agree, and with the owner if Step 4 ran | Offer `/fool` Evidence Audit on these points (below) |
| SPLIT | A and B land in different places | Owner decides; the verdict shows the crux |
| TIE | On a point, each adopted the other's earlier position in the same round | Owner decides. A tie is a finding, not a reason for another round |
| AGAINST-OWNER | A and B agree with each other and both hold against the owner | Owner decides; `/grill-me` if they want to test their reasons |

Then the ledger writes, exactly as `/fool` Step 5 describes ("Then the ledger writes"): show the lines, wait for a yes, write them, link them from `verdict.md`.

**CONSENSUS hand-off:** the analysts saw only the packet, so agreement can rest on what the packet left out. Offer: "Both analysts agree on <points>. Run /fool's Evidence Audit on that against the repo and vault?" On yes, follow `/fool` with the Evidence Audit lens, searching `brainstorms/`, `plans/`, research files and `brain/` for anything that contradicts the consensus. (In the first run this is what found a payment study in the repo that the packet had missed.)

## Gotchas

- **Analysts read the whole folder they are given.** Codex with `-C arena/` can `cat` anything there. Anything the analysts must not see lives in the parent folder. In the first run the owner file sat beside the packet and only a prompt instruction kept it out.
- **Never substitute a second Claude for Codex.** If Codex is out (usage limit, login), stop and say so. Two Claude analysts is self-consistency, not a cross-model check.
- **The Claude analyst is fresh.** A fork carries this conversation, which is exactly the anchoring the duel removes.
- **Discount same-family deference.** In one final check the Claude analyst deferred to a Claude-run grill on 4 of 5 points; Codex held all five. Note it in the verdict when a Claude analyst defers to a position a Claude session helped form.
- **No third round, ever.** If the swap did not converge, the disagreement is the result.
- **`codex exec -o` holds only the final message.** The script asks for the whole answer as the final message and checks the size; a one-line "written to X" stub means it tried to write a file instead.
- **The moderator has opinions; keep them out.** It may have argued the question earlier in the session. The verdict cites the analysts; the moderator's view, if asked for, goes after the verdict under its own heading.

## Completeness check

- [ ] Owner approved `arena/packet.md`; leak-check result is in `notes.md`
- [ ] `owner.md` was outside `arena/` until Step 4
- [ ] round0, swap (and final if run) exist for both A and B, each over 1,500 bytes
- [ ] Every verdict row cites A or B
- [ ] Overall label set; CONSENSUS points offered to `/fool` Evidence Audit
