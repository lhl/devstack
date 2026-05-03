---
title: Pi Coding Agent
tags: [tools, coding-agent, terminal, extensible]
sources:
  - sources/gists/karpathy-llm-wiki.md
links:
  - https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent
  - https://pi.dev
  - https://github.com/qualisero/awesome-pi-agent
  - https://github.com/ifiokjr/oh-pi
  - https://github.com/ArtemisAI/pi-loop
  - https://github.com/tintinweb/pi-schedule-prompt
  - https://github.com/Tiziano-AI/pi-continue
---

# Pi Coding Agent

Pi (pi.dev) is a minimal, extensible terminal coding harness by Mario Zechner (badlogic/Earendil Inc). It provides a lean foundation — 4 default tools, no built-in MCP, no plan mode, no permission system — with the philosophy that users build what they need via extensions.

## Installed Extensions

| Extension | npm | Purpose | Status |
|---|---|---|---|
| **pi-rtk-optimizer** | `npm:pi-rtk-optimizer` | Token optimization via RTK command rewriting + output compaction | ✅ Installed |
| **pi-schedule-prompt** | `npm:pi-schedule-prompt` | Natural language scheduling, cron, per-task model | ✅ Installed |
| **pi-boomerang** | `npm:pi-boomerang` | Token-efficient autonomous loops — summarize between iterations | ✅ Installed |
| **pi-continue** | `git:pi-continue` | Mid-run context compaction with Continuation Ledger | ✅ Installed (v0.6.0, local) |
| **pi-code-previews** | `git:pi-code-previews` | Shiki syntax-highlighted tool output rendering in TUI | ✅ Installed (v0.1.14, local) |

**Install commands:**
```bash
pi install npm:pi-schedule-prompt

# pi-continue and pi-code-previews installed from local git clones due to npm 11 peer-dep issue:
# git clone https://github.com/Tiziano-AI/pi-continue .pi/git/pi-continue
# git clone https://github.com/mattleong/pi-code-previews .pi/git/pi-code-previews
# pi install -l .pi/git/pi-continue
# pi install -l .pi/git/pi-code-previews
# pi-code-previews requires shiki as a manual global dependency:
# npm install -g shiki
```

## Installed Extension Usage

### pi-rtk-optimizer

```
/rtk              # Open interactive TUI settings modal
/rtk stats        # Show compaction metrics for session
/rtk verify       # Check if rtk binary is available
/rtk reset        # Reset to defaults
```

### pi-schedule-prompt

```
# Recurring prompts
/schedule-prompt "check build status" every 5 minutes
/schedule-prompt "analyze metrics" every hour

# One-time reminders
/schedule-prompt "review PR in 30 minutes"
/schedule-prompt "follow up tomorrow at 9am"

# Via LLM tools
schedule_wakeup delaySeconds=300
cron_create cron="0 * * * *" prompt="hourly check"
```

### pi-boomerang

```
# Plain task
/boomerang Fix the login bug

# Run prompt template
/boomerang /commit "fix auth bug"

# Chain templates
/boomerang /scout "map auth" -> /planner "design JWT" -> /impl

# Auto-boomerang for next prompt (shortcut: Ctrl+Alt+B)
/boomerang auto on

# Cancel mid-task
/boomerang-cancel
```

**Key feature:** Replaces full turn history with compact handoff summary — same outcome, fraction of tokens. Good for 15+ iteration runs.

### pi-continue

```
# Open action palette (interactive) or continue now (non-interactive)
/continue

# Compact now, aborting active work if needed, then resume
/continue steer [focus]

# Wait until pi is idle, compact, then resume
/continue queue [focus]

# Preview prompt payloads that would be used (read-only overlay)
/continue preview [focus]

# Show latest continuation status, config, thresholds
/continue status

# Show latest Continuation Ledger in transient TUI overlay
/continue ledger

# Edit package settings (project or global)
/continue settings [project|global]

# Delete package settings after confirmation
/continue reset [project|global]
```

