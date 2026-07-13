---
name: learn
description: Research a domain before building. Use when entering unfamiliar territory, using a new library/framework, or before implementing something you haven't done before. Prevents the "jumped into coding without understanding" anti-pattern.
---

# Learn Before Building

Research and understand a domain before writing code. Prevents wasted effort from wrong assumptions.

## When to Use

- "I've never used [X] before"
- "I'm not sure how [Y] works"
- Starting work in an unfamiliar codebase area
- Using a new library, API, or framework
- Implementing a pattern you haven't done before
- Before any task where you're unsure of the approach

## The Learning Process

### Step 1: Define What You Need to Know

```markdown
**Goal**: What am I trying to build/do?
**Gap**: What do I not understand yet?
**Scope**: What's the minimum I need to learn to proceed?
```

Don't try to learn everything. Focus on what's needed for the task.

### Step 2: Find Authoritative Sources

**Priority order:**
1. **Official documentation** — Most accurate, most current
2. **Official examples/tutorials** — Practical application
3. **Source code** — Ultimate truth for how it works
4. **Reputable blogs/articles** — Good for concepts and gotchas
5. **Stack Overflow** — Good for specific problems
6. **AI assistance** — Good for explanations, verify against docs

**Red flags:**
- Outdated articles (check the date)
- No official docs cited
- Contradicts official documentation

### Step 3: Understand Key Concepts

For any new technology, identify:

```markdown
### Core Concepts
- [Concept 1]: [One-sentence explanation]
- [Concept 2]: [One-sentence explanation]

### Mental Model
[How does this thing "think"? What's the paradigm?]

### Key APIs/Methods
- [Method 1]: [What it does, when to use]
- [Method 2]: [What it does, when to use]
```

### Step 4: Study Patterns & Anti-Patterns

```markdown
### Common Patterns (Do This)
- [Pattern 1]: [When and why]
- [Pattern 2]: [When and why]

### Anti-Patterns (Don't Do This)
- [Anti-pattern 1]: [Why it's bad]
- [Anti-pattern 2]: [Why it's bad]

### Gotchas
- [Gotcha 1]: [What catches people]
- [Gotcha 2]: [What catches people]
```

### Step 5: Find Working Examples

Before writing your own code:
1. Find a working example that does something similar
2. Run it to confirm it works
3. Modify it to understand how it works
4. Use it as a reference for your implementation

### Step 6: Create a Minimal Prototype

Before building the real thing:
```bash
# Create a scratch file/project
# Implement the simplest possible version
# Verify it works as expected
# Then integrate into real code
```

## Output Format

```markdown
## Learning Summary: [Topic]

### Goal
[What I'm trying to accomplish]

### Key Concepts
| Concept | What It Is | Why It Matters |
|---------|------------|----------------|
| [X] | [Definition] | [Relevance to my task] |

### How It Works
[Brief mental model / explanation]

### API Reference (What I'll Use)
| Method/Function | Purpose | Example |
|-----------------|---------|---------|
| [method()] | [What it does] | [Simple example] |

### Patterns to Follow
1. [Pattern]: [Why]
2. [Pattern]: [Why]

### Gotchas to Avoid
1. [Gotcha]: [What goes wrong]
2. [Gotcha]: [What goes wrong]

### Example Code
\`\`\`typescript
// Working example I found/tested
\`\`\`

### Ready to Build
- [ ] Understand the core concepts
- [ ] Know which APIs to use
- [ ] Have a working example to reference
- [ ] Know the common pitfalls
```

## Questions to Ask

When learning something new, answer these:

### Understanding
- What problem does this solve?
- What's the mental model / paradigm?
- How does data flow through it?

### Practical
- What's the "hello world" example?
- What are the most common use cases?
- What's the recommended project structure?

### Gotchas
- What trips up beginners?
- What are the performance considerations?
- What are the security considerations?

### Integration
- How does this fit with what I already have?
- What dependencies does it require?
- Are there compatibility issues?

## The Anti-Pattern This Prevents

**The Timer Feature Pattern** (from your lessons learned):
- Jumped into coding without understanding Firebase `update()` behavior
- Spent hours debugging
- Had to revert everything

**With `/learn` first:**
1. Research Firebase update vs set behavior
2. Find examples of the pattern you need
3. Understand the gotchas
4. Then implement with confidence

## When to Use /learn vs Just Building

| Situation | Action |
|-----------|--------|
| Done this exact thing before | Just build |
| Similar to something you know | Skim docs, then build |
| New library/framework | `/learn` first |
| New paradigm (e.g., first time with GraphQL) | `/learn` thoroughly |
| High-stakes (payments, auth, data) | `/learn` thoroughly |

## Next Step

Run `/pre-implement` to plan using what you learned.

## Integration with Other Skills

```
Starting unfamiliar task → /learn
After learning → /pre-implement (plan the work)
After planning → /pre-mortem (check risks)
Then → implement
```

## Time Investment

| Complexity | Learning Time | Saves |
|------------|---------------|-------|
| New API/method | 15-30 min | Hours of trial-and-error |
| New library | 1-2 hours | Days of refactoring |
| New paradigm | Half day | Weeks of wrong approaches |

The time spent learning almost always pays for itself in avoided mistakes.
