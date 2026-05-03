> What are the most active/useful Karpathy installed LLM Wiki projects, let's answer this in an introduction to LLM Wiki Guide format (or basically a Claude Code/Codex powered KB) - I know there are a lot of tools out there, probably some "awesome LLM Wiki" projects (the meta-goal for the guide is to make sure that someone getting started can basically build a git-basked agentic knowledge graph/knowledge base they can add to and consult).

I found the awesome list. Let me grab the canonical inventory.Let me confirm activity/star counts on the most-mentioned implementations.## Restated question

You're asking: among the open-source projects that have emerged from Andrej Karpathy's April 2026 "LLM Wiki" gist (the [`llm-wiki.md` idea file](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), which proposes that a coding agent like Claude Code or Codex *compiles* a folder of raw sources into a structured, interlinked, self-maintained markdown wiki — rather than re-deriving answers via RAG on every query) — which specific GitHub projects are currently most active and most useful, including any "awesome-list" indexes, for someone who wants to bootstrap a **git-tracked, agent-maintained knowledge graph / KB** they can keep adding sources to and consulting? You want this as an "Intro to LLM Wiki" guide aimed at the build-it-yourself end of the spectrum.

---

# An LLM Wiki Guide

## 1. The pattern in 60 seconds

Karpathy's gist is deliberately not code — he calls it an "idea file" meant to be copy-pasted into a coding agent which then instantiates a version for your specific needs. The shift it argues for: stop doing RAG, which rediscovers the same facts on every query, and instead have the LLM *compile* sources into a stable wiki once, then query the wiki.

Three layers, mostly converged across implementations:

- **`raw/`** — immutable source material: PDFs, web clippings (Obsidian Web Clipper → markdown), papers, transcripts, notes, code dumps. The LLM reads this but never edits it.
- **`wiki/`** — LLM-owned: summary pages, entity pages, concept pages, cross-references via `[[wikilinks]]`, mermaid diagrams, an `index.md`. You read it, the LLM writes it.
- **schema** — `CLAUDE.md` / `AGENTS.md` / `MEMORY.md` — the contract that tells the agent how to ingest, where to file, how to link, when to lint.

Four operations:

1. **Ingest** — drop a source into `raw/`, ask the agent to integrate it.
2. **Compile** — the agent writes/updates wiki pages, touching 10–15 related pages on a single ingest, flagging contradictions.
3. **Query** — you ask questions; the agent reads the *already synthesized* wiki, not the raw sources, then files good answers back as new pages.
4. **Lint** — periodic audit pass for orphans, stale claims, missing concept pages, contradictions.

The key claim, which holds up well at "personal research project" scale: at ~100 articles / ~400,000 words, the LLM's ability to navigate via summaries and index files is more than sufficient — vector-DB infrastructure introduces more retrieval noise than it solves at this scale. Beyond that scale, you bolt on hybrid search (qmd, below).

## 2. Canonical sources to read first

These three documents *are* the foundation. Skim them in order, then pick implementations.

