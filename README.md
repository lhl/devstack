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

## Why Pi Is Neat

- **extensions**: built to be customized/extended. anything you don't like? tell pi to change itself. Almost everything can be refreshed with `/reload` without a restart — see my list for how w/ minimal yak-shaving, you can customize something to be *very* specific to your preferences
- **models**: scope your model list to your fav providers, check out new/free stuff on openrouter, swap between different models
- **non-blocking**: unlike Claude Code/Codex, most UI/commands (switching models, effort, getting status) are *not* blocked while the model is running. this is obvious and how it should be???
- **advanced history**: I don't know if other harnesses have these, but pi makes it easy to time-travel, fork, clone your sessions/rollouts which is very convenient (`/tree`, `/fork`, `/clone`)
- **caveat**: Pi moves relatively fast and there have been a lot of breaking changes — you sort of need to be on top of things with updates. The upside is that maintenance can be handled mostly by your coding agent and all the source is available, so you don't get Claude Code-style breaking where you're stuck (e.g., Claude got dumb for a month and you get gaslit by Anthropic about it)

## My Pi Extensions

Oftentimes there are multiple options for a feature; these are the ones I've picked. My preference is for composability (doing one thing well). Some things don't exist and I've made my own; some are unmaintained or part of monorepos and in those cases I've forked for maintainability/updatability.

### Web Access

This is probably the biggest feature you're going to need. `pi-web-access` is the most popular and robust plugin, and the others augment the capabilities with better data extraction or more robust browsing

- [nicobailon/pi-web-access](https://github.com/nicobailon/pi-web-access) - web search, content extraction, video/YT, GitHub clone, PDF
- [Thinkscape/agent-smart-fetch](https://github.com/Thinkscape/agent-smart-fetch) (pi-smart-fetch) - browser-like TLS fingerprints + Defuddle site extractors
- [MonsieurBarti/camoufox-pi](https://github.com/MonsieurBarti/camoufox-pi) - stealth web access via Camoufox anti-fingerprinting Firefox fork (requires `npx camoufox fetch` + `/reload`)
  - [Camoufox](https://github.com/daijro/camoufox) - there are a few different builds, but basically, it's a Firefox fork designed for AI agents

### Automation & Workflow

There are also a bajillion sub-agent extensions, I mostly would rather start new sessions or control my sub-agents rather than having them spawned willy-nilly, but if I find a good extension I actually use, I'll add it here.

- [lhl/pi-multiloop](https://github.com/lhl/pi-multiloop) - my autoloop. A from-scratch implementation from the things I learned from my [codex-autoresearch](https://github.com/lhl/codex-autoresearch/) fork and from my experience working with autoloops since mid-2025. Published to npm and installed via `npm:pi-multiloop`.
- [tintinweb/pi-schedule-prompt](https://github.com/tintinweb/pi-schedule-prompt) - if you just want an easy heartbeat (recurring cron-like tasks, or one-shot tasks) this does the job 

### Context Management 

For saving tokens.

- [MasuRii/pi-rtk-optimizer](https://github.com/MasuRii/pi-rtk-optimizer) - the most mature/complete `rtk` plugin (`rtk` is a standalone rust binary that dynamically filters and compresses command outputs before they reach LLM context for huge token savings)
  - [rtk](https://github.com/rtk-ai/rtk) — if you pay for tokens or have a quota, I've found this to be the easiest way to reduce token consumption
- [nicobailon/pi-boomerang](https://github.com/nicobailon/pi-boomerang) - this allows launching subagents for tasks that deliver just summarized outputs to your harness 
- [sting8k/pi-vcc](https://github.com/sting8k/pi-vcc) - zero-LLM algorithmic compaction. Replaces pi's default single-pass LLM summarization with deterministic extraction (goal / files / commits / outstanding / preferences + rolling transcript). We install this with `overrideDefaultCompaction: true` (see `pi-setup.sh`) because pi core's default compaction can fail with `400 status code (no body)` when the summarization span exceeds the summarizer LLM's input window; pi-vcc never makes that LLM call. Prior history stays searchable via `vcc_recall` / `/pi-vcc-recall`. Evaluation and alternatives (`pi-grounded-compaction`, `@pi-unipi/compactor`, `pi-agentic-compaction`) documented in [`wiki/tools/pi-agent.md`](wiki/tools/pi-agent.md#compaction-landscape).

### Account & Quota Management

- [victor-software-house/pi-multicodex](https://github.com/victor-software-house/pi-multicodex) - automatic ChatGPT Codex account rotation when quota limits or rate limits are hit
- [pi-codex-status](https://www.npmjs.com/package/pi-codex-status) - CLI + pi extension for ChatGPT Codex quota visibility (`/status`, `pi-codex-status statusline`, normalized JSON export); source: [lhl/pi-codex-status](https://github.com/lhl/pi-codex-status)

### Task Management

- [tintinweb/pi-tasks](https://github.com/tintinweb/pi-tasks) - Claude Code-style task tracking with 7 LLM-callable tools, dependency management, and a persistent visual widget

### UX

- [lhl/pi-skill-dollar](https://github.com/lhl/pi-skill-dollar) - `$` autocomplete shortcut that triggers skill suggestions in the input area
- [lhl/pi-zentui](https://github.com/lhl/pi-zentui) - my personal fork of a status-line that fits my preferences
- [mattleong/pi-code-previews](https://github.com/mattleong/pi-code-previews) - for better syntax-highlighting from tool calls

### Skills

- `outline-edit` — CLI for Outline knowledge base with local markdown cache (pip, mambaforge)

## Models (as of May 2026)

Pi supports a number of providers OOTB including most first-party frontier model providers as well as Bedrock, Vertex, and HuggingFace and OpenRouter.

### Custom Providers

- [`@lhl/pi-vertex`](https://www.npmjs.com/package/@lhl/pi-vertex) — Google Vertex AI provider with Gemini, Claude, Llama, DeepSeek, Qwen, Mistral, and 20+ other MaaS models. Forked from `@ssweens/pi-vertex` with added tests, CI, and linting; source: [lhl/pi-vertex](https://github.com/lhl/pi-vertex).
  ```bash
  pi install npm:@lhl/pi-vertex
  export GOOGLE_CLOUD_PROJECT=your-project-id
  export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
  pi --provider vertex --model claude-opus-4-6
  ```

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


## Guides & Writeups

Things I've written about agentic coding and dev workflows:

- [Agentic Coding](writing/20260415%20Agentic%20Coding.pdf) — talk/slides on agentic coding practices (April 2026)
- [Supply Chain Security for Software Developers](writing/202604-supply-chain-security.md) — practical supply chain security for devs (April 2026)
- [My Workflow](writing/202602-lhl-workflow.md) — personal AI-assisted coding workflow notes (February 2026)

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
