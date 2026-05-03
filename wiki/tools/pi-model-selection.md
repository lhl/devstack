---
title: Pi Model Selection & Customization
tags: [tools, pi, configuration, models]
links:
  - https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent
  - https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/settings.md
  - https://github.com/nicobailon/pi-model-switch
---

# Pi Model Selection & Customization

Nearly all model scoping, favorites, and stickiness behavior is built in — no extension required for the core workflow.

## Favorites / Restricted Picker

Set **`enabledModels`** in `settings.json` (`~/.pi/agent/` global or `.pi/` per-project). It's a string array of model patterns — same syntax as the `--models` CLI flag:

- **Glob matching:** `"sonnet:*"`, `"haiku:*"`
- **Force-include/exclude:** `+force-include`, `-force-exclude`, `!exclude`

**Effect:**
- `Ctrl+P` cycles through only the `enabledModels` list
- `Ctrl+L` / `/model` still opens the **full picker** over all configured providers — an escape hatch, not a hard restriction

## Scoping by Scope

### Per-Project (Sticky)

`.pi/settings.json` in a project root overrides `~/.pi/agent/settings.json`. Drop a different `enabledModels` (and any model-related knob like `defaultThinkingLevel`, `thinkingBudgets`) in there. Walking into the dir and running `pi` picks it up automatically.

### Per-Session (Sticky)

Sessions are JSONL trees. The selected model is part of session state — resume, fork, or branch via `/tree` restores the model that was active at that node. Combined with `--fork` from the CLI, you get sticky-by-session for free.

### One-Shot CLI

```bash
pi --models "sonnet:high,haiku:low"
```

Useful for shell aliases per-project when you don't want to commit a `.pi/settings.json`.

## Extensions for Advanced Use

### pi-model-switch — Agent-Initiated Model Swapping

[nicobailon/pi-model-switch](https://github.com/nicobailon/pi-model-switch) exposes a `switch_model` tool to the agent itself, so it can swap mid-turn — e.g., escalate from Haiku to Opus on a hard step or downgrade for a trivial edit.

Foreground orchestration has been moved to `pi-orchestrate` per the README.

### pi-agent-extensions — Runtime Model Discovery

[jayshah5696/pi-agent-extensions](https://github.com/jayshah5696/pi-agent-extensions) ships an Nvidia NIM auth extension that runtime-mutates `enabledModels` to add discovered models. Useful as a template for auto-populating favorites from an inference fleet.

### Async Extension Factory — Dynamic Provider Registration

Use the async factory pattern (see [`docs/extensions.md`](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/extensions.md)) to hit a `/v1/models` endpoint at startup and call `pi.registerProvider(...)`. This keeps the picker auto-synced with whatever inference endpoints you're serving — no hand-editing `models.json`.

For setups serving custom models (vLLM, SGLang, etc.), this is the cleanest route to keep the picker dynamically current.

## Recommended Setup

For a workflow with a few frontier models plus custom endpoints (e.g., Shisa variants):

1. **Global `enabledModels`** — frontier picks for daily work
2. **Per-project `.pi/settings.json`** overrides — pin a specific model for repos where it matters
3. **Async-factory extension** — dynamically register custom inference endpoints (vLLM/SGLang) so they appear in the picker without manual config