- **[karpathy/442a6bf555914893e9891c11519de94f](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)** — the original. Explicitly designed to be pasted into your agent.
- **[rohitg00/2067ab416f7bbe447c1977edaaa681e2](https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2)** — "LLM Wiki v2", the most-cited extension. Adds a typed knowledge graph, BM25+vector+graph triple retrieval, confidence scoring, supersession tracking, and a retention/forgetting curve. Worth reading even if you don't use it — it inventories the failure modes the basic pattern hits at scale.
- **[tjiahen/awesome-llm-wiki](https://github.com/tjiahen/awesome-llm-wiki)** — the closest thing to a curated index. Categorizes ~30 projects into Foundational Pattern / Core Implementations / CLI Tools / Knowledge Graphs+MCP / Learning Layers / Schemas. Caveat: it's still small (~1 star at the time of writing) and itself uses the wiki pattern, so treat it as a starting bibliography rather than a popularity ranking.

## 3. The retrieval layer (Karpathy-recommended): qmd

If there's one "Karpathy-installed" tool in the strict sense — i.e., one he explicitly points at as part of his stack — it's **[tobi/qmd](https://github.com/tobi/qmd)** by Tobi Lütke (Shopify CEO). It's the search engine he uses on top of the markdown wiki.

What it actually is: a local CLI + MCP server. The pipeline is well-engineered for this exact use case:

- LLM query expansion (1.7B fine-tune, generates 2 variants, original gets 2× weight)
- Parallel BM25 (SQLite FTS5) and vector search (embeddinggemma-300M)
- RRF fusion (k=60) with top-rank bonus
- Local reranker (qwen3-reranker-0.6B) on top 30 candidates
- Position-aware blend: ranks 1–3 trust retrieval more (75/25), ranks 11+ trust the reranker more (40/60)
- Tree-sitter AST-aware chunking for code files (`.ts/.js/.py/.go/.rs`), regex chunking with markdown-heading boundaries elsewhere

Everything runs on-device via node-llama-cpp with GGUF models. Install: `npm install -g @tobilu/qmd`, then `qmd collection add ~/wiki --name wiki && qmd embed && qmd mcp` to expose it to Claude Code / Codex as an MCP server. This is the single most useful "supporting" project to install regardless of which wiki framework you adopt — your agent will use it as a tool.

Companion: **[AlexZeitler/lazyqmd](https://github.com/AlexZeitler/lazyqmd)** — a TUI for qmd with collection navigation, markdown preview, in-place nvim editing.

## 4. Core agent-driven implementations (pick one)

Sorted by what they're actually best at, not alphabetically.

**If you want maximum agent agnosticism (Claude Code + Codex + Cursor + Gemini CLI):**
- **[Astro-Han/karpathy-llm-wiki](https://github.com/Astro-Han/karpathy-llm-wiki)** — packages the pattern as an installable Agent Skill. Built from a real KB with 94 articles and 99 sources maintained daily since April 2026, so the prompt structure is battle-tested rather than speculative.
- **[SamurAIGPT/llm-wiki-agent](https://github.com/SamurAIGPT/llm-wiki-agent)** — multi-platform via separate schema files per agent; notably detects contradictions at *ingest* time rather than deferring everything to the lint pass.
- **[Pratiyush/llm-wiki](https://github.com/Pratiyush/llm-wiki)** — the interesting twist: ingests your existing Claude Code / Codex CLI / Cursor / Gemini CLI session transcripts (`.jsonl`) into the wiki, plus emits `llms.txt` / `llms-full.txt` / JSON-LD for downstream agents. Useful if you want your past coding sessions to become first-class knowledge.

**If you want MCP-native (Claude.ai connects directly):**
- **[lucasastorian/llmwiki](https://github.com/lucasastorian/llmwiki)** — ships an MCP server; Claude gets `search`/`read`/`write`/`delete` tools across the vault. Hosted version at llmwiki.app, but the code is the point.
- **[iamsashank09/llm-wiki-kit](https://github.com/iamsashank09/llm-wiki-kit)** — pip-installable MCP server with optional extras for PDF, URL extraction, and YouTube transcripts. Easiest "agent gets persistent memory across sessions" setup.

**If you want Obsidian as the GUI:**
- **[AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian)** — 10 specialized skills, contradiction flagging, autonomous research loops, installable from the Claude Code marketplace. The most production-feeling Obsidian-native implementation.
- **[NicholasSpisak/second-brain](https://github.com/NicholasSpisak/second-brain)** — minimalist Obsidian-vault drop-in; lets you browse the compiled result with graph view.
- **[YishenTu/Claudian](https://github.com/YishenTu/Claudian)** — native Obsidian plugin embedding Claude Code with plan mode, `@mention`, word-level inline diff editing.

**If you want a research-agent style (parallel investigation, not just compilation):**
- **[nvk/llm-wiki](https://github.com/nvk/llm-wiki)** — CLI that deploys 5–10 parallel specialized sub-agents (academic / technical / contrarian / etc.) for thesis-driven multi-round investigation with confirmation-bias countering. Closer in spirit to a research orchestrator than a notebook.

**If you want something more like a real knowledge graph:**
- **[skridlevsky/graphthulhu](https://github.com/skridlevsky/graphthulhu)** — MCP server giving agents read/write access to Logseq or Obsidian graphs; treats decisions as first-class objects.
- **[nashsu/llm_wiki](https://github.com/nashsu/llm_wiki)** — desktop app with a 4-signal relevance model and Louvain community detection for automatic knowledge clustering.

## 5. Schemas / specifications

The schema file is more important than which framework you pick. The active conventions:

- **`CLAUDE.md`** — Anthropic's project-level memory file for Claude Code. This is where your wiki's compile/query/lint rules live.
- **`AGENTS.md`** — OpenAI's parallel convention; some implementations (e.g. `Pratiyush/llm-wiki`) ship both so the same wiki works under Codex *and* Claude Code.
- **`MEMORY.md`** (from `claude-obsidian`) — index-first routing-table approach: always loaded at session start, points at domain-specific topic files. Useful pattern even outside that project.

## 6. A recommended starter stack

For someone in your position (research-heavy, multiple agents, wants git as the substrate, doesn't want to be Obsidian-locked), this is what I'd actually run:

1. **`git init` a `~/wiki/` repo** with `raw/`, `wiki/`, `CLAUDE.md`, `AGENTS.md`. Put `raw/` in Git LFS or `.gitignore` if you'll have large PDFs — Karpathy keeps everything in the same repo, but disk-friendliness varies.
2. **Paste Karpathy's gist into `CLAUDE.md`** as the seed, then iterate it with your agent into your actual schema. This is the intended workflow — don't skip it for a pre-built schema.
3. **Install qmd** as the retrieval layer: `npm install -g @tobilu/qmd && qmd collection add ~/wiki && qmd embed && qmd mcp --http --daemon`. Wire it into Claude Code and Codex as an MCP server. This is the single highest-leverage install.
4. **Pick one agent skill package** as the compile/lint workflow — `Astro-Han/karpathy-llm-wiki` if you want something opinionated and battle-tested, `SamurAIGPT/llm-wiki-agent` if you want ingest-time contradiction detection, or roll your own slash-commands (`/wiki-ingest`, `/wiki-query`, `/wiki-lint`) which is what most people end up doing within a week anyway.
5. **Read `rohitg00/2067ab416f7bbe447c1977edaaa681e2` v2** before you have ~50 articles, not after. Confidence scoring, supersession, and forgetting are easier to add to a small wiki than retrofit to a rotted one.
6. **Commit early, commit often.** The git history *is* the provenance trail — ingest commits, compile commits, lint commits should be cleanly separated. This is the part everyone gets wrong.

## 7. Caveats worth knowing before you commit

- **The wiki critique.** A serious thread of objection (visible in the Karpathy gist's own comments) is that scoping should be deterministic and reasoning should be probabilistic — Zettelkasten-style atoms with stable IDs and explicit links may be closer to Bush's Memex than a single self-rewriting document. If you find yourself not trusting the LLM-rewritten wiki, that critique is why; the synthesis layer wants to live as separate notes that *cite* immutable atoms, not absorb them.
- **Linting is the discipline.** Without periodic lint passes the wiki rots — orphan pages accumulate, contradictions stack, supersession isn't tracked. Most v2-style extensions exist because the original pattern under-specifies maintenance.
- **Scale ceiling.** The "no vector DB needed" claim is true around ~100 articles, gets shaky around ~500, and breaks somewhere past that. qmd or a real graph layer is the upgrade path, not optional.
- **The "awesome list" is young.** `tjiahen/awesome-llm-wiki` is comprehensive but barely starred; it's a bibliography, not a popularity ranking. For now, GitHub stars on the *individual* projects are the better signal — `tobi/qmd`, `lucasastorian/llmwiki`, and `AgriciDaniel/claude-obsidian` are the highest-velocity ones in active development.

The shortest version of all of this: **paste Karpathy's gist into Claude Code, install qmd, and let your agent build out the schema interactively**. Everything else is a variation on that.
