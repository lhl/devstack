---
title: Context Pruning and Compaction Landscape
tags: [tools, token-optimization, pi-extension, context-management, pi-context-prune]
sources:
  - https://github.com/championswimmer/pi-context-prune
  - https://github.com/complexthings/pi-dynamic-context-pruning
  - https://github.com/chopratejas/headroom
links:
  - https://github.com/championswimmer/pi-context-prune
  - https://github.com/championswimmer/pi-context-prune/blob/main/PRUNING.md
  - https://github.com/complexthings/pi-dynamic-context-pruning
  - tools/pi-agent.md
---

# Context Pruning and Compaction Landscape

A dated record of devstack's evaluation of conversation-level pruning and its current, simpler context-management stack.

## Current Decision

**Decision (2026-07-18):** Removed `pi-context-prune` from the canonical stack because frequent runtime errors outweighed its context-saving benefit. Canonical sync removes the extension, setup no longer creates its config, and no replacement pruning extension is installed.

Devstack currently relies on:

1. **`pi-boomerang`** at the subagent layer. Only the summarized result of an autonomous task returns to the parent context.
2. **`@sting8k/pi-vcc`** at the session-compaction layer. It replaces the default compaction summarizer with deterministic extraction and keeps prior history searchable through `vcc_recall`.

There is intentionally no automatic tool-output or tool-batch pruning layer.

## Conversation-Level Pruning Approaches

These tools operate on accumulated conversation history rather than altering a command while it runs.

| Tool | Architecture | Current assessment |
|---|---|---|
| **pi-context-prune** ([source](https://github.com/championswimmer/pi-context-prune)) | Summarizes completed tool-call batches and keeps originals retrievable on demand | Removed 2026-07-18; the recoverable design was attractive, but frequent runtime errors outweighed its benefit. |
| **pi-dynamic-context-pruning** ([source](https://github.com/complexthings/pi-dynamic-context-pruning)) | Duplicate removal, superseded-write removal, error purging, recency protection, and model-triggered compression | Not installed. Broader feature surface and unresolved compression-block growth concerns at review time. |
| **pi-context-pruning** | Proactive removal of older tool outputs after turns | Not installed. Smaller feature set, but still another automatic context mutation layer. |
| **headroom** ([source](https://github.com/chopratejas/headroom)) | Provider-side proxy with reversible compression and retrieval | Not installed. Adds another service in the request path and had substantial provider/authentication issue surface at review time. |
| **hermes-context-manager** | Conversation compression for Hermes Agent | Not applicable to Pi. |

## Why We Tried pi-context-prune

The extension had several properties that appeared suitable for devstack:

- Pruned originals remained retrievable instead of being permanently discarded.
- `agent-message` mode batched one context rewrite per user-to-final-response span rather than rewriting after every tool turn.
- It did not modify files or command output on disk.
- Session JSONL remained available for later inspection and `vcc_recall`.

The operational experience did not justify the extra moving part. Frequent errors interrupted work often enough that the potential context savings were not worthwhile.

## Replacement Policy

Do not add a replacement by default. Revisit conversation pruning only if all of the following are true:

- A measured context-size or cost problem exists in real devstack sessions.
- The candidate preserves or reliably retrieves original tool results.
- It does not corrupt command output or files.
- It remains stable alongside session compaction and background-task wakeups.
- The measured benefit exceeds its operational and debugging cost.

## Related

- [[tools/pi-agent]] — canonical Pi extension stack and compaction configuration.
