# devstack

Handbook / framework / toolkit for agentic programming practices.

## Components

- **Pi Agent** — personal agent framework
- **RTK** — Rust Token Killer (CLI proxy for token-optimized dev operations)
- **Goal / Ralph Loop / AutoResearch** — autonomous research and goal-tracking patterns
- **LLM Wiki** — git-backed, agent-maintained knowledge base (Karpathy pattern)

## Repo Structure

```
devstack/
├── README.md              # This file — overview + wiki schema
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
├── docs/                  # Project working docs for this repo
├── projects/              # Software submodules / subdirs
└── tools/                 # Scripts, configs, utilities
```

### Directory roles

**inbox/** — Drop anything here: URLs, PDFs, conversations, screenshots, half-formed notes. The agent processes items into `wiki/` pages and archives originals into `sources/`. Unprocessed items live here until ingested.

**sources/** — Karpathy's "raw" layer. Immutable once filed. The agent reads from here but never modifies these files. Organized by type. Binary files (PDFs, images) can use Git LFS via `.gitattributes`.

**wiki/** — Agent-owned. The agent creates, updates, and cross-links pages here. Humans read it; the agent writes it. Every page should use `[[wikilinks]]` for cross-references. `index.md` is the entry point — a categorized catalog of all pages with one-line summaries. `log.md` is an append-only chronological record of operations (ingests, queries, lint passes).

**docs/** — Working documents for this repo itself — development notes, research, planning. May be human-authored or agent-authored. Not part of the wiki; these are project-specific artifacts.

**projects/** — Actual software (pi-agent, etc.) as submodules or subdirs. Not indexed by qmd — code, not knowledge.

**tools/** — Scripts and configs that support the devstack workflow.

## Wiki Schema

### Operations

**Ingest** — Process material from `inbox/` or `sources/` into the wiki:
1. Read the source material
2. Discuss key takeaways
3. Write or update summary page in `wiki/`
4. Update related concept, tool, and project pages
5. Update `wiki/index.md`
6. Append entry to `wiki/log.md`
7. Move original from `inbox/` to appropriate `sources/` subfolder

A single source may touch 5-15 wiki pages.

**Query** — Answer questions using the wiki:
1. Read `wiki/index.md` to find relevant pages
2. Read those pages, synthesize an answer
3. If the answer is substantial and reusable, file it as a new wiki page

**Lint** — Periodic health check:
- Orphan pages with no inbound links
- Stale claims superseded by newer sources
- Concepts mentioned but lacking their own page
- Missing cross-references
- Contradictions between pages

### Page conventions

- Frontmatter with `title`, `tags`, `sources` (list of source file paths)
- `[[wikilinks]]` for cross-references between wiki pages
- One concept per page — split rather than merge
- Pages link back to their sources in `sources/`

### log.md format

```markdown
## [2026-05-03] ingest | Karpathy LLM Wiki gist
- Source: sources/gists/karpathy-llm-wiki.md
- Pages created: (list)
- Pages updated: (list)
```

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
- [docs/RESEARCH-llmwiki.md](docs/RESEARCH-llmwiki.md) — Survey of LLM Wiki ecosystem and project recommendations

### Related

- [github.com/lhl/agentic-memory](https://github.com/lhl/agentic-memory) — deeper research on agentic memory systems (benchmarks, architectures)
