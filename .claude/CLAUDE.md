# Claude Code Setup Guide

## What it is

A public, opinionated guide to setting up Claude Code (skills, hooks, memory, project config),
published from the maintainer's real config. Readers clone it and run `./install.sh`.

## Stack

Markdown docs plus a bash installer. No build, no dependencies, no tests.

## Layout

| Path | What |
|---|---|
| `docs/` | the numbered guide chapters, the actual product |
| `examples/` | config artifacts copied out of `~/.claude`: settings, hook examples, a CLAUDE.md template |
| `examples/skills/starter-pack/` | genericized copies of real skills |
| `install.sh` | places the example config into a reader's `~/.claude` |

## Invariants

- **This repo is PUBLIC.** Everything in it is world-readable the moment it is pushed. No client
  names, no account identifiers, no file paths that reveal private structure, no meta files
  (`HANDOVER.md`, `learnings.md`, work logs, brainstorms).
- **`examples/` is auto-fed from `~/.claude` by `~/.claude/scripts/sync-setup-guide.sh`.** A
  post-commit hook there runs it in warn mode on every `~/.claude` commit; `--commit` applies and
  pushes. So a change to private config can reach a public repo without anyone deciding to publish
  it. Before assuming a decision is still open, check what is already in `HEAD`.
- **Every documented mechanism must be true of the current Claude Code version, and verified.**
  A wrong claim here fails silently for readers: seven hook recipes documented `$TOOL_INPUT` and
  friends as the input mechanism when hooks actually read JSON from stdin, so anyone running
  `install.sh --full` got hooks that never fired once. Check against the shipped binary, not docs.
- **`install.sh` must work on a machine that has none of the maintainer's setup.** It cannot assume any
  `~/.claude/references/` file exists; the repo ships none.

## Pointers

| File | Holds |
|---|---|
| `README.md` | reader-facing entry point |
| `~/.claude/scripts/sync-setup-guide.sh` | the sync, including what it does and does not copy |
