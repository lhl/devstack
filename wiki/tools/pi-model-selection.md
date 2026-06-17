---
title: Pi Model Selection & Customization
tags: [tools, pi, configuration, models]
sources:
  - pi-ai models.generated.js (static model catalog)
links:
  - https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent
  - https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/settings.md
  - https://github.com/nicobailon/pi-model-switch
---

# Pi Model Selection & Customization

Nearly all model scoping, favorites, and stickiness behavior is built in — no extension required for the core workflow.

## How the Model Catalog Is Loaded

Pi's model list is **not fetched dynamically** — it's a static catalog compiled into the `@earendil-works/pi-ai` package:

```
node_modules/@earendil-works/pi-ai/dist/models.generated.js
```

This file exports a top-level object keyed by **provider** (`huggingface`, `openrouter`, `anthropic`, `google`, `openai`, etc.). Each provider section lists its models with id, name, capabilities (`reasoning`, `input` types), cost (per-million-token pricing), context window, and max output tokens.

### Merge with `models.json`

User-defined models in `~/.pi/agent/models.json` merge into the built-in catalog at runtime. Structure:

```json
{
  "providers": {
    "huggingface": {
      "models": [
        {
          "id": "zai-org/GLM-5.2",
          "name": "GLM-5.2",
          "reasoning": true,
          "input": ["text"],
          "cost": { "input": 1.4, "output": 4.4, "cacheRead": 0.26, "cacheWrite": 0 },
          "contextWindow": 1048576,
          "maxTokens": 131072
        }
      ]
    }
  }
}
```

A model with the same `id` as a built-in entry overrides it; a new `id` adds to the provider's list. This is the mechanism for:

- **Adding models not yet in the upstream catalog** (e.g., a new release on HuggingFace that hasn't been added to `pi-ai` yet)
- **Overriding specs** (e.g., correcting a context window or cost figure)
- **Registering custom/self-hosted models** under an existing or new provider

### Catalog Lag Pattern

New model releases on HuggingFace typically appear on the platform before they're added to `pi-ai`'s static catalog. The lag can range from days to weeks depending on release velocity. When a model you want is missing:

1. Check `models.generated.js` — search for the model id under each provider
2. If missing, add it to `models.json` under the appropriate provider
3. When the upstream catalog catches up, your `models.json` entry will merge cleanly (same id = override)

**Example:** `zai-org/GLM-5.2` shipped on HuggingFace in June 2026. The `huggingface` provider section in `models.generated.js` had GLM-4.7, GLM-4.7-Flash, GLM-5, and GLM-5.1 but not 5.2. Only the `openrouter` provider listed it (as `z-ai/glm-5.2`). Adding it to `models.json` under `huggingface` made it immediately available via `Ctrl+P`.

### Dynamic Discovery Alternatives

For setups where the model list changes frequently (custom inference fleets, vLLM endpoints), use an async extension factory to call `pi.registerProvider(...)` at startup — see [Extensions for Advanced Use](#extensions-for-advanced-use) below.

## Favorites / Restricted Picker

> **Prerequisite:** The model must be in the catalog (built-in or via `models.json`) before it can appear in favorites or the picker.

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