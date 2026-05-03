# devstack

An opiniated guide for agentic programming best practices. This is what I'm currently using/moving towards to for development.

## Coding Agent

[Pi Coding Agent](https://pi.dev/) is an open source "minimal terminal coding harness" that is designed be customized and adapt to the way you want to work. You can start with Claude Code, OpenAI Codex, OpenCode or any harness you want, but if you're looking to start really customizing your workflow/experience, or looking for the best tool to use with multiple models (or just looking for a harness that won't introduce ridiculous regressions constantly), I believe Pi Agent's flexibility and ease of customization actually makes it the current best option. 

You should visit their nicely designed website to get a better idea of what it's all about, but if you just want to install my current setup (pi + my plugins):

```bash
git clone https://github.com/lhl/devstack
cd devstack
./pi-setup.sh
```

### Web Access

This is probably the biggest feature you're going to need. `pi-web-access` is the most popular and robust plugin, and the others augment the capabilities with better data extraction or more robust browsing

- [nicobailon/pi-web-access](https://github.com/nicobailon/pi-web-access) - web search, content extraction, video/YT, GitHub clone, PDF
- [Thinkscape/agent-smart-fetch](https://github.com/Thinkscape/agent-smart-fetch) (pi-smart-fetch) - browser-like TLS fingerprints + Defuddle site extractors
- [MonsieurBarti/camoufox-pi](https://github.com/MonsieurBarti/camoufox-pi) - stealth web access via Camoufox anti-fingerprinting Firefox fork (requires `npx camoufox fetch` + `/reload`)
  - [Camoufox](https://github.com/daijro/camoufox) - there are a few different builds, but basically, it's a Firefox fork designed for AI agents

### Automation & Workflow

There are also a bajillion sub-agent extensions, I mostly would rather start new sessions or control my sub-agents rather than having them spawned willy-nilly, but if I find a good extension I actually use, I'll add it here.

- [lhl/pi-multiloop](https://github.com/lhl/pi-multiloop) - my autoloop. A from-scratch implementation from the things I learned from my [codex-autoresearch](https://github.com/lhl/codex-autoresearch/) fork and from my experience working with autoloops since mid-2025
- [tintinweb/pi-schedule-prompt](https://github.com/tintinweb/pi-schedule-prompt) - if you just want an easy heartbeat (recurring cron-like tasks, or one-shot tasks) this does the job 

### Context Management 

For saving tokens.

- [MasuRii/pi-rtk-optimizer](https://github.com/MasuRii/pi-rtk-optimizer) - the most mature/complete `rtk` plugin (`rtk` is a standalone rust binary that dynamically filters and compresses command outputs before they reach LLM context for huge token savings)
  - [rtk](https://github.com/rtk-ai/rtk) — if you pay for tokens or have a quota, I've found this to be the easiest way to reduce token consumption
- [nicobailon/pi-boomerang](https://github.com/nicobailon/pi-boomerang) - this allows launching subagents for tasks that deliver just summarized outputs to your harness 
- [Tiziano-AI/pi-continue](https://github.com/Tiziano-AI/pi-continue) - Pi has good compaction OOTB (the plugins I looked at weren't unambiguous improvements) but this is one nice add-on that helps with the corner case where you run out of context mid-run

### UX

- [lhl/pi-zentui](https://github.com/lhl/pi-zentui) - my personal fork of a status-line that fits my preferences
- [mattleong/pi-code-previews](https://github.com/mattleong/pi-code-previews) - for better syntax-highlighting from tool calls

### Skills

- `outline-edit` — CLI for Outline knowledge base with local markdown cache (pip, mambaforge)

## Models (as of May 2026)

Pi supports a number of providers OOTB including most first-party frontier model providers as well as Bedrock, Vertex, and HuggingFace and OpenRouter.

My current best coding models:
- GPT-5.5 xhigh
- GPT-5.4 xhigh
- Opus-4.7 xhigh
- Opus-4.6 max
- GPT-5.3-codex xhigh
- GPT-5.2 xhigh

I haven't used enough of the latest open models but these should be good (Sonnet 4.x level?):
- DeepSeek V4 Pro
- MiniMax M2.7
- Kimi K2.6
- MiMo V2.5 Pro
- Qwen3.6 Max Preview


## This Repo

This repo is also an LLM Wiki (Karpathy pattern) — a personal knowledge base where an agent ingests sources, compiles synthesized wiki pages, and maintains cross-links. Detailed docs for each component at `wiki/tools/`. Extension evaluations and comparisons at `wiki/tools/pi-agent.md`.

### Tools

| Tool | Version | Install | Purpose |
|---|---|---|---|
| `qmd` | 2.1.0 | npm (global) | Local semantic search engine for markdown/code collections |

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

## Sources & References

- [sources/gists/karpathy-llm-wiki.md](sources/gists/karpathy-llm-wiki.md) — Karpathy's original LLM Wiki gist
- [sources/gists/rohitg00-llm-wiki-v2.md](sources/gists/rohitg00-llm-wiki-v2.md) — LLM Wiki v2 spec (lifecycle, knowledge graphs, scale)
- [sources/conversations/RESEARCH-llmwiki.md](sources/conversations/RESEARCH-llmwiki.md) — Survey of LLM Wiki ecosystem and project recommendations

### Related

- [github.com/lhl/agentic-memory](https://github.com/lhl/agentic-memory) — deeper research on agentic memory systems (benchmarks, architectures)
