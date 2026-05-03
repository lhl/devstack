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
---

# Pi Coding Agent

Pi (pi.dev) is a minimal, extensible terminal coding harness by Mario Zechner (badlogic/Earendil Inc). It provides a lean foundation — 4 default tools, no built-in MCP, no plan mode, no permission system — with the philosophy that users build what they need via extensions.

## Installed Extensions

| Extension | npm | Purpose | Status |
|---|---|---|---|
| **pi-rtk-optimizer** | `npm:pi-rtk-optimizer` | Token optimization via RTK command rewriting + output compaction | ✅ Installed |
| **pi-schedule-prompt** | `npm:pi-schedule-prompt` | Natural language scheduling, cron, per-task model | ✅ Installed |

**Install commands:**
```bash
pi install npm:pi-schedule-prompt
```

## Installation

```bash
npm install -g @mariozechner/pi-coding-agent

# Authenticate
export ANTHROPIC_API_KEY=sk-ant-...
pi

# Or use subscription auth
# /login inside pi
```

Current version: 0.71.1 (as of 2026-05-03)

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
