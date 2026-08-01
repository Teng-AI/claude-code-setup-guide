---
name: compound
description: Extract learnings from the current session. Captures corrections, patterns, decisions, and domain insights. Use at session end, after completing meaningful work, or anytime you say "let's capture this", "that's worth remembering", "note that for next time", or "we should remember this".
---

# Compound Learning Extraction

Extract what this session taught us so future sessions start smarter. This is the "compound" step — each extraction builds the knowledge base that the next session draws from.

## When to Use

- At session end (invoked by `/wrap-up` Step 6)
- After completing a meaningful task (feature, debug session, research, deliverable)
- When the user says "capture this", "remember this", "note that"
- After any session where you learned something non-obvious

**Skip if:** The session was purely mechanical — applying known patterns, no new ground broken. But check: "Did we discover anything about HOW to do this more effectively?" That's a pattern worth capturing even if nothing went wrong.

## The Extraction Process

Review the session and ask these four questions. Adapt to what actually happened — not every session produces all four types.

### Question 1: Corrections

> Did anything surprise us? Wrong assumptions, unexpected behavior, corrections?

Look for:
- User corrected your approach
- Debugging revealed non-obvious behavior
- An assumption was wrong
- A library/API didn't work as expected

### Question 2: Patterns

> Did we find an approach that worked well? Something we'd want to reuse?

Look for:
- A technique that solved a problem elegantly
- A workflow that was more effective than the obvious approach
- A workaround that should become the standard approach
- An ordering or sequencing that matters

### Question 3: Decisions

> Did we make any design choices we'd want to remember the rationale for?

Look for:
- Choices between alternatives where the reasoning matters
- Trade-offs made under constraints (time, compatibility, scope)
- "We chose X over Y because..." moments
- Skip if the decision was big enough for a formal ADR (wrap-up Step 8 handles those)

### Question 4: Domain Insights

> Did we learn anything about the domain (not the tools) that would help in future work?

Look for:
- How users/clients actually behave vs. how we assumed
- Business rules or constraints discovered during implementation
- Facts about external systems, APIs, or services
- Industry or domain knowledge gained

## For Each Learning

### 1. Categorize

Assign a type: `correction`, `pattern`, `decision`, or `domain`.

### 2. Determine Scope and Audience

Ask two questions, in order:

**"Who is this for?"** (the ownership map in `~/.claude/references/memory-system.md` is authoritative)
- **For Claude** (tool gotchas, process, preferences that change future behavior) → continue to the scope question below
- **For the user** (world knowledge they would read themselves: facts about a domain, market, org, or system that are true regardless of Claude) → **vault-first**: write or update the page in `~/Documents/projects/brain/topics/` (read `brain/CLAUDE.md` router rules first), and add at most a one-line pointer stub in memory if sessions will need to find it. Domain-type learnings usually land here.

**"Would this help in a different project?"**
- **Global** — learnings about tools (Notion API, Firebase, Claude Code), reusable techniques, writing/communication patterns
- **Project** (default) — learnings about this project's specific architecture, data model, or domain-only context

When in doubt on scope, keep it project-local. It can always be promoted later.

### 3. Write to learnings.md

**Read `~/.claude/references/learnings-format.md` now** if you have not already this session. It defines the four entry types, the scope rule, and the append-only constraint. It is no longer loaded at session start, so this read is the only thing that puts the format in context.

Append to the project's `learnings.md` using that format. Create the file if it doesn't exist.

### 4. Bridge globals to home memory

If scope is global, BOTH steps are required — a file without an index line is invisible to every future session (the 2026-07-11 audit found 4 orphans from exactly this):

1. Write a topic file to `~/.claude/projects/<your-home-project>/memory/learning_<slug>.md`
   - `<slug>` = kebab-case of the learning title
   - Frontmatter: `name`, `description`, `type: reference`, `source_project`, `source_date`
2. Add a one-line entry to that MEMORY.md under the matching subsection of "Learnings by domain" (Verification discipline, Notion, Sheets, and so on; add a subsection only if none fits) — in the same tool-use turn as step 1, never deferred
3. Verify before finishing: `grep <slug> MEMORY.md` returns the new line. If not, the bridge is incomplete; fix it before reporting the learning as captured.

**Example global topic file:**
```yaml
---
name: Notion API MCP limitations
description: MCP only supports paragraph and bulleted_list_item — use direct curl for all other block types
type: reference
source_project: client-project
source_date: 2026-03-24
---

MCP Notion server only supports `paragraph` and `bulleted_list_item` block types. For headings, callouts, dividers, toggles, tables, code blocks, and file uploads, use direct `curl` calls to the Notion API. See `~/.claude/references/notion-api.md` for patterns.
```

### 5. Check for supersession (before writing, not after)

Capture used to be purely additive, so a corrected belief landed *beside* the old one instead of replacing it. Two entries then disagree and the reader cannot tell which won.

For each learning about to be written, search the layer it is going into for what it contradicts:

```bash
grep -ril "<3-4 distinctive keywords from the new learning>" \
  ~/.claude/projects/*/memory/ path/to/learnings.md
```

If something comes back that the new learning contradicts:

- **Delete the losing text and write the winner in its place.** Do not append and date-stamp both.
- Keep whatever remains true from the old entry, merged into the new one. Supersession replaces a claim, not necessarily a whole file.
- If the old entry lives one layer up (a memory file, a CLAUDE.md rule), say so and stop. Editing an instruction is the user's call, not an automatic one.
- If it is genuinely a different case rather than a contradiction, keep both and make the distinguishing condition explicit in each. "It behaves this way when X" and "this way when Y" are two facts. "It behaves this way" written twice with different answers is one fact and a stale copy.

Removal is event-driven only: something contradicted it, or its project died. **Never delete a memory because it looks old or unused.** The rarely-retrieved entries are the highest-value ones here, so an age or usage rule deletes exactly the wrong files.

### 6. Check for promotion candidates

If a global learning has been surfaced in 3+ sessions or has grown into substantial reference material, flag it:

> "This learning about [X] keeps coming up. Worth promoting to a full reference file at `~/.claude/references/`?"

Leave the actual promotion to the user.

## Output Format

After extraction, display a summary:

```markdown
## Compound Learnings: [Project Name]

**Captured:** N learnings (X project-local, Y global)

| Type | Title | Scope |
|------|-------|-------|
| pattern | [title] | project |
| correction | [title] | global |

**Written to:** learnings.md
**Global bridge:** learning_[slug].md (if any)
```

If nothing was captured: "No learnings this session — purely mechanical work."

## Integration

- Called by `/wrap-up` Step 6
- Learnings surfaced by `/session-start` Step 0.75
- Format defined in `~/.claude/references/learnings-format.md`
- Global learnings stored in `~/.claude/projects/<your-home-project>/memory/`