**Key feature:** Handles mid-run context overflow — waits for completed assistant/tool-result batch, triggers compaction before the next oversized provider request, injects a structured Continuation Ledger (active task, recency, context map, working edge, validation, risks, anti-rework), then resumes the same task in-session.

**Optional sync:** Can write `CONTINUE.md` and/or replace `AGENTS.md` with modeled updates — both off by default. The `agentGuideSyncMode` allows the agent guide to evolve into a living operating record across long runs.

**Configuration:** `~/.pi/agent/extensions/pi-continue.json` (global) or `.pi/extensions/pi-continue.json` (project). Key settings: `midRunGuardEnabled` (default true), `summarizerModel` ("inherit" uses active model), `reasoning`, `continuationDocSyncMode`, `agentGuideSyncMode`.

**Version:** 0.6.0 (as of 2026-05-03, installed from local git clone due to npm 11 peer-dep resolution issue)

## Compaction Landscape

Pi has built-in auto-compaction (enabled by default, triggers at `contextWindow - reserveTokens`). Several extensions modify or replace this behavior:

### Evaluated Compaction Extensions

| Extension | Approach | Status |
|---|---|---|
| **pi-continue** | Mid-run guard + Continuation Ledger | ✅ Installed |
| **pi-boomerang** | Context collapse after autonomous task runs | ✅ Installed |
| **@sting8k/pi-vcc** | Algorithmic, no LLM calls | Researched |
| **pi-observational-memory** (elpapi42) | Tiered cognitive memory with reflections (v2.3.0) | Researched |
| **pi-extension-observational-memory** (Foxy) | Observational summaries + reflector GC, single-pass | Evaluated (below) |
| **pi-agentic-compaction** | Agentic loop over virtual filesystem | Evaluated |
| **pi-model-aware-compaction** | Per-model compaction thresholds | Researched |
| **pi-custom-compaction** | Swap model + template + trigger | Researched |
| **pi-context-cap** | Cap model windows to force earlier compaction | Researched |

### pi-agentic-compaction (Evaluated, Not Installed)

