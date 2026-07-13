---
name: humanizer
version: 4.0.0
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

## Step 0: Load the voice profile

Voice profiles live in `voices/` next to this file. Pick one:

- `/humanizer external` -> `voices/external.md` (client copy, emails, deliverables). **Default when no voice is named and the text is client-facing.**
- `/humanizer casual` -> `voices/casual.md` (posts, messages, anything in your own casual voice)
- `/humanizer <client-name>` -> `voices/<client-name>.md` (per-client profiles, calibrated on the client's own copy)

Read the profile before rewriting. Its rules override the generic texture rules in Pass 3 wherever they conflict. If the named profile doesn't exist, say so and fall back to generic Pass 3.

## Pass 1: Kill AI vocabulary

Never use these words. Replace with plain alternatives or cut entirely.

> **Sync contract:** this ban list is kept as the UNION of this section and the grep patterns in `~/.claude/hooks/humanizer-check.sh` (synced 2026-07-11). Any edit to either list must be mirrored in the other file. Note: the skill's "unlock" ban covers the hook's "unlock the" pattern.

**Instant AI tells:** delve, tapestry, testament, unwavering, pivotal, foster, underscore, landscape (figurative), embark, endeavor, nuanced, multifaceted, intricate, vibrant, crucial, showcase, enduring, enhance, garner, interplay, meticulously

**Promotional fluff:** groundbreaking, breathtaking, stunning, renowned, nestled, "in the heart of," boasts, profound, exemplifies, "commitment to," must-visit, game-changing, unlock, "elevate your," master, skyrocket, revolutionize, disruptive, seamless, innovative, unprecedented

**Transitions that cluster:** Furthermore, Moreover, Additionally, In conclusion, Consequently, Subsequently, Accordingly, "It is worth noting," Notably, Significantly, Indeed

**Chatbot artifacts:** "I hope this helps," "Of course!," "Certainly!," "You're absolutely right!," "Would you like...," "let me know," "here is a...," "Great question!," "as of my last update"

**Filler phrases (compress or cut):**
- "In order to" -> "To"
- "Due to the fact that" -> "Because"
- "At this point in time" -> "Now"
- "It is important to note that" -> cut it
- "has the ability to" -> "can"
- "serves as / stands as / represents a" -> "is"
- "boasts / features / offers" -> "has"

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

Read your rewrite fresh, as a skeptical stranger, and ask: **"What here still reads as obviously AI-generated?"** Fix whatever you find, including tells not listed anywhere above — the lists are a floor, not a ceiling. Repeat once if the first critique found anything.

## Do not over-edit

Not everything polished is AI. Do NOT flag or "fix":

- **Formal vocabulary alone.** A lawyer writing "pursuant to" is a lawyer, not a bot. Judge clusters of tells, never isolated words.
- **Perfect grammar.** Humans proofread too. Don't inject errors.
- **An existing human voice.** If the input already has rhythm variation, specific detail, opinions, or mess, preserve those sentences untouched. Rewriting them makes the text worse and more generic.
- **Domain conventions.** Legal disclaimers, financial boilerplate, and API docs have required phrasing. Leave it.

Signals of genuine human writing to protect: specific lived detail, unresolved tension or mixed feelings, era- or place-bound references, jokes that don't land perfectly, rhythm that swings. If a sentence has one of these, it earns its place as-is.

## Verification checklist

Before returning the text, confirm:

- [ ] Zero words from the banned lists above
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
> The update adds batch processing, keyboard shortcuts, and offline mode. Beta testers reported faster task completion. Whether it changes how people think about productivity is another question, but the early numbers look good.

**Changes:** Removed inflated symbolism ("testament," "pivotal role," "evolving landscape"), promotional tricolon ("seamless, intuitive, and powerful"), negative parallelism ("not just...it's"), vague attribution ("Industry experts believe"), em dash, and -ing filler. Added specific features and a real opinion.

---

Based on [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) and community-tested humanization techniques. The 3-pass structure (vocabulary, structure, texture) is the highest-ROI approach per extensive user testing.
