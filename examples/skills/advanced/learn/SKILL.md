---
name: learn
description: Research unfamiliar domain or library before building
---

# /learn - Pre-Implementation Research

When invoked, research an unfamiliar technology, library, or domain before writing any code. This prevents the common mistake of jumping into implementation with incomplete understanding.

## Usage

Invoke with the topic: `/learn [topic]`

Examples:
- `/learn Firebase Realtime Database`
- `/learn React Server Components`
- `/learn Stripe webhooks`

## Steps

### 1. Identify What's Unfamiliar

- State clearly what you don't know.
- Distinguish between "never used" and "used before but rusty."
- Identify which parts of the technology are relevant to the current task (you don't need to learn everything).

### 2. Research Core Concepts

For a **library or framework:**
- What problem does it solve?
- What are its core abstractions? (e.g., React has components, hooks, state; Firebase has documents, collections, listeners)
- What's the basic usage pattern?
- How does data flow through it?
- What's the mental model? (event-driven, declarative, reactive, etc.)

For a **domain or business concept:**
- What are the key terms and their precise definitions?
- What are the rules and constraints?
- What are common edge cases?
- What do users expect?

### 3. Identify Gotchas and Anti-Patterns

- What are the most common mistakes beginners make?
- What looks like it should work but doesn't?
- What are the performance traps?
- What are the security considerations?
- Are there breaking changes between versions that blog posts might not reflect?

### 4. Create a Quick Reference

Produce a short reference of:

```
## Quick Reference: [Technology]

### Key Concepts
- [Concept]: [one-line explanation]

### Common Patterns
- [Pattern name]: [when to use it]

### Gotchas
- [Gotcha]: [why it's a problem and what to do instead]

### Key APIs for This Task
- [function/method]: [what it does, key params]
```

This reference should be specific to the current task, not a general tutorial.

### 5. Identify Remaining Unknowns

- What questions can only be answered by trying things during implementation?
- What might need a prototype or spike to validate?
- Are there architectural decisions that depend on how the technology behaves under specific conditions?

List these so they can be investigated during implementation rather than forgotten.

## Rules

- Do not write production code during the learn phase. Research only.
- Do not try to learn everything. Focus on what's needed for the current task.
- If the technology has official docs, prefer those over blog posts or Stack Overflow (which may be outdated).
- If you find conflicting information, note the conflict and which source is more authoritative.
- Time-box this: learning should inform implementation, not replace it. If research is taking too long, note the remaining unknowns and move to implementation.

## Output

The quick reference (step 4) plus the list of remaining unknowns (step 5). This becomes the working reference for the implementation phase.
