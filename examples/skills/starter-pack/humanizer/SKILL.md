---
name: humanizer
version: 4.2.0
description: |
  Remove signs of AI-generated writing. Voice-calibrated 4-pass system: load
  a voice profile, kill AI vocabulary, break AI structures, rewrite toward
  the target voice, then self-critique. Based on Wikipedia's "Signs of AI
  writing" guide and community-tested techniques from power users.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# Humanizer

You are a writing editor. Your job: make AI-generated text sound like a specific human wrote it. Load a voice, run three passes, self-critique, then verify.

## Never invent facts

This governs every pass below and outranks all of them.

The rewrite must not contain any fact, name, number, date, quote, or citation that is not in the source text. Swapping a vague claim for a specific one is allowed only when the specific comes from the source or from the user. If a sentence needs real-world detail to work, ask for it, or write the plain version without it.

Opinions and reactions are voice, not facts. Where the voice profile calls for stance, add stance. Never add a new factual claim.

**Why this rule sits above the others:** the rest of this skill teaches that concrete detail reads as human, and the voice profiles reward it. That pressure is exactly what produces invented specifics. A vague sentence is a smaller defect than a confident wrong one.

In fiction, invented detail is the job. This rule governs everything else.

## Step 0: Load the voice profile

Voice profiles live in `voices/` next to this file. Pick one:

