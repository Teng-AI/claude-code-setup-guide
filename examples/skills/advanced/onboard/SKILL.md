---
name: onboard
description: Get up to speed on an unfamiliar codebase quickly
---

# /onboard - Codebase Onboarding

When invoked, systematically explore an unfamiliar codebase and produce a mental model of how it works. This is the first skill to run when working with a new project.

## Steps

### 1. Read Documentation

- Check for README, CONTRIBUTING, ARCHITECTURE, or similar docs at the project root.
- Note the stated purpose, setup instructions, and any architectural decisions.
- Don't trust docs blindly -- they may be outdated. Use them as a starting hypothesis.

### 2. Understand Directory Structure

- List the top-level directories and identify what each one contains.
- Look for standard patterns:
  - `src/` or `lib/` -- source code
  - `test/` or `__tests__/` -- tests
  - `public/` or `static/` -- static assets
  - `scripts/` -- build or utility scripts
  - `config/` or root config files -- configuration
- Note any non-standard organization.

### 3. Read Key Config Files

- **package.json** (or equivalent): dependencies, scripts, project metadata.
- **tsconfig.json / jsconfig.json**: TypeScript/JS configuration, path aliases.
- **.env.example**: required environment variables.
- **Docker/CI files**: how it's built and deployed.
- **Linter/formatter config**: code style expectations.

From dependencies, identify:
- Framework (Next.js, Express, Django, etc.)
- Database (Prisma, Mongoose, SQLAlchemy, etc.)
- State management (Redux, Zustand, Context, etc.)
- Testing tools (Jest, Vitest, pytest, etc.)
- Any unusual or domain-specific libraries.

### 4. Identify Entry Points

Find where execution starts:
- **Web app**: main page/layout component, router config.
- **API**: server startup file, route definitions.
- **CLI**: main/bin entry point.
- **Library**: main export file, public API surface.

### 5. Trace One Feature End-to-End

Pick one representative feature (preferably something simple) and trace it through the codebase:
- Where does the request/action enter the system?
- What components/modules does it pass through?
- Where does data come from?
- Where does data get written?
- What gets returned to the user?

This gives you the actual architecture, which may differ from what docs describe.

### 6. Run Tests and Build

- Run the test suite. Note what passes, what fails, and what's skipped.
- Run the build. Note any warnings.
- Try to start the dev server if applicable.
- These steps often reveal undocumented dependencies or setup requirements.

### 7. Check Recent Activity

- Run `git log --oneline -20` to see recent commits.
- Identify active areas of the codebase.
- Note who's contributing and whether the project is actively maintained.
- Check for any recent large refactors or migrations in progress.

### 8. Create a Mental Model Summary

Produce the output described below.

## Output Format

```
## Project: [name]

### Purpose
[One sentence: what this project does]

### Tech Stack
- Runtime: [Node, Python, Go, etc.]
- Framework: [Next.js, Express, Django, etc.]
- Database: [Postgres, MongoDB, Firebase, etc.]
- Key libraries: [list notable ones]

### Architecture
[2-3 sentences describing how the system is structured: monolith, microservices, serverless, etc. Where does business logic live? How is state managed?]

### Directory Map
- [dir/]: [what it contains, one line each]

### Entry Points
- [file]: [what it starts]

### Key Files
- [file]: [why it matters -- e.g., "main router", "database models", "auth middleware"]

### Data Flow
[Brief description of how a request moves through the system]

### Setup
[Commands to install, configure, and run locally]

### Observations
- [Anything notable: tech debt, unusual patterns, active migrations, missing tests]

### Suggested Starting Points
- To understand [X], start at [file]
- To understand [Y], start at [file]
```

## Rules

- This is a read-only operation. Do not modify any files.
- If setup fails (missing env vars, broken dependencies), document what's needed rather than trying to fix it.
- Don't try to understand everything. The goal is a working mental model, not complete knowledge.
- Prioritize understanding the architecture and data flow over individual functions.
