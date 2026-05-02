---
title: Pi Coding Agent
tags: [tools, coding-agent, terminal, extensible]
sources:
  - sources/gists/karpathy-llm-wiki.md
links:
  - https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent
  - https://pi.dev
---

# Pi Coding Agent

Pi (pi.dev) is a minimal, extensible terminal coding harness by Mario Zechner (badlogic/Earendil Inc). It provides a lean foundation — 4 default tools, no built-in MCP, no plan mode, no permission system — with the philosophy that users build what they need via extensions.

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

## Open Questions

- How does pi's compaction compare to Claude Code's automatic compression in practice?
- What's the extension development experience like for non-trivial tools?
- How mature is the package ecosystem — are there production-quality MCP or sub-agent extensions?
- Performance comparison on same tasks with same model (Anthropic API)?
- How well does the tree-structured session format work for long research sessions?
