# devstack

An opiniated guide for agentic programming best practices. This is what I'm currently using/moving towards to for development.

## Coding Agent

- [Pi Coding Agent](https://pi.dev/) - an open source minimal terminal coding harness that will adapt to the way you want to work. You may want to start or use Claude Code, OpenAI Codex, OpenCode, etc, but Pi's flexibility and ease of customization makes it something probably worth trying sooner rather than later
### Pi Extensions

Here's what I actually have installed for my Pi setup:

- [pi-multiloop](https://github.com/lhl/pi-multiloop) — my autoloop. A fresh implementation from the things I learned from my [codex-autoresearch](https://github.com/lhl/codex-autoresearch/) fork and from my experience with autoloops since 2025
- [pi-zentui](https://github.com/lhl/pi-zentui) — my personal fork of a status-line that fits my preference
- `pi-rtk-optimizer` — token optimization via RTK command rewriting + output compaction
  - [rtk](https://github.com/rtk-ai/rtk) — if you pay for tokens or have a quota, I've found this to be the easiest way to reduce token consumption. You can hook this up to basically any agentic harness relatively easily
- `pi-schedule-prompt` — natural language scheduling, cron, per-task model
- `pi-boomerang` — token-efficient autonomous loops — summarize between iterations
- `pi-continue` — mid-run context compaction with Continuation Ledger
- `pi-code-previews` — Shiki syntax-highlighted tool output rendering in TUI
- `pi-web-access` — web search, content extraction, video/YT, GitHub clone, PDF
- `pi-smart-fetch` — browser-like TLS fingerprints + Defuddle site extractors
- `camoufox-pi` — stealth web access via Camoufox anti-fingerprinting Firefox fork (requires `npx camoufox fetch` + `/reload`)


If you want to install everything:
```
git clone https://github.com/lhl/devstack
cd devstack
./pi-setup.sh
```

### Standalone Tools

| Tool | Version | Install | Purpose |
|---|---|---|---|
| `outline-edit` | 0.2.0 | pip (mambaforge) | CLI for Outline knowledge base with local markdown cache |
| `qmd` | 2.1.0 | npm (global) | Local semantic search engine for markdown/code collections |
| `realitycheck` | — | ❌ Not installed | Framework for rigorous claim/source/prediction tracking |




## This Repo

This  

Detailed docs for each component at `wiki/tools/`. Extension evaluations and comparisons at `wiki/tools/pi-agent.md`.

## Repo Structure

```
devstack/
├── README.md              # This file — overview + setup
├── inbox/                 # Drop zone for unprocessed material
├── sources/               # Immutable archive of ingested material
│   ├── gists/             # External specs, gists
│   ├── conversations/     # Exported chat sessions, research transcripts
│   ├── articles/          # Web clippings, blog posts
│   └── papers/            # PDFs, academic papers
├── wiki/                  # Agent-maintained compiled knowledge
│   ├── index.md           # Page catalog (agent-maintained)
│   ├── log.md             # Chronological operations log
│   ├── concepts/          # Ideas, patterns, comparisons
│   ├── tools/             # qmd, RTK, Claude Code, Codex, etc.
│   ├── practices/         # Workflows, playbooks, how-tos
│   └── projects/          # Pi Agent, devstack, etc.
├── writing/               # Your authored content — writeups, talks, slides
├── docs/                  # Project working docs for this repo
├── projects/              # Software submodules / subdirs
└── tools/                 # Scripts, configs, utilities
```



### Directory roles

**inbox/** — Drop anything here: URLs, PDFs, conversations, screenshots, half-formed notes. The agent processes items into `wiki/` pages and archives originals into `sources/`. Unprocessed items live here until ingested.

**sources/** — Karpathy's "raw" layer. Immutable once filed. The agent reads from here but never modifies these files. Organized by type. Binary files (PDFs, images) can use Git LFS via `.gitattributes`.

**wiki/** — Agent-owned. The agent creates, updates, and cross-links pages here. Humans read it; the agent writes it. Every page should use `[[wikilinks]]` for cross-references. `index.md` is the entry point — a categorized catalog of all pages with one-line summaries. `log.md` is an append-only chronological record of operations (ingests, queries, lint passes).

**writing/** — Your own authored content: workflow writeups, talks, slide decks, presentations. Not ingested sources or agent wiki pages — these are things you wrote for external audiences.

**docs/** — Working documents for this repo itself — development notes, research, planning. May be human-authored or agent-authored. Not part of the wiki; these are project-specific artifacts.

**projects/** — Actual software (pi-agent, etc.) as submodules or subdirs. Not indexed by qmd — code, not knowledge.

**tools/** — Scripts and configs that support the devstack workflow.

## Wiki Schema

See [`docs/WIKI.md`](docs/WIKI.md) for the full wiki operational schema (operations, page conventions, frontmatter format, index/log formats, subdirectories, filing rules).

## Setup

### Coding Agents

This repo is designed to work with multiple coding agents. We use `AGENTS.md` as the canonical instruction file with `CLAUDE.md` symlinked to it (see [AGENTS.md](AGENTS.md) for details).

#### Claude Code

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) is Anthropic's CLI agent. Install via the [official instructions](https://docs.anthropic.com/en/docs/claude-code/getting-started).

```bash
# Authenticate
export ANTHROPIC_API_KEY=sk-ant-...
# Or use: claude login
```

Claude Code automatically loads `CLAUDE.md` (→ symlink → `AGENTS.md`) from the repo root.

#### Pi Agent

[Pi](https://pi.dev) ([GitHub](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent)) is a minimal, extensible terminal coding harness. It supports 20+ LLM providers and is built around a TypeScript extension system rather than batteries-included features.

```bash
# Install (pick one)
curl -fsSL https://pi.dev/install.sh | sh     # install script
npm install -g @mariozechner/pi-coding-agent   # npm global

# Authenticate (pick one)
export ANTHROPIC_API_KEY=sk-ant-...            # API key
pi                                             # then /login for subscription auth
```

Pi automatically loads `AGENTS.md` (or `CLAUDE.md`) by walking parent directories from cwd — same pattern as Claude Code.

**Key config paths:**
- `~/.pi/agent/settings.json` — global settings
- `.pi/settings.json` — project-level overrides
- `~/.pi/agent/extensions/` — TypeScript extensions
- `~/.pi/agent/skills/` — skills (also `.pi/skills/`, `.agents/skills/`)
- `~/.pi/agent/prompts/` — prompt templates
- `.pi/SYSTEM.md` — system prompt override

**Packages:** Pi supports installable packages bundling extensions, skills, prompts, and themes:
```bash
pi install npm:@foo/pi-tools
pi install git:github.com/user/repo@v1
pi list
pi update
```

See [wiki/tools/pi-agent.md](wiki/tools/pi-agent.md) for full evaluation notes and comparison with Claude Code. See [pi.dev docs](https://pi.dev/docs/latest) for complete documentation.

#### Codex (OpenAI)

[Codex](https://github.com/openai/codex) is OpenAI's CLI agent. It reads `AGENTS.md` natively.

```bash
npm install -g @openai/codex
export OPENAI_API_KEY=sk-...
codex
```

### qmd

[qmd](https://github.com/tobi/qmd) is a local semantic search engine + MCP server for markdown/code collections. Hybrid BM25 + vector search with on-device models — the retrieval layer for wiki search at scale.

```bash
# Install
npm install -g @tobilu/qmd

# Add collections and build embeddings
qmd collection add ~/github/lhl/devstack/wiki --name devstack-wiki
qmd collection add ~/github/lhl/devstack/sources --name devstack-sources
qmd embed

# Run as MCP server (for Claude Code / Codex)
qmd mcp --http --daemon
```

## Sources & References

- [sources/gists/karpathy-llm-wiki.md](sources/gists/karpathy-llm-wiki.md) — Karpathy's original LLM Wiki gist
- [sources/gists/rohitg00-llm-wiki-v2.md](sources/gists/rohitg00-llm-wiki-v2.md) — LLM Wiki v2 spec (lifecycle, knowledge graphs, scale)
- [sources/conversations/RESEARCH-llmwiki.md](sources/conversations/RESEARCH-llmwiki.md) — Survey of LLM Wiki ecosystem and project recommendations

### Related

- [github.com/lhl/agentic-memory](https://github.com/lhl/agentic-memory) — deeper research on agentic memory systems (benchmarks, architectures)
