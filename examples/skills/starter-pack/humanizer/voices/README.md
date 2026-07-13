# Voice Profiles

The humanizer skill loads a voice profile from this directory before rewriting (`/humanizer external` -> `external.md`, `/humanizer casual` -> `casual.md`, `/humanizer <client-name>` -> `<client-name>.md`). Without one it falls back to the generic rules in the skill, which produce clean-but-anonymous text. A calibrated profile is what makes output sound like *you*.

## How to calibrate a profile

1. **Collect a corpus.** 8-15 samples of text you actually typed by hand (sent emails, Slack messages, posts). Screen out anything AI-drafted; calibrating on AI text defeats the purpose. Aim for 800+ words.
2. **Measure, don't vibe.** Count real numbers from the corpus: median sentence length, share of sentences under 9 words, contraction rate, exclamation frequency, how often you use parentheticals. Enforced numbers beat adjectives like "casual" or "friendly."
3. **Find your tells.** Compare your corpus against text an AI drafted for you. The habits AI *adds* that you never use (a sign-off, em dashes, bold emphasis) become your hard-fail list.
4. **Write the profile** using the skeleton below, one file per voice or per client.

## Profile skeleton

```markdown
# Voice: [name] ([when to use it])

Calibrated [date] on [N] hand-typed samples ([word count] corpus). These are enforced rules, not vibes: match the numbers.

## Rhythm (the signature)
- Median sentence: [N] words. Range [N-N]. [What failure looks like.]
- [Short-sentence rule, e.g. "at least 1 in 3 sentences under 9 words."]

## Openers and closers
- Greeting: [your actual defaults, by context]
- Sign-off: [your actual sign-off]. NEVER [sign-offs you'd never use].

## Punctuation rules
- [Contraction rate, exclamation habits, dash/parenthetical usage, comma splices.]

## Structure
- [How you handle lists, questions, paragraph length, bold/headers.]

## Moves
- [Recurring rhetorical habits: how you make requests, hedge, follow up, admit mistakes.]

## Stock phrases (use naturally, don't stack)
[Phrases that appear repeatedly in your corpus.]

## Hard fails (your personal AI tells; any one of these breaks the voice)
[The additions an AI makes that you never would.]

## Caricature test
If you exaggerated this voice, you'd get: [a parody line]. If your exaggeration instead sounds like [the wrong voice], you've drifted. Recalibrate.

## Before/after
Before (generic AI): [a sample AI draft]
After (you): [the same message as you'd actually type it]
```

The caricature test and before/after pair matter more than they look: they give the model a fast way to check drift without re-reading every rule.
