---
name: show-me
description: Build a visual (diagram, table, timeline, interactive widget) to explain the current topic, anchored in the live example in this conversation. Use when the user says "show me", "diagram this", "draw this", "visualize this", "make a visual", "help me see this", "what does this look like", "map this out", or asks how parts fit together / what order things happen in. Also offer it proactively when an explanation involves 3+ interacting parts or a multi-step flow. Sibling of /plain — that one fixes the words, this one fixes the shape.
---

# Show Me

Build one visual that resolves the specific confusion in this conversation. Not a tutorial graphic — an explainer for the thing we are looking at right now.

## Invocation

- `/show-me` — visualize whatever the current topic is
- `/show-me <concept>` — focus on one concept in the context of this conversation
- Proactive: when an explanation has the shape of a diagram (3+ interacting parts, a sequence, a layered system), offer one in a single sentence. Offer, don't auto-render.

## Steps

1. **Diagnose the confusion type first.** Name it to yourself before picking a form. If there are two confusions, that's two visuals — say so and do them one at a time.

2. **Pick the form from the routing table:**

   | Confusion is about... | Build |
   |---|---|
   | How parts relate (anatomy, architecture, accounts, permissions) | Boxes-and-arrows diagram |
   | Order of events (request flow, pipeline, git operations) | Sequence / flow diagram with numbered steps |
   | A tradeoff or comparison | Side-by-side table or 2x2 — not a chart |
   | Magnitude ("how much bigger/more is X") | Chart or proportional shapes — defer to the dataviz skill if available |
   | Change over time / lifecycle / statuses | Timeline or state diagram |
   | "What happens if I change X" | Interactive widget with a control — the only case that earns interactivity |

3. **Anchor in the live example.** Use the actual names from this conversation — this file, this account, this error message. `jane@example.com → gws → client_secret.json` teaches more than a generic OAuth diagram. If you catch yourself writing "Service A" and "Service B", stop and use the real ones.

4. **Render with the richest tool available, degrade gracefully:**
   1. Inline widget tool (e.g. `show_widget` from a visualize MCP) — renders in chat
   2. Artifact tool, if present
   3. Write an HTML or SVG file to the scratchpad and open it in the browser
   4. Last resort (plain terminal, no renderer): a tight ASCII diagram or markdown table

5. **Frame it like /plain frames prose:**
   - **Above the visual:** one jargon-free sentence saying what it shows and why it matters.
   - **Below the visual:** one line starting "This does NOT show..." — the explicit scope boundary.
   - **Last line:** offer to zoom one level deeper on a specific part, phrased as a question.

6. **Offer persistence only when it's durable.** If the visual explains world knowledge the user will want again (not this session's debugging), offer to save it next to the matching `brain/topics/` note. Session-specific visuals stay ephemeral — don't file them.

## Gotchas

- **Don't decorate.** Color encodes meaning (state, ownership, layer) or it doesn't appear. No gradients, icons, or dashboard chrome on an explainer.
- **Don't build interactive when static answers it.** Interactivity is for exploring a parameter, not for polish. A static diagram with good labels beats a widget with tabs.
- **Don't use a chart when a table is honest.** Charts imply measured quantity. Comparing features or tradeoffs is a table.
- **Don't cram two ideas into one visual.** The moment a diagram needs a legend to separate two stories, split it.
- **Don't skip the NOT-line.** A visual without a scope boundary creates the same conflation problem prose does — the user assumes it shows everything.
- **Don't lecture around it.** The visual plus three sentences of frame. If more prose is needed, the visual picked the wrong form.

## Output Shape

```markdown
[One jargon-free sentence: what this shows and why it matters right now]

[THE VISUAL]

This does NOT show [explicit non-goal that scopes the diagram].

Want me to zoom into [specific part, one level deeper]?
```

## Integration with Other Skills

| Pair with | When |
|---|---|
| `/plain` | The words are the problem, not the shape. Run it first if both — prose diagnosis often reveals which diagram to draw |
| `dataviz` skill | The visual is a real data chart (quantities, trends) — use its palette and form rules |
| `/compound` | The topic will come up again; capture the insight, and the visual if durable |
