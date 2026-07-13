---
name: plain
description: Re-explain the current technical topic in plain English, anchored in the live example in this conversation. Use when jargon is piling up or when a layered concept (scheduler vs. container, branch vs. commit, etc.) is blurring together.
---

# Plain

Translate whatever we just discussed into plain English for someone transitioning from vibe coder to disciplined engineer. Technical depth is fine — the user has it. Unexplained jargon is what trips them up.

## When to Use

Run `/plain` when:
- The last few turns stacked up acronyms / cloud-service names / framework terms
- Two concepts got conflated (common case: infra layer vs. application layer)
- User asks "what are we actually doing / testing for / solving" — that's a signal the narrative got lost
- Proactively: at the end of a multi-step operation where you used 2+ terms without defining them

## Invocation

- `/plain` — explain whatever the current topic is
- `/plain <term>` — focus on one specific term/concept in the context of this conversation

## The Five Rules

### 1. First sentence: what + why, no jargon
If you can't open with a jargon-free sentence that says what we're doing and why it matters, you don't understand it well enough to explain it. Try again.

**Bad:** "Cloud Scheduler triggers the Cloud Run Job on a cron expression."
**Good:** "It's the timer that starts the weekly job automatically every Monday morning, so nobody has to remember to run it."

### 2. Anchor in the live example
Use the thing we're actually looking at — this file, this commit, this error message — not a generic analogy.

**Bad:** "A container is like a shipping container for code."
**Good:** "We packaged your `report.py` and friends into a self-contained bundle and handed it to Google. That bundle is what just ran on their servers — same code you ran on your laptop, different machine."

### 3. Separate what got conflated
A lot of "I don't get it" isn't one missing piece — it's two adjacent concepts mashed together. Name the layers.

**Bad:** "The scheduler runs the job in the container."
**Good:** "Three separate things: (1) the **timer** that fires Monday morning, (2) the **job** that actually does the parsing, (3) the **container** the job runs inside. They're independent — you can test any one without the others."

### 4. End with "what we're NOT doing"
Scoping down is the clearest way to bound a concept. Every explanation should close with an explicit non-goal.

**Good:** "We are NOT testing that the timer fires correctly — that was already proven in the Stage 2 alert drill. We're only testing that the engine still works when run from the cloud copy of the code."

### 5. Offer one level deeper
Last line: a specific offer to explain the next concept down, phrased as a question. Let the user steer.

**Good:** "Want the mechanics of how `gcloud run jobs execute` actually talks to the container?"

## Anti-patterns

- **Don't lecture.** This is a re-explanation, not a tutorial. Two or three paragraphs, not a wall of text.
- **Don't define every term.** Define the ones actually blocking comprehension. Leaving `git` undefined is fine; leaving `artifact registry` undefined is not.
- **Don't use the word "basically."** It almost always precedes a definition that isn't basic. Say what the thing is, directly.
- **Don't flatten what's genuinely nuanced.** If something has a real gotcha, name it — don't smooth it away for the sake of simplicity.

## Output Shape

```markdown
[One-paragraph jargon-free explanation of what + why, anchored in the live example]

[If layers got conflated: short numbered list separating them]

We are NOT [explicit non-goal that scopes the concept].

Want [one level deeper]?
```

## Example in Context

User has been debugging a Cloud Run Job that won't find its secret. Ask "/plain".

```
What's happening: your code is asking Google for a secret value (the service account key file). Google replies "I don't know who you are, and also you're not allowed to read that secret anyway." Two separate NOs — fixing one doesn't fix the other.

Three layers, commonly confused:
1. **Who the job is running as** — the service account identity attached to the Cloud Run Job.
2. **What that identity is allowed to read** — the IAM roles granted on each secret.
3. **How the code fetches it** — the `secretmanager` client library call, which just asks on behalf of (1).

We are NOT debugging the code in step (3) — it's correct. The failure is in (2): the identity from (1) doesn't have `secretAccessor` on the specific secret.

Want the gcloud command to check (2) directly?
```

## Next Step

After `/plain`, the user usually either drills down ("yes, explain X") or gets what they need and moves on. If they drill down, run `/plain` again on the narrower topic — recursion is fine and appropriate.

## Integration with Other Skills

| After `/plain` | Run If... |
|----------------|-----------|
| `/show-me` | The shape is the problem rather than the words; a diagram would land better than more prose |
| `/compound` | The topic will come up again and is worth capturing as a learning |

If the "what's happening" explanation revealed an actual bug (not just confusion), switch to fixing it: state a hypothesis, change one thing at a time, revert failed attempts.