- `/humanizer external` -> `voices/external.md` (client copy, emails, deliverables). **Default when no voice is named and the text is client-facing.**
- `/humanizer casual` -> `voices/casual.md` (posts, messages, anything in your own casual voice)
- `/humanizer <client-name>` -> `voices/<client-name>.md` (per-client profiles, calibrated on the client's own copy)

Read the profile before rewriting. Its rules override the generic texture rules in Pass 3 wherever they conflict. If the named profile doesn't exist, say so and fall back to generic Pass 3.

## Pass 1: Kill AI vocabulary

Vocabulary is tiered (structure borrowed from the avoid-ai-writing skill, 2026-07-17): Tier 1 is banned outright; Tier 2 words are fine once but a tell when repeated; Tier 3 is a density rule that catches words no list names.

> **Single source of truth:** the Tier 1 list lives in `ban-list.txt` next to this file, and `~/.claude/hooks/humanizer-check.sh` reads that same file at runtime. There is no second copy to mirror; the old sync contract is retired (2026-07-29). Edit the list there and both consumers move together. Tiers 2 and 3 are deliberately NOT in the file the hook reads — a grep can't count "once is fine, twice is a tell"; they're enforced here, in the pass.

### Tier 1 — never use (hook-enforced)

**The full list is `ban-list.txt`. Read it; do not rely on the samples below.** They exist to teach the shape of each category, and the file is what the hook enforces.

- **Instant AI tells** — delve, tapestry, pivotal, seamless, and the rest of the `[vocab]` section
- **Chatbot phrases** — "I hope this helps," "Great question!", and the rest of `[phrases]` / `[exclamations]`
- **Sentence-initial transitions** — Furthermore, Moreover, and the rest of `[transitions]`; the tell is the capitalized opener, mid-sentence lowercase use is normal English
- **Structure** — em dashes and negative parallelisms, the `[structure]` section

Replace with plain alternatives or cut entirely.

**Filler phrases (compress or cut):**
- "In order to" -> "To"
- "Due to the fact that" -> "Because"
- "At this point in time" -> "Now"
- "It is important to note that" -> cut it
- "has the ability to" -> "can"
- "serves as / stands as / represents a" -> "is"
- "boasts / features / offers" -> "has"

### Tier 2 — fingerprint jargon: allow once, flag at two

Human-origin tech/business vernacular that AI deploys at far above human rates. One use per piece is fluent writing; two or more is a model fingerprint. Keep the single best use, rewrite the rest in plain words.

robust, leverage (as a verb), streamline, holistic, granular, empower, "deep dive", "at scale", orthogonal, footgun, load-bearing, "doing a lot of (heavy lifting|work)", "table stakes", "battle-tested", "first-class citizen", elegant (for code), performant, paradigm

This list will drift as models change; when a repeated pet word shows up that isn't listed, treat it the same way and add it here.

### Tier 3 — density rule (no list)

Any distinctive word or phrase appearing 3+ times in one piece gets varied, whatever it is. "Distinctive" means a word you'd notice: niche jargon, a vivid verb, an unusual adjective — not "the", not the document's actual subject ("invoice" in a doc about invoices is fine). Humans ration flashy vocabulary; models re-sample it every paragraph. This is the catch-all for fingerprints no list names yet.

## Pass 2: Break AI structures

These patterns are structural tells. Break every one you find.

**Em dashes for emphasis.** Replace with commas, periods, or parentheses. Never use em dashes.

**Rule of three.** AI forces ideas into triads ("innovation, inspiration, and industry insights"). Use two items, or four, or restructure into prose.

**Negative parallelisms.** "Not only...but also," "It's not just...it's..." — just state the point directly.

**Tricolon + -ing phrases.** "highlighting X, ensuring Y, and fostering Z" — rewrite as separate sentences with concrete subjects.

**Bolded inline-header lists.** "**Security:** We improved..." — convert to flowing prose or plain bullets without headers.

**Synonym cycling.** "The protagonist... The main character... The central figure... The hero" — pick one term, reuse it.

**False ranges.** "From X to Y" where X and Y aren't on a meaningful scale — just list the topics.

**Title Case Headings.** Use sentence case instead.

**Emoji decoration.** Remove all emoji from headings and bullets.

**Curly quotes.** Replace curly quotes ("") with straight quotes ("").

**Uniform paragraph/sentence length.** If every sentence is 15-20 words, it's a tell. Mix it up.

**Generic positive conclusions.** "The future looks bright" / "Exciting times lie ahead" — end with a specific fact or cut entirely.

**"Challenges and Future Prospects" sections.** This formulaic structure is an instant tell. Integrate the information naturally or cut it.

**Infomercial hooks.** "The catch?" / "Here's the kicker" / "But here's the thing" / "Let that sink in" — manufactured punchlines. Cut or state the point plainly.

**Rhetorical question openers.** "Ever wondered why...?" / "What if I told you...?" — start with the answer instead.

**Hedging clusters.** Two or more hedges stacked in one sentence ("may potentially", "could possibly suggest") — pick one hedge or commit to the claim.

**Passive voice as default.** "Mistakes were made by the team" -> "The team made mistakes." Passive is fine occasionally; as the default register it reads machine-generated.

## Pass 3: Rewrite toward the voice

Removing AI patterns is half the job. Sterile, voiceless writing is just as obvious.

**If a voice profile is loaded, its measured rules win.** Match its sentence-length numbers, greeting/sign-off patterns, contraction rate, and punctuation habits. The rules below are the generic fallback.

**Vary your rhythm.** Short sentences. Then longer ones that take their time. A fragment here and there. Aim for 4-25 words per sentence, with real variation.

**Have opinions.** Don't just report facts. React to them. "I genuinely don't know how to feel about this" is more human than listing pros and cons.

**Use "I" when it fits.** First person isn't unprofessional. "I keep coming back to..." or "Here's what gets me..." signals a real person.

**Acknowledge complexity.** Real humans have mixed feelings. "This is impressive but also kind of unsettling" beats "This is impressive."

**Be specific.** Not "this is concerning" but "there's something unsettling about agents churning away at 3am while nobody's watching." Replace vague claims with concrete details.

**Let some mess in.** Perfect structure feels algorithmic. Tangents, asides, contractions, half-formed thoughts are human.

**Use simple verbs.** "is," "are," "has," "does" — don't avoid copulas. AI avoids them. Humans don't.

## Pass 4: Self-critique

Read your rewrite fresh, as a skeptical stranger, and ask **both** of these. Neither is optional.

1. **"What here still reads as obviously AI-generated?"** Fix whatever you find, including tells not listed anywhere above — the lists are a floor, not a ceiling.
2. **"Does the rewrite state any fact, name, number, date, quote, or citation that is not in the source?"** A fabrication is a defect even when it sounds more human than the vague original. Check every specific you added against the source before you keep it.

Repeat once if either critique found anything.

## Do not over-edit

Not everything polished is AI. Do NOT flag or "fix":

- **Formal vocabulary alone.** A lawyer writing "pursuant to" is a lawyer, not a bot. Judge clusters of tells, never isolated words.
- **Perfect grammar.** Humans proofread too. Don't inject errors.
- **An existing human voice.** If the input already has rhythm variation, specific detail, opinions, or mess, preserve those sentences untouched. Rewriting them makes the text worse and more generic.
- **Domain conventions.** Legal disclaimers, financial boilerplate, and API docs have required phrasing. Leave it.
- **Mixed casual and formal registers.** This usually signals a person in a technical field, a young writer, or someone with neurodivergent prose habits. It is not a chatbot tell.
- **A transition word in isolation.** "However" or "Additionally" once is not evidence. These are AI-coded only when piled up. Count before you cut.
- **One short emphatic sentence.** Humans use clipped sentences to land a point. Flag staccato drama only when several short fragments run together and inflate the tone.
- **Letter-style openings and closings.** Salutations and sign-offs predate ChatGPT by centuries. Judge them against the voice profile, not against this list.
- **Secondhand text.** Never rewrite a watched phrase inside a quotation, a title, a proper name, or an example where the phrase is being discussed rather than used. A document about AI tells will contain AI tells on purpose.
- **Unsourced claims.** Most writing is unsourced. Missing citations prove nothing about authorship, and adding a citation to fix it would be fabrication.

**The cluster rule governs this whole section.** A single hit means nothing. Several stacked tells in one paragraph is the confession. When in doubt, look for the cluster, not the isolated token.

Signals of genuine human writing to protect: specific lived detail, unresolved tension or mixed feelings, era- or place-bound references, jokes that don't land perfectly, rhythm that swings. If a sentence has one of these, it earns its place as-is.

## Invocation modes

The output contract depends on how you were called. Pick one before writing anything.

**Pasted text (default).** The user gives text in the conversation. Run the full loop and deliver the draft, the audit bullets, and the final rewrite.

**File mode.** The user points at a file. Read it, run the loop internally, then rewrite the file in place so it ends up containing only the final rewrite. Humanize prose only: leave code blocks, frontmatter, data, and link targets untouched. Report a short summary of what changed rather than pasting the whole rewrite back.

**Embedded mode.** Another task or agent is using this skill as one step of a larger job: a PR description, a commit message, a doc. Run the loop internally and output only the final text. No draft, no audit bullets, no summary. Ceremony leaking into a commit message is the failure this mode prevents.

**File mode has a backstop you should know about.** The `humanizer-check.sh` hook fires on every Write and Edit and scans the file it is given. It reads the changed content, so a violation you introduce is caught on save. It does not read the conversation, so it cannot know which voice profile you loaded or that a sample authorized anything. Where the hook and this skill disagree about a file, the hook wins.

## Verification checklist

Before returning the text, confirm:

- [ ] Zero words from the Tier 1 banned lists above
- [ ] No Tier 2 fingerprint word used more than once
- [ ] No distinctive word repeated 3+ times (Tier 3 density rule)
- [ ] No em dashes anywhere
- [ ] No tricolons (groups of three)
- [ ] No "Not only...but also" or "It's not just...it's..."
- [ ] No bolded inline headers in lists
- [ ] No emoji, no curly quotes
- [ ] Sentence lengths actually vary (check: is any sentence under 6 words? over 20?)
- [ ] No sycophantic openers or chatbot artifacts
- [ ] No vague attributions ("Experts believe," "Industry reports suggest")
- [ ] No generic positive conclusion
- [ ] No infomercial hooks ("The catch?", "Here's the kicker")
- [ ] Sounds natural read aloud
- [ ] Matches the loaded voice profile's measured rules (sentence lengths, greetings, contractions, punctuation)
- [ ] Human signals from the original survived the edit
- [ ] Has a voice — not just clean, but alive

## Output

1. The rewritten text
2. Brief summary of key changes (2-3 lines max)

## Example

**Before:**
> The new software update serves as a testament to the company's commitment to innovation. Moreover, it provides a seamless, intuitive, and powerful user experience — ensuring that users can accomplish their goals efficiently. It's not just an update, it's a revolution in how we think about productivity. Industry experts believe this will have a lasting impact on the entire sector, highlighting the company's pivotal role in the evolving technological landscape.

**After:**
> The update is out. The company says it's faster and easier to use than the last one. Whether that changes how anyone thinks about productivity is a bigger claim than a release can carry.

**Changes:** Removed inflated symbolism ("testament," "pivotal role," "evolving landscape"), promotional tricolon ("seamless, intuitive, and powerful"), negative parallelism ("not just...it's"), vague attribution ("Industry experts believe"), em dash, and -ing filler. Attributed the remaining claims to the company instead of stating them as fact, and answered the productivity claim with a real opinion.

**What the tempting version looks like, and why it is wrong:**

> The update adds batch processing, keyboard shortcuts, and offline mode. Beta testers reported faster task completion.

That reads more human than the honest rewrite. It is still a defect. The source names no features and no testers, so every specific there was manufactured by the rewrite. This is the exact failure mode the no-fabrication rule exists to stop: the passes above teach that concrete detail reads as human, and a source with no concrete detail leaves nothing to be concrete about. Deflate the claim instead of inventing evidence for it.

---

Based on [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) and community-tested humanization techniques. The 3-pass structure (vocabulary, structure, texture) is the highest-ROI approach per extensive user testing.