**Repo:** [laulauland/pi-agentic-compaction](https://github.com/laulauland/pi-agentic-compaction)

Replaces pi's default single-pass summarization with an agentic exploration loop:
- Mounts the conversation as `/conversation.json` in an in-memory virtual filesystem (just-bash)
- Gives the summarizer `bash`/`zsh` + `jq`, `grep`, `head`, `tail`, `wc`, `cat` to explore it
- Model queries only the parts it needs across multiple tool-call turns, then emits the summary
- Configurable multi-model fallback chain via `/compaction-model`; defaults to cheap models (`cerebras/zai-glm-4.7`, `openai/gpt-5.4-mini`)

**Gains vs default compaction:**
- **Cheaper** for long conversations — model reads only what it queries, not the entire transcript
- **Better file accuracy** — pairs tool calls with tool results, filters no-op edits
- **Tool result fidelity** — keeps up to 50k chars (default truncates at 2k)
- **Steerable** — `/compact focus on X` biases exploration strategy and output

**Losses vs default compaction:**
- **Multiple API calls** per compaction (exploration loop) instead of a single pass
- **Higher latency** — multiple round-trips + tool execution
- **Small-model blind spots** — cheap defaults (zai-glm-4.7, gpt-5.4-mini) may miss context a full-pass model would catch; bad exploration = bad summary
- **No cumulative file tracking** — detects files only from current messages, doesn't carry forward across compactions
- **No split-turn handling** — default has explicit logic for mid-turn cuts (`turnPrefixMessages`); this extension doesn't
- **Raw JSON serialization** — summarizer must parse JSON structure with jq, more complex than default's readable text format

**Verdict:** Interesting concept but riskier than default for general use. Worth revisiting when sessions routinely exceed 100k+ tokens where single-pass costs become painful. Pin a capable model (not the default cheap ones) if summary quality matters. Currently not installed.

### pi-extension-observational-memory (Evaluated, Not Installed)

**Repo:** [GitHubFoxy/pi-observational-memory](https://github.com/GitHubFoxy/pi-observational-memory) | **npm:** `pi-extension-observational-memory`

Replaces default compaction with an observational-memory format. Single-pass (like default) but with a different summary structure, post-processing reflector, and built-in auto-trigger.

**Overrides:** Yes — returns a custom `compaction` result from `session_before_compact`, fully replacing the default summary format. Also hooks `session_before_tree` for branch summaries. Falls back gracefully if no model/API key or if generation fails.

**Architecture:**
- Single-pass summarization via `serializeConversation` + `convertToLlm` (same as default)
- Uses the **active session model** (not a separate cheap model)
- After generation: runs a **reflector** (dedup + priority-cap pruning) when observation token estimate crosses threshold (default 40k) or when forced
- Cumulative file tracking — merges `<read-files>` and `<modified-files>` from previous compactions
- Two-threshold flow:
  - **Observer trigger** (default 30k tokens): raw-tail tokens since last compaction → fires auto-compaction on `agent_end` in buffered mode
  - **Reflector trigger** (default 40k tokens): observation-block tokens → fires reflector dedup/prune
  - **Raw-tail retain** (default 8k tokens): extra buffer before observer triggers, for partial activation

**Summary format:**
```markdown
## Observations
- 🔴 critical constraints, blockers, deadlines, irreversible decisions
- 🟡 important but possibly evolving context
- 🟢 low-priority informational context

## Open Threads
- unfinished work items

## Next Action Bias
1. most likely immediate next action
2. optional second action
```

**Commands:**
```
/obs-memory-status      # Show compaction + branch summary metadata, token estimates
/obs-auto-compact        # Show/set thresholds and mode (keyed or positional)
/obs-mode                # Show/set observer mode: buffered (default) or blocking
/obs-view [obs|raw] [N]  # Inspect latest observation summary
/obs-reflect [focus]     # Force aggressive reflection + trigger compaction now
```

**Gains vs default compaction:**
- **Better memory format** — priority-tagged observations (🔴/🟡/🟢) with open threads and action bias, more scannable than default's long-form narrative
- **Reflector GC** — deduplicates and prunes observations on overflow; both threshold-based (automatic) and forced (`/obs-reflect`)
- **Cumulative file tags** — merges read/modified files across compactions, same as default
- **Buffered auto-mode** — background observer trigger on `agent_end` at configurable thresholds, with cooldown
- **Status overlay** — `Ctrl+Shift+O` opens a live TUI overlay showing compaction state, token estimates, observation counts
- **Split-turn aware** — preserves `preparation.isSplitTurn` in metadata, `turnPrefixMessages` included in serialized input for single-pass

**Losses vs default compaction:**
- **Incompatible summary format** — completely different structure from default; summaries aren't interchangeable (but the summary is self-contained, so the LLM can still read it)
- **No dedicated summarizer model** — uses the active session model (same cost as conversation model); if that model is expensive (e.g., Opus), compaction costs what a conversation turn costs
- **Single-pass bottleneck** — same as default: model must ingest the full serialized conversation; no cost savings on long sessions (unlike pi-agentic-compaction's agentic exploration)
- **Reflector is lossy by design** — dedup and cap pruning can drop context the default would preserve; forced reflector is aggressive (max 72 🔴, 28 🟡, 8 🟢)

**Comparison with pi-agentic-compaction:**

| Aspect | pi-agentic-compaction | pi-extension-observational-memory |
|---|---|---|
| Exploration | Agentic (bash + jq tools) | Single-pass (like default) |
| Model | Separate cheap models (configurable) | Active session model |
| Cost profile | Cheaper for long sessions (reads only what it queries) | Same as default (reads everything) |
| Latency | Higher (multiple tool-call turns) | Same as default (one LLM call) |
| Summary format | Standard markdown (customizable structure) | Priority-tagged observations + threads + bias |
| Post-processing | None (raw model output) | Reflector dedup + priority-cap pruning |
| File tracking | Current messages only | Cumulative (merges previous compaction tags) |
| Auto-trigger | None (relies on pi's built-in) | Buffered observer on `agent_end` at configurable thresholds |
| Split-turn handling | None | Preserves metadata, includes in single-pass input |
| Risk of missing context | High (depends on model's exploration strategy) | Low (single-pass, but reflector pruning can drop items) |

**Verdict:** A thoughtful alternative to default compaction if you prefer priority-scored, deduplicated summaries with explicit action bias. The two-threshold flow (observer + reflector) is well-designed. Main hesitation: uses the expensive session model rather than a cheap dedicated summarizer, so cost is the same as a regular turn. The reflector pruning caps are aggressive — useful for keeping observation blocks compact, but you trade completeness. Not installed for now — pi-continue handles mid-run continuation and we're fine with default's summary format.

### Two Observational Memory Extensions Compared

Two packages share the "observational memory" name but are architecturally unrelated:

| Aspect | elpapi42/pi-observational-memory (v2.3.0) | GitHubFoxy/pi-extension-observational-memory |
|---|---|---|
| **npm** | `pi-observational-memory` | `pi-extension-observational-memory` |
| **Architecture** | Three-tier: Observer → Compaction → Reflector+Pruner | Single-pass + reflector GC |
| **Background observer** | ✅ Async, incremental (~1k token chunks), stores silent tree entries | ❌ No background observer — works only at compaction time |
| **Summary assembly** | **Mechanical concatenation** — no LLM rewrite, byte-identical across cycles. Eliminates summary-of-a-summary degradation. | LLM-generated summary each compaction (like default) |
| **Summary format** | `## Reflections` (durable prose) + `## Observations` (timestamped, relevance-tiered) | `## Observations` (🔴🟡🟢 emoji-priority) + `## Open Threads` + `## Next Action Bias` |
| **Memory layers** | Two: durable reflections (identity, constraints) vs temporal observations (events). Reflections crystallize once, persist forever. | One: prioritized observations only |
| **Compaction model** | Configurable via `compactionModel` — can point at a cheap/fast model separate from the session model | Always uses the active session model (expensive) |
| **Pruning strategy** | Pruner drops observations by id across up to 5 passes, with token-budget pressure. Reflector crystallizes new reflections from pool. | Single-pass dedup + hard cap-prune (e.g., max 96 🔴, 40 🟡, 16 🟢; 72/28/8 when forced) |
| **Auto-trigger** | Proactive: triggers compaction when agent is idle, configurable at ~50k raw tokens | Buffered observer on `agent_end` at configurable thresholds (observer 30k + reflector 40k + retain 8k) |
| **Crash recovery** | Observer stores observations as silent tree entries in session JSONL | State only in-memory; lost on restart |
| **Cache-friendly** | Memory updates batched at compaction boundaries — prompt prefix caching intact between compactions | Same: memory injected only at compaction, not mid-stream |
| **Temporal reasoning** | Every observation has per-minute timestamp (`YYYY-MM-DD HH:MM`) | Date header only ("Date: unknown" if not available) |
| **Commands** | `/om-status`, `/om-view` | `/obs-memory-status`, `/obs-auto-compact`, `/obs-mode`, `/obs-view`, `/obs-reflect` |
| **UI** | Notification-based | Rich TUI overlay (`Ctrl+Shift+O`), model picker |
| **Tests** | ✅ vitest test suite (7 test files) | ❌ No tests |
| **Lines of code** | ~2,500 across 20+ modules | ~1,500 in single file + overlay |
| **Split-turn handling** | Unknown | Metadata preserved, included in single-pass input |
| **File tracking** | Unknown | Cumulative (merges with previous compaction tags) |

**Key insight:** elpapi42's is a proper implementation of the [Mastra observational memory](https://mastra.ai/blog/observational-memory) pattern (94.87% on LongMemEval). The background observer + mechanical summary assembly means the summary never degrades through repeated compactions — it's the observation *pool* that evolves, not the summary text. Foxy's is a lighter adaptation with a different summary format and nicer UI polish.

**Verdict:** If choosing between the two, elpapi42's is the stronger technical foundation — dedicated compaction model support, mechanical summary assembly (no compounding drift), background observer, crash recovery, test suite. Foxy's has nicer UX (overlay, model picker) but uses the expensive session model and LLM-generated summaries that degrade across cycles. Neither installed currently.

## Installation

```bash
npm install -g @mariozechner/pi-coding-agent

# Authenticate
export ANTHROPIC_API_KEY=sk-ant-...
pi

# Or use subscription auth
# /login inside pi
```

Current version: 0.72.1 (as of 2026-05-03)

## Rendering & UI Extensions

### pi-code-previews (✅ Installed)

**Repo:** [mattleong/pi-code-previews](https://github.com/mattleong/pi-code-previews) | **npm:** `pi-code-previews` (v0.1.14)

Purely cosmetic — enhances how built-in tool calls render in the pi TUI. Does NOT modify tool execution or LLM behavior.

**Usage:**
```
/code-preview-settings    # Open TUI settings (theme, line counts, icons, tools)
/code-preview-health      # Show renderer state, active/skipped tools, Shiki status
```

**Features:**
- Uses **Shiki** for syntax-highlighted previews of file content, diffs, commands, and search results
- Clearer `edit` and `write` diffs with configurable word-level emphasis (`smart` | `all` | `off`)
- `grep` results grouped by file
- `find` and `ls` path lists compacted with optional icons (unicode / nerd / off)
- Optional visual warnings for risky shell commands and secret-looking output
- Auto-skips tools already owned by another extension (no conflicts)
- Configurable via `.pi/settings.json` (`codePreview.*`) or env vars (`CODE_PREVIEW_*`)
- Comprehensive test suite (15 test files)

**Version:** 0.1.14 (as of 2026-05-03, installed from local git clone)

## Core Architecture

**Four default tools:** `read`, `write`, `edit`, `bash` — intentionally minimal. Additional tools (`grep`, `find`, `ls`) available but not default.

**Four operating modes:**
- Interactive terminal UI (TUI) — primary usage
- Print/JSON mode — automation and scripting
- RPC mode — stdin/stdout JSONL for non-Node integrations
- SDK mode — embed in Node.js applications

**20+ LLM providers:** Anthropic, OpenAI, Google Gemini/Vertex, Azure, Amazon Bedrock, DeepSeek, Mistral, Groq, Cerebras, xAI, OpenRouter, and more. Switch mid-session via `/model`.

**Session format:** Tree-structured JSONL with `id` and `parentId` fields. Enables in-place branching without separate files. Navigate with `/tree`, fork with `/fork`, clone with `/clone`.

## Context File Loading

Pi loads `AGENTS.md` (or `CLAUDE.md`) from:
1. `~/.pi/agent/AGENTS.md` (global)
2. Parent directories walking upward from cwd
3. Current directory

All matching files concatenate. Disable with `--no-context-files` or `-nc`.

System prompt override: `.pi/SYSTEM.md` (project) or `~/.pi/agent/SYSTEM.md` (global). Append via `APPEND_SYSTEM.md`.

This means our existing `AGENTS.md` files work with pi out of the box.

## Customization Layers

### Configuration
- `~/.pi/agent/settings.json` — global settings
- `.pi/settings.json` — project-level overrides
- `~/.pi/agent/models.json` — custom provider definitions

### Extensions (TypeScript modules)
- Location: `~/.pi/agent/extensions/` or `.pi/extensions/`
- Full API access: tools, commands, keyboard shortcuts, event handlers, UI components
- Async factory pattern for initialization
- Can implement: sub-agents, plan mode, permission gates, git checkpointing, MCP integration, custom editors, sandboxing

```typescript
export default function (pi: ExtensionAPI) {
  pi.registerTool({ name: "deploy", ... });
  pi.registerCommand("stats", { ... });
  pi.on("tool_call", async (event, ctx) => { ... });
}
```

### Skills
- Location: `~/.pi/agent/skills/` or `.pi/skills/` or `.agents/skills/`
- Follows the Agent Skills standard
- Invoked via `/skill:name`

### Prompt Templates
- Location: `~/.pi/agent/prompts/` or `.pi/prompts/`
- Markdown files with variables
- Invoked via `/name`

### Themes
- Location: `~/.pi/agent/themes/` or `.pi/themes/`
- Hot-reload supported

### Packages
Bundle and distribute extensions, skills, prompts, themes:
```bash
pi install npm:@foo/pi-tools
pi install git:github.com/user/repo@v1
pi list
pi update
pi remove npm:@foo/pi-tools
```

## Comparison with Claude Code

| Aspect | Pi | Claude Code |
| --- | --- | --- |
| Philosophy | Minimal core, extend everything | Batteries included |
| Default tools | 4 (read/write/edit/bash) | Many (Agent, WebFetch, etc.) |
| MCP | Build via extension | Built-in |
| Plan mode | Build via extension | Built-in |
| Permission system | Build via extension | Built-in |
| Sub-agents | Build via extension (tmux) | Built-in Agent tool |
| Provider support | 20+ providers | Anthropic only |
| Extension language | TypeScript | Hooks (shell commands) |
| Session format | Tree-structured JSONL | Conversation history |
| AGENTS.md loading | Same pattern (dir walk + concat) | Same pattern |
| Context management | Manual compaction + auto on overflow | Automatic compression |
| Package ecosystem | npm/git pi packages | Plugins (newer) |

**Key tradeoff:** Pi requires more upfront work to match Claude Code's out-of-box experience, but offers deeper customization. Claude Code's hooks are shell-level; pi's extensions are full TypeScript with API access.

## What Pi Deliberately Omits

These are left to extensions by design:
- MCP server integration
- Sub-agent orchestration
- Permission popups / approval gates
- Plan mode
- To-do / task tracking
- Background bash execution

This is a philosophical choice, not a limitation — the repo has 50+ extension examples implementing these.

## Documentation

Full docs in the repo at `packages/coding-agent/docs/`:
- `extensions.md` — extension development guide
- `skills.md` — skill implementation
- `sdk.md` — programmatic embedding
- `rpc.md` — RPC protocol
- `settings.md` — configuration schema
- `keybindings.md` — keyboard customization
- `sessions.md` / `session-format.md` — session management
- `packages.md` — package management

## Extensions

### RTK Optimizer (Recommended)

[pi-rtk-optimizer](https://github.com/MasuRii/pi-rtk-optimizer) (`npm:pi-rtk-optimizer`) provides token optimization through two mechanisms:

**1. Command Rewriting** — Delegates to [[tools/rtk]] binary
- Automatically rewrites bash commands to their `rtk` equivalents
- Delegates rewrite logic to the `rtk` binary (source of truth)
- Falls back to original command if rtk is unavailable
- Supports both agent `bash` tool and user `!<cmd>` commands

**2. Output Compaction Pipeline**
Multi-stage filtering for tool output:
- ANSI stripping (removes color codes)
- Test aggregation (summarizes pass/fail counts)
- Build filtering (extracts errors/warnings only)
- Git compaction (condenses status, log, diff)
- Linter aggregation (groups by rule)
- Search grouping (groups grep results by file)
- Source code filtering (`none` | `minimal` | `aggressive`)
- Smart truncation (preserves file boundaries)
- Hard truncation (character limits)

**Installation:**
```bash
pi install npm:pi-rtk-optimizer
# Requires rtk binary on PATH for command rewriting:
# brew install rtk-ai/rtk/rtk  # or cargo install rtk-ai-rtk
```

**Usage:**
- `/rtk` — Open interactive TUI settings modal
- `/rtk stats` — Show compaction metrics for session
- `/rtk verify` — Check if rtk binary is available
- `/rtk reset` — Reset to defaults

**Configuration:** `~/.pi/agent/extensions/pi-rtk-optimizer/config.json`

Key settings:
- `mode`: `"rewrite"` (auto) or `"suggest"` (notify only)
- `outputCompaction.readCompaction.enabled`: defaults `false` (code reads stay exact)
- `outputCompaction.sourceCodeFiltering`: `"none"` | `"minimal"` | `"aggressive"`
- `outputCompaction.truncate.maxChars`: default 12000

**Version:** 0.7.0 (as of 2026-05-03)

### RTK Extension Comparison

| Package | Version | Command Rewriting | Output Compaction | TUI Settings | Dependencies | 
|---------|---------|-------------------|-------------------|--------------|---------------|
| **MasuRii/pi-rtk-optimizer** | 0.7.0 | ✅ Via `rtk` binary | ✅ Full pipeline | ✅ /rtk modal | rtk binary (opt) |
| sherif-fanous/pi-rtk | 0.3.0 | ✅ Via `rtk` binary | ❌ | ❌ | rtk binary (req) |
| mcowger/pi-rtk | 0.1.4 | ❌ | ✅ Limited | ❌ CLI only | None |

| Feature | pi-rtk-optimizer | sherif-fanous | mcowger |
|---------|:---:|:---:|:---:|
| ANSI stripping | ✅ | — | ✅ |
| Test aggregation | ✅ | — | ✅ |
| Build filtering | ✅ | — | ✅ |
| Git compaction | ✅ | — | ✅ |
| Linter aggregation | ✅ | — | ✅ |
| Search grouping | ✅ | — | ✅ |
| Source code filtering | ✅ (3 levels) | — | ✅ (2 levels) |
| Smart truncation | ✅ | — | ✅ |
| Hard truncation | ✅ | — | ✅ |
| Streaming sanitization | ✅ | ❌ | ❌ |
| Skill-read preservation | ✅ | ❌ | ❌ |
| Windows compatibility | ✅ | ❌ | ❌ |
| Metrics tracking | ✅ | ❌ | ✅ |

**Recommendation:** MasuRii/pi-rtk-optimizer — most active development, feature-complete, clean architecture that delegates rewrite rules to rtk binary rather than duplicating logic.

**Minimal alternative:** sherif-fanous if only command rewriting needed (~60 LOC, trivial footprint)

---

## Community Distributions

### awesome-pi-agent

[qualisero/awesome-pi-agent](https://github.com/qualisero/awesome-pi-agent) — Concise, curated list of extensions, skills, and integrations for pi. The go-to resource for discovering community tools.

### oh-pi

[ifiokjr/oh-pi](https://github.com/ifiokjr/oh-pi) — "One-click setup for pi-coding-agent — extensions, themes, prompts, skills, and ant-colony swarm." Like oh-my-zsh for pi.

### oh-my-pi

[can1357/oh-my-pi](https://github.com/can1357/oh-my-pi) — "AI Coding agent for the terminal — hash-anchored edits, optimized tool harness, LSP, Python, browser, subagents, and more."

Other variants exist (搜索 `oh-my-pi` on GitHub shows multiple forks with different feature sets).

---

## Autonomous Loop / Goal Extensions

Several extensions provide autonomous loop, autoresearch, or long-running goal capabilities. They overlap in intent but differ in scope and implementation.

| Extension | Author | Focus | Key Feature |
|-----------|--------|-------|-------------|
| [pi-autoresearch](https://github.com/davebcn87/pi-autoresearch) | davebcn87 | Autonomous experiment loop | Runs experiments in loops until goal met |
| [pi-autoloop](https://github.com/mikeyobrien/pi-autoloop) | mikeyobrien | Autonomous LLM loops | Runs autonomous LLM loops |
| [pi-goal](https://github.com/nqh-packages/pi-goal) | nqh-packages | Long-running goal mode | Goal-directed agent execution |
| [pi-goal-driven](https://github.com/vurihuang/pi-goal-driven) | vurihuang | Goal-driven master/subagent | Master/subagent orchestration |
| [ralph-wiggum](https://github.com/tmustier/pi-extensions/tree/main/ralph-wiggum) | tmustier | Iterative development loops | Long-running agent loops for iterative dev |
| [pi-autoresearch-studio](https://github.com/jhochenbaum/pi-autoresearch-studio) | jhochenbaum | Dashboard for pi-autoresearch | UI for managing autoresearch sessions |

### Detailed Comparison

#### pi-autoresearch

**Repo:** [davebcn87/pi-autoresearch](https://github.com/davebcn87/pi-autoresearch)

Autonomous experiment loop extension. The agent runs experiments iteratively until a goal condition is met. Useful for:
- Benchmark experiments
- Hyperparameter tuning
- Research loops where success/failure can be detected programmatically

#### pi-autoloop

**Repo:** [mikeyobrien/pi-autoloop](https://github.com/mikeyobrien/pi-autoloop)

Runs autonomous LLM loops. Simple, focused implementation for keeping the agent running continuously without manual prompts.

#### pi-goal

**Repo:** [nqh-packages/pi-goal](https://github.com/nqh-packages/pi-goal)

Long-running goal mode extension. The agent works toward a defined goal across multiple turns, maintaining context and iterating until completion.

#### pi-goal-driven

**Repo:** [vurihuang/pi-goal-driven](https://github.com/vurihuang/pi-goal-driven)

Goal-driven master/subagent pattern as a Pi-native extension. Coordinates multiple subagents toward a common goal, with a master agent delegating subtasks.

#### ralph-wiggum (pi-extensions)

**Repo:** [tmustier/pi-extensions/ralph-wiggum](https://github.com/tmustier/pi-extensions/tree/main/ralph-wiggum)

Part of the tmustier/pi-extensions package. Long-running agent loops for iterative development. Good for:
- Refactoring sessions
- Test-driven development iterations
- Progressive code improvements

### Overlap Analysis

| Use Case | Recommended Extension |
|----------|----------------------|
| Continuous monitoring loop (time-based) | pi-loop |
| Simple continuous loop (keep agent running) | pi-autoloop |
| Research experiments with success conditions | pi-autoresearch |
| Single goal, many iterations | pi-goal |
| Multi-step tasks with subagent coordination | pi-goal-driven |
| Iterative code development/refactoring | ralph-wiggum |
| Full dashboard + workflow for research | pi-autoresearch-studio + pi-autoresearch |

**Avoid installing multiple loop extensions simultaneously** — they may conflict in controlling the agent flow.

---

## Scheduling Extensions

Two options for cron/scheduled prompts:

### pi-schedule-prompt (Recommended)

**Repo:** [tintinweb/pi-schedule-prompt](https://github.com/tintinweb/pi-schedule-prompt)
**Stars:** 43

"Pi's Heartbeat" — natural language prompt scheduling.

**Features:**
- Natural language: "schedule X in 5 minutes", "every hour do Y"
- Multiple formats: Cron, intervals, ISO timestamps, relative time
- **Per-task model** — run prompts in separate agent session (doesn't affect current chat)
- Live widget below editor with active schedules
- Human-readable display instead of raw cron
- Safety: duplicate name prevention, infinite loop detection

### pi-loop

**Repo:** [ArtemisAI/pi-loop](https://github.com/ArtemisAI/pi-loop)
npm: `@pi-agents/loop`, 3 stars

Similar features but less developed. Has `/loop` command, cron tools, idle gating, anti-thundering-herd jitter.

**Verdict:** pi-schedule-prompt has more stars, per-task model (big plus), and live widget. Use that one.

---

## Open Questions

- How does pi's compaction compare to Claude Code's automatic compression in practice?
- What's the extension development experience like for non-trivial tools?
- How mature is the package ecosystem — are there production-quality MCP or sub-agent extensions?
- Performance comparison on same tasks with same model (Anthropic API)?
- How well does the tree-structured session format work for long research sessions?
