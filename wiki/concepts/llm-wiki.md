---
title: LLM Wiki
tags: [concept, knowledge-management, pattern]
sources:
  - sources/gists/karpathy-llm-wiki.md
  - sources/gists/rohitg00-llm-wiki-v2.md
  - sources/conversations/RESEARCH-llmwiki.md
links:
  - https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
  - https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2
  - https://github.com/tjiahen/awesome-llm-wiki
  - https://github.com/tobi/qmd
---

# LLM Wiki

The LLM Wiki pattern is a knowledge management approach where a coding agent **compiles** raw source material into a structured, interlinked markdown wiki — rather than re-deriving answers via RAG on every query. Originated as an "idea file" by Andrej Karpathy (April 2026).

## Core Idea

The key insight: stop doing RAG (which rediscovers the same facts on every query) and instead have the LLM compile sources into a stable wiki once, then query the wiki. The compiled result is version-controlled, human-readable, and navigable without any infrastructure.

## Architecture (Three Layers)

- **`raw/` (or `sources/`)** — immutable source material: PDFs, web clippings, papers, transcripts, notes, code dumps. The LLM reads this but never edits it.
- **`wiki/`** — LLM-owned: summary pages, entity pages, concept pages, cross-references via `[[wikilinks]]`, an `index.md`. You read it, the LLM writes it.
- **Schema** (`CLAUDE.md` / `AGENTS.md`) — the contract that tells the agent how to ingest, where to file, how to link, when to lint.

## Four Operations

1. **Ingest** — drop a source into raw, ask the agent to integrate it
2. **Compile** — the agent writes/updates wiki pages, touching 10–15 related pages on a single ingest, flagging contradictions
3. **Query** — ask questions; the agent reads the already-synthesized wiki, not the raw sources, then files good answers back as new pages
4. **Lint** — periodic audit pass for orphans, stale claims, missing concept pages, contradictions

## Scale Characteristics

- At ~100 articles / ~400K words, the LLM's ability to navigate via summaries and index files is sufficient — no vector DB needed
- Gets shaky around ~500 articles
- Beyond that, bolt on hybrid search (e.g., [[tools/qmd]])

## Canonical Sources

| Source | What it is |
| --- | --- |
| [Karpathy's gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) | Original idea file — designed to be pasted into your agent |
| [rohitg00 LLM Wiki v2](https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2) | Most-cited extension — adds typed knowledge graph, BM25+vector+graph retrieval, confidence scoring, supersession tracking, forgetting curve |
| [tjiahen/awesome-llm-wiki](https://github.com/tjiahen/awesome-llm-wiki) | Curated index of ~30 projects categorized by type |

## Notable Implementations

### Agent-Agnostic (Claude Code + Codex + Cursor + Gemini CLI)

- **[Astro-Han/karpathy-llm-wiki](https://github.com/Astro-Han/karpathy-llm-wiki)** — installable Agent Skill; battle-tested with 94 articles maintained daily since April 2026
- **[SamurAIGPT/llm-wiki-agent](https://github.com/SamurAIGPT/llm-wiki-agent)** — multi-platform via separate schema files per agent; detects contradictions at ingest time
- **[Pratiyush/llm-wiki](https://github.com/Pratiyush/llm-wiki)** — ingests existing CLI session transcripts (`.jsonl`) into wiki; emits `llms.txt` / JSON-LD

### MCP-Native

- **[lucasastorian/llmwiki](https://github.com/lucasastorian/llmwiki)** — MCP server; Claude gets `search`/`read`/`write`/`delete` tools. Hosted version at llmwiki.app
- **[iamsashank09/llm-wiki-kit](https://github.com/iamsashank09/llm-wiki-kit)** — pip-installable MCP server with PDF, URL, and YouTube transcript extraction

### Obsidian-Native

- **[AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian)** — 10 specialized skills, contradiction flagging, autonomous research loops
- **[NicholasSpisak/second-brain](https://github.com/NicholasSpisak/second-brain)** — minimalist Obsidian-vault drop-in
- **[YishenTu/Claudian](https://github.com/YishenTu/Claudian)** — native Obsidian plugin embedding Claude Code with plan mode and inline diff editing

### Research-Agent Style

- **[nvk/llm-wiki](https://github.com/nvk/llm-wiki)** — deploys 5–10 parallel specialized sub-agents for thesis-driven multi-round investigation with confirmation-bias countering

### Knowledge Graph

- **[skridlevsky/graphthulhu](https://github.com/skridlevsky/graphthulhu)** — MCP server for Logseq/Obsidian graphs; treats decisions as first-class objects
- **[nashsu/llm_wiki](https://github.com/nashsu/llm_wiki)** — desktop app with 4-signal relevance model and Louvain community detection

## Retrieval Layer: qmd

[qmd](https://github.com/tobi/qmd) by Tobi Lütke is the Karpathy-recommended retrieval tool. Local CLI + MCP server with:
- LLM query expansion (1.7B fine-tune)
- Parallel BM25 (SQLite FTS5) + vector search (embeddinggemma-300M)
- RRF fusion with local reranker (qwen3-reranker-0.6B)
- Tree-sitter AST-aware chunking for code files

See [[tools/pi-agent]] for how this integrates with our setup.

## Critiques and Limitations

- **The wiki critique**: scoping should be deterministic and reasoning probabilistic — Zettelkasten-style atoms with stable IDs may be closer to Bush's Memex than a self-rewriting document
- **Linting is the discipline**: without periodic lint passes the wiki rots (orphans, contradictions, untracked supersession)
- **Scale ceiling**: "no vector DB needed" holds at ~100 articles, breaks past ~500
- **The awesome list is young**: `tjiahen/awesome-llm-wiki` is comprehensive but barely starred; individual project activity is the better signal

## Our Implementation

This devstack repo uses the LLM Wiki pattern. See `docs/WIKI.md` for our operational schema. Key differences from the vanilla pattern:
- Uses `sources/` (not `raw/`) with subdirs by format/origin
- `inbox/` as explicit staging area before filing to `sources/`
- Structured `wiki/log.md` for operation tracking
- `AGENTS.md` as the schema file (compatible with Claude Code, Pi, and Codex)
