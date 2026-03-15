# Claude Code Setup Guide

A guide to setting up [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with skills, hooks, memory, and project configuration. Based on a real production setup with custom skills across multiple projects.

> **Note:** This is one person's opinionated setup, not official Anthropic documentation. Take what's useful, skip what isn't.

## Quick Start

```bash
git clone https://github.com/Teng-AI/claude-code-setup-guide.git
cd claude-code-setup-guide
./install.sh
```

This gives you the starter pack of essential skills covering the core development workflow. To install everything (all skills, hooks, memory system, templates):

```bash
./install.sh --full
```

Run `./install.sh --help` for all options.

## Table of Contents

| # | Document | Description |
|---|----------|-------------|
| 01 | [Getting Started](docs/01-getting-started.md) | Installation, key concepts, directory structure, writing your CLAUDE.md |
| 02 | [Settings](docs/02-settings.md) | Configuring settings.json and permissions |
| 03 | [Skills](docs/03-skills.md) | How skills work, full catalog, learning path |
| 04 | [Hooks](docs/04-hooks.md) | Event-driven automation with pre/post tool hooks |
| 05 | [Memory System](docs/05-memory-system.md) | Persistent cross-session knowledge |
| 06 | [Project Setup](docs/06-project-setup.md) | Per-project CLAUDE.md, learnings.md, templates, references |
| 07 | [Plugins and Agents](docs/07-plugins-and-agents.md) | Third-party plugins and custom agent definitions |
| 08 | [Workflow Walkthrough](docs/08-workflow-walkthrough.md) | End-to-end example of a full development session |

## Starter Pack vs Full Setup

| Feature | Starter Pack | Full Setup |
|---------|-------------|------------|
| **Skills** | 8 core skills ([details](docs/03-skills.md)) | All skills ([details](docs/03-skills.md)) |
| **Hooks** | -- | Pre-commit, post-tool, deploy gate, prompt-based workflow gates |
| **Memory system** | -- | learnings.md tracking, session state persistence |
| **Templates** | -- | PR templates, reference docs |
| **Best for** | Getting started, trying out skills | Full workflow adoption across projects |

Start with the starter pack. Run `./install.sh --full` later to add the rest without losing anything.

## License

[MIT](LICENSE)
