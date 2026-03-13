---
name: code-reviewer
description: Review code for quality, bugs, security, and best practices. Use when the user asks to review code, check for issues, audit a file, or wants feedback on implementation.
---

# Code Reviewer

Perform thorough code reviews focusing on correctness, security, and maintainability.

## Review Checklist

### 1. Correctness
- Logic errors or edge cases not handled
- Off-by-one errors, null/undefined handling
- Race conditions in async code
- Incorrect assumptions about data shape

### 2. Security (OWASP Top 10)
- Injection vulnerabilities (SQL, command, XSS)
- Authentication/authorization flaws
- Sensitive data exposure (hardcoded secrets, logs)
- Insecure dependencies

### 3. Performance
- N+1 queries, unnecessary loops
- Missing indexes for database queries
- Memory leaks (event listeners, subscriptions)
- Blocking operations in async contexts

### 4. Maintainability
- Function/variable naming clarity
- Single responsibility principle
- Dead code or unused imports
- Missing error handling

### 5. Testing
- Are critical paths testable?
- Missing test coverage for edge cases
- Mocked dependencies that hide bugs

### 6. Separation of Concerns
- **Can each function be described in one sentence without "and"?**
  - ❌ "This function fetches data AND formats it AND updates the UI"
  - ✅ "This function fetches user data" (separate functions format and update)
- Does each module have a single responsibility?
- Are there functions doing multiple unrelated things?
- Could this be split into smaller, more focused units?

### 7. State Management
- **Where does state live?** Is it clear?
- **What changes it?** Is mutation controlled?
- **How do other components know when it changes?** Is propagation clear?
- Are there multiple sources of truth? (Bad)
- Potential sync issues between local and remote state?
- Race conditions in state updates?

### 8. Comprehension
- Would a new developer understand this code?
- Is the "why" documented, not just the "what"?
- Are complex algorithms explained?
- Could the code reviewer explain every line if asked?

## Output Format

```markdown
## Code Review: [file/component name]

### Critical Issues
- [Issues that must be fixed]

### Improvements
- [Suggestions that would improve quality]

### Positive Notes
- [What's done well]
```

## Guidelines
- Be specific: include line numbers and concrete suggestions
- Prioritize: critical > important > nice-to-have
- Be constructive: explain why, not just what
- Don't nitpick style unless it affects readability
