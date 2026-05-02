---
title: outline-edit
tags: [tools, cli, python, outline, knowledge-base, cache]
sources:
  - https://github.com/lhl/outline-edit
links:
  - https://github.com/lhl/outline-edit
  - https://pypi.org/project/outline-edit/
---

# outline-edit

A Python command-line tool for working with an [Outline](https://www.getoutline.com/) knowledge base through the raw Outline API while keeping a local markdown cache on disk.

## Overview

| Attribute | Value |
|-----------|-------|
| **Version** | 0.2.1 |
| **Language** | Python 3.10+ |
| **License** | MIT |
| **Author** | Leonard Lin |
| **Repository** | github.com/lhl/outline-edit |

**Zero runtime dependencies.** The entire tool is built on the Python standard library. No third-party packages are imported at runtime.

## Why Not Just Use MCP?

Outline ships an MCP server, but `outline-edit` addresses structural inefficiencies that compound in agent and automation workflows:

| Operation | What MCP Does | Cost |
|---|---|---|
| List 50 recent docs | Returns full ProseMirror JSON body for every doc | ~1 MB of tokens |
| Read one document | Searches by title, returns full content of all matches | N x full doc bodies |
| Fix a typo | Fetch full doc, generate full replacement, send full doc, re-fetch to verify | 4 x full doc body |
| Browse a collection | Returns full content of every doc in the collection | Entire collection |
| Check what changed this week | Fetch all docs just to read timestamps | All content for metadata |

### Root Causes (verified against Outline v1.6.1)

- **No metadata-only mode.** `list_documents` always includes full document bodies.
- **No partial content.** Cannot request a section or summary — always full document.
- **No diff or patch on update.** `update_document` requires entire body as replacement.
- **No revision history.** MCP does not expose `revisions.*` endpoints.
- **No event or audit log.** Cannot ask "what changed this week" without fetching every document.
- **No reliable document read by ID.** Resource URIs return authorization errors in practice.

### Cost Comparison

```
With outline-edit:
  Read a doc      →  local file read           (~0 API tokens)
  Edit a doc      →  local file edit           (~0 API tokens)
  Push edits      →  one API call              (1x full doc)
  Pull fresh copy →  one API call, cached      (1x full doc)

With MCP:
  Read a doc      →  search by title           (Nx full docs in results)
  Edit a doc      →  generate full replacement (1x full doc in context)
  Push edits      →  send full doc             (1x full doc)
  Verify the push →  search by title again     (Nx full docs)
```

**Use MCP** for direct tool-mediated interaction with a live Outline workspace.

**Use outline-edit** for reproducible local cache, cheap read path for repeated workflows, or access to revision and audit capabilities.

## Features

- Local markdown cache with index metadata
- Pull by collection, query, document ID, or full crawl
- Local `status`, `list`, `read`, `search`, and `diff`
- Remote `create`, `push`, `publish`, `archive`, `restore`, and `delete`
- Revision history, activity log, and revision-to-revision diff
- Starter config generation with `init`
- Bundled agent skill definition via `outline-edit skill`

## Installation

```bash
# From PyPI
pip install outline-edit

# With uv
uv tool install outline-edit

# With pipx
pipx install outline-edit

# Run without installing
uvx outline-edit --help
```

## Configuration

Generate config interactively:

```bash
outline-edit init --interactive
```

Default config location: `~/.config/outline-edit/config.env`

```bash
OUTLINE_CLI_BASE_URL=https://your-outline.example.com
OUTLINE_CLI_API_KEY=...

# Optional
OUTLINE_CLI_CACHE_DIR=/path/to/custom/cache
OUTLINE_CLI_TIMEOUT=30
```

## Quick Start

```bash
# Initialize and validate auth
outline-edit init --interactive
outline-edit auth

# Pull one collection into local cache
outline-edit pull --collection Engineering

# Inspect local cache
outline-edit status
outline-edit list --collection Engineering
outline-edit read "Weekly Notes"
outline-edit search incident

# Edit locally and push changes back
outline-edit diff "Weekly Notes"
outline-edit push "Weekly Notes"

# Remote operations
outline-edit create "New Doc" --collection Engineering
outline-edit publish "Weekly Notes"
outline-edit archive "Old Doc"
outline-edit delete "Trash Doc"
```

## Commands

| Command | Description |
|---------|-------------|
| `init` | Generate starter config file |
| `auth` | Validate API authentication |
| `pull` | Sync documents from Outline to local cache |
| `status` | Show cache status and statistics |
| `list` | List cached documents |
| `read` | Read a document from local cache |
| `search` | Search documents locally |
| `diff` | Show local changes vs remote |
| `push` | Push local edits to Outline |
| `create` | Create new document |
| `publish` | Publish a document |
| `archive` | Archive a document |
| `restore` | Restore an archived document |
| `delete` | Delete a document |
| `revisions` | Show revision history |
| `revisions diff` | Diff between revisions |
| `activity` | Show activity/audit log |

## Agent Skill

The tool includes a bundled agent skill definition:

```bash
outline-edit skill  # Outputs SKILL.md content
```

This can be used with pi or other agents that support the Agent Skills standard.

## Related

- [Outline](https://www.getoutline.com/) — Open-source knowledge base
- [outline-edit on PyPI](https://pypi.org/project/outline-edit/)