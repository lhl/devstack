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
  - https://github.com/nicobailon/pi-web-access
  - https://github.com/Thinkscape/agent-smart-fetch
  - https://github.com/MonsieurBarti/camoufox-pi
---

# Pi Coding Agent

Pi (pi.dev) is a minimal, extensible terminal coding harness by Mario Zechner (badlogic/Earendil Inc). It provides a lean foundation — 4 default tools, no built-in MCP, no plan mode, no permission system — with the philosophy that users build what they need via extensions.

## Installed Extensions

| Extension | npm | Purpose | Status |
|---|---|---|---|
| **pi-rtk-optimizer** | `npm:pi-rtk-optimizer` | Token optimization via RTK command rewriting + output compaction | ✅ Installed |
| **pi-schedule-prompt** | `npm:pi-schedule-prompt` | Natural language scheduling, cron, per-task model | ✅ Installed |
| **pi-boomerang** | `npm:pi-boomerang` | Token-efficient autonomous loops — summarize between iterations | ✅ Installed |
| **pi-continue** | `git:pi-continue` | Mid-run context compaction with Continuation Ledger | ❌ Disabled (v0.6.0, local) |
| **pi-code-previews** | `git:pi-code-previews` | Shiki syntax-highlighted tool output rendering in TUI | ✅ Installed (v0.1.14, local) |
| **pi-web-access** | `npm:pi-web-access` | Web search, content extraction, video/YT understanding, GitHub cloning, PDF | ✅ Installed (v0.10.7) |
| **pi-smart-fetch** | `npm:pi-smart-fetch` | Browser-like TLS fingerprints + Defuddle extraction for bot-defended pages | ✅ Installed (v0.2.35) |
| **camoufox-pi** | `npm:@the-forge-flow/camoufox-pi` | Stealth web access via Camoufox (C++-level anti-fingerprinting Firefox fork) | ✅ Installed (v0.2.1) |
| **pi-zentui** | `npm:pi-zentui` | Starship-inspired status line + Opencode-style TUI (footer with git/runtime, bordered editor, accent rail) | ✅ Installed (v0.1.2) |
| **pi-codex-status** | `https://github.com/lhl/pi-codex-status` | ChatGPT Codex quota/status CLI + `/status` extension (5h, weekly, credits, JSON/statusline export) | ✅ Installed (v0.1.0) |
| **pi-vertex** | `npm:@lhl/pi-vertex` | Google Vertex AI provider — Gemini, Claude, Llama, DeepSeek, Qwen, Mistral, and 20+ other MaaS models | ✅ Installed (v1.1.6, forked from ssweens) |

**Install commands:**
```bash
pi install npm:pi-schedule-prompt

# pi-continue and pi-code-previews installed from local git clones due to npm 11 peer-dep issue:
# git clone https://github.com/Tiziano-AI/pi-continue .pi/git/pi-continue
# git clone https://github.com/mattleong/pi-code-previews .pi/git/pi-code-previews
# pi install -l .pi/git/pi-continue
# pi install -l .pi/git/pi-code-previews
# pi install -l does NOT run npm install — must install deps manually:
# (cd .pi/git/pi-continue && npm install)
# (cd .pi/git/pi-code-previews && npm install)

# Web fetch & search
pi install npm:pi-web-access
pi install npm:pi-smart-fetch
pi install npm:@the-forge-flow/camoufox-pi

# Status bar
pi install npm:pi-zentui

# Codex quota/status
pi install https://github.com/lhl/pi-codex-status

# camoufox-pi also needs its ~500MB browser binary (one-time):
# npx camoufox fetch && chmod -R 755 ~/.cache/camoufox/
# Then /reload inside pi before first use.
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

### pi-codex-status

```
/status              # Boxed ChatGPT Codex quota summary
/status refresh      # Bypass the local cache
/status json         # Normalized JSON for scripts/extensions
/status raw          # Raw ChatGPT backend usage response
/status statusline   # Compact one-line output
/codex-status        # Alias if another extension claims /status
```

**CLI:** `pi-codex-status`, `pi-codex-status statusline`, `pi-codex-status json`. The package now exposes only the status CLI name to keep published usage unambiguous.

**Key feature:** Gives idle-time visibility into ChatGPT Codex usage limits without waiting for a 429. It reads existing OAuth credentials from `~/.pi/agent/auth.json` first, falls back to `~/.codex/auth.json`, calls ChatGPT's private Codex usage endpoint, and self-caches to `~/.cache/pi-codex-status/usage.json` for statusline use. The pi extension also parses `x-codex-*` response headers when available to refresh the cache opportunistically.

**Caveat:** The usage endpoint is private/reverse-engineered and may change. The official fallback is `https://chatgpt.com/codex/settings/usage`.

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

**Version:** 0.6.2 (as of 2026-05-04)

**Status: DISABLED** — Removed from install script and `settings.json`. See known issue below.

#### Known Issue: "Compaction cancelled" Error

As of v0.6.2, pi-continue's handoff synthesis can fail with:

```
automatic continuation: saving handoff (N/M tokens, threshold T).
Error: Compaction cancelled
automatic continuation: handoff failed: pi-continue could not create a usable handoff, so continuation stopped before resuming.
```

This is **not model-specific** — observed with both Kimi K2 and Claude Opus. The root cause is in `extensions/continue/index.ts` line ~310: the history summarizer LLM pass doesn't produce the structured JSON artifacts pi-continue expects (`parseHistoryArtifacts` returns null), triggering a `SynthesisStageError("history-artifact")` which causes `{ cancel: true }` to be returned to pi-core's `session_before_compact` hook.

When this happens, pi-core throws `"Compaction cancelled"` and the session cannot compact at all — it's stuck. Since pi-continue intercepts the `session_before_compact` event, pi's built-in compaction is also blocked.

**Workaround:** Disable globally via `~/.pi/agent/extensions/pi-continue.json`:
```json
{ "enabled": false }
```
Or remove `"npm:pi-continue"` from `~/.pi/agent/settings.json` packages array. Pi's built-in compaction then takes over and works fine.

## Compaction Landscape

Pi has built-in auto-compaction (enabled by default, triggers at `contextWindow - reserveTokens`). Several extensions modify or replace this behavior:

### Evaluated Compaction Extensions

| Extension | Approach | Status |
|---|---|---|
| **@sting8k/pi-vcc** | Algorithmic, no LLM calls | ✅ Installed (override) |
| **pi-boomerang** | Context collapse after autonomous task runs | ✅ Installed |
| **pi-continue** | Mid-run guard + Continuation Ledger | ❌ Removed (2026-05-05) |
| **pi-grounded-compaction** | Custom summary prompt + model presets + files-touched grounding | Evaluated (below) |
| **@pi-unipi/compactor** | Zero-LLM pipeline + FTS5 recall + XML resume snapshots | Evaluated (below) |
| **pi-observational-memory** (elpapi42) | Tiered cognitive memory with reflections (v2.3.0) | Researched |
| **pi-extension-observational-memory** (Foxy) | Observational summaries + reflector GC, single-pass | Evaluated (below) |
| **pi-agentic-compaction** | Agentic loop over virtual filesystem | Evaluated |
| **pi-model-aware-compaction** | Per-model compaction thresholds | Researched |
| **pi-custom-compaction** | Swap model + template + trigger | Researched |
| **pi-context-cap** | Cap model windows to force earlier compaction | Researched |

### Why we moved off default compaction (2026-05-05)

On long sessions (research + ingest work on large transcripts) pi's default auto-compaction began failing with:

```
Error: 400 status code (no body)
Context overflow recovery failed after one compact-and-retry attempt.
Try reducing context or switching to a larger-context model.
```

Root cause: pi serializes the full summarization span (everything from the last kept boundary up to `contextTokens − keepRecentTokens`) and hands it to the summarizer LLM in one call. When the span plus the summary prompt exceeds the summarizer's input window, the provider rejects the call with a 400. Pi's built-in recovery is a single compact-and-retry; when that also fails, the session cannot progress until the user manually reduces context or switches models.

We hit this even **after removing `pi-continue`** (which had been our mid-run continuation helper) — so the problem was in pi core's single-pass summarization, not a plugin interaction. `pi-continue` was removed from `settings.json` before this evaluation; its removal did not fix the 400.

Options considered in order of how directly each kills the failure mode:

| Option | Type | Fixes 400? | Why / why not |
|---|---|---|---|
| Raise `compaction.reserveTokens` / `keepRecentTokens` in settings | Tuning | Partial | Shrinks the span on each pass, but a single oversized turn can still exceed the summarizer window |
| `pi-grounded-compaction` | Single-pass, configurable model preset | Partial | Only if the preset model has a big enough context window; still one LLM call |
| `pi-agentic-compaction` | Multi-call agentic loop reading `/conversation.json` | ✅ | Summarizer never ingests the full span |
| `@sting8k/pi-vcc` | Zero-LLM algorithmic extraction | ✅ | No network call to fail |
| `@pi-unipi/compactor` | Zero-LLM pipeline + FTS5 + XML resume | ✅ | No network call to fail |

The two zero-LLM options (`pi-vcc`, `@pi-unipi/compactor`) describe the same 6-stage pipeline (normalize → filter → build sections → brief → format → merge) and the same "95%+ reduction on long sessions" claim, strongly suggesting UniPi's compactor is architecturally derived from pi-vcc. On pure extraction quality they should be comparable; they diverge on recall, continuity, and surface area.

**Decision: install `@sting8k/pi-vcc` with `overrideDefaultCompaction: true`.** Rationale:

- **Directly eliminates the failure mode** — no LLM call, no 400 possible.
- **Smaller surface area** — zero dependencies, 158 KB, single responsibility. Easier to audit and remove than UniPi's 18-package suite.
- **More iteration on summary quality** — v0.3.7 release notes: *"reduce junk in compacted summaries — tightened preference patterns, dedup vs goals, cleaner Outstanding Context."* Concrete tuning against real sessions.
- **More real-world usage** — 3,299 downloads/mo vs UniPi compactor's 774/mo (≈4× exposure to edge cases).
- **Transparent merge semantics** — per-section merge policy documented (sticky for goal/prefs, volatile for outstanding context, union for files/commits, rolling for transcript).
- **Recall that can't go stale** — `vcc_recall` reads the raw session JSONL directly with regex + ranked OR. No index to maintain or resync. Lineage-aware (`scope:"all"` opt-in for cross-branch search).
- **Low migration cost** — if after a week of real usage we find we miss state reinjection (XML resume snapshots) or BM25 recall, swapping to `@pi-unipi/compactor` is a single settings change.

**Trade-offs accepted:**

- No synthesis of implicit context ("we chose B over A because of latency" won't appear unless stated explicitly in a message). Mitigated by `vcc_recall` over raw JSONL.
- No cross-compaction state reinjection (UniPi's XML resume). If a compaction drops behavioral preferences, the agent must re-derive them from the recall tool.
- Regex-based preference extraction is pattern-matched on `always/never/prefer/…` — will miss nuanced preferences stated in other forms.

**Install & config:**

```bash
pi install npm:@sting8k/pi-vcc
```

`~/.pi/agent/pi-vcc-config.json`:

```json
{
  "overrideDefaultCompaction": true,
  "debug": false
}
```

With `overrideDefaultCompaction: true`, pi-vcc handles `/compact`, auto-threshold compaction, and the new `/pi-vcc` / `/pi-vcc-recall` slash commands. To search prior history after compaction, use `vcc_recall({ query: "…" })` or `/pi-vcc-recall …`.

### pi-grounded-compaction (Evaluated, Not Installed)

**Package:** [`pi-grounded-compaction`](https://pi.dev/packages/pi-grounded-compaction) by w-winter ([source: `w-winter/dot314`](https://github.com/w-winter/dot314))

Single-pass LLM summarization with two angles:

1. **Model presets** — route compaction to a different model than the session model. Presets like `fast` (e.g. Gemini Flash) and `deep` (e.g. Opus) let you compact cheaply on a session running an expensive main model. `--preset <name>` / `-p <name>` CLI override on `/compact`.
2. **Grounded files-touched tracking** — shared collector covers pi native tools, RepoPrompt (`read_file`, `apply_edits`, `file_actions`, `git mv/rm`), and bash patterns (`sed -i`, `mv`, `rm`, shell redirections). Normalizes path spellings so the same file appears once. Also augments branch summaries during `/tree`.

**Gains vs default:**
- Model selection per compaction; thinking level configurable independently
- File tracking catches bash and RepoPrompt ops that default compaction misses
- Same mechanism extended to `/tree` branch summaries
- No prefix-cache penalty (compaction serializes to text first, so there's no cached-prefix to preserve)

**Losses vs default:**
- Still a **single LLM call** — does not fix the 400 failure mode unless you pick a preset model with a big enough context window
- Conflicts with other `session_before_compact` extensions (explicit warning in README re: `pi-agentic-compaction`)
- Branch-summary control is narrower than compaction (pi's `session_before_tree` hook doesn't expose model/thinking level)

**Verdict:** The best option **if you want to keep prose summaries** but route compaction to a cheaper/larger-context model. File-tracking grounding is genuinely nice for repos that use bash `sed -i`/`mv`. Not a fit for us because we specifically want to eliminate the summarization LLM call entirely — `pi-grounded-compaction` still has one, just on a different model.

### @pi-unipi/compactor (Evaluated, Not Installed)

**Package:** [`@pi-unipi/compactor`](https://pi.dev/packages/@pi-unipi/compactor) by Neuron-Mr-White ([source: `Neuron-Mr-White/unipi`](https://github.com/Neuron-Mr-White/unipi), monorepo `packages/compactor`)

Zero-LLM context engine. Part of the **UniPi** suite (18 packages: workflow, ralph, memory, subagents, web-api, mcp, notify, footer, btw, ask-user, milestone, kanboard, info-screen, utility, updater, input-shortcuts, compactor, core).

**Architecture:** Same 6-stage pipeline as pi-vcc (normalize → filter → build sections → brief → format → merge), plus:
- **Session Engine** with SQLite + XML **resume snapshots** for cross-compaction state continuity
- **Display Engine** (mode-aware rendering)
- **Auto Injection** of behavioral state after compaction (Pipeline Feature toggle)
- **FTS5 index** for project content via `content_index` / `content_search`
- **Sandbox** tool for running code in 11 languages (`sandbox`, `sandbox_file`, `sandbox_batch`)
- 4 presets: `precise` / `balanced` (default) / `thorough` / `lean`, with per-project override
- TUI settings overlay (Presets / Strategies / Pipeline tabs)
- Footer + info-screen dashboard integration showing compaction count, tokens saved, compression ratio

**Recall:** `session_recall` with **BM25** search, optional proximity reranking, timeline sort. Requires `better-sqlite3` (optional dep) for the FTS5 index.

**Gains vs pi-vcc:**
- **Cross-compaction state continuity** — XML resume snapshots + Auto Injection reinject behavioral state after a compaction, not just the textual summary
- **BM25 recall** — more sophisticated retrieval for natural-language queries than pi-vcc's regex + ranked OR
- **More tuning knobs** — 4 presets, per-pipeline-feature toggles, TUI overlay, per-project overrides
- **Content indexing beyond the session** — FTS5 index of project files can reduce re-reading same files into context
- **Ecosystem integration** — footer stats, info-screen dashboard, coexist triggers with other UniPi packages

**Losses vs pi-vcc:**
- **Much bigger surface area** — 281 KB package, pulls `@pi-unipi/core`, optional `better-sqlite3`, part of 18-package suite
- **Newer and less battle-tested** — v0.2.3 published May 1 2026, 774 downloads/mo vs pi-vcc's 3,299/mo
- **Index-dependent recall** — BM25 index can theoretically go stale or corrupt; pi-vcc reads raw JSONL directly
- **No documented lineage awareness** — pi-vcc's `scope:"all"` explicitly handles pi's `/tree` branching; UniPi compactor docs don't mention it
- **Less transparent merge semantics** — per-section merge policy not spelled out the way pi-vcc's is
- **No visible quality-iteration history** — pi-vcc's release notes show specific fixes like "reduce junk in compacted summaries"; UniPi compactor has no equivalent public trail

**Verdict:** Genuinely more capable than pi-vcc on two axes — state continuity (XML resume) and natural-language recall (BM25). Worth the migration if we find ourselves wishing the agent retained behavioral state across compactions or if regex recall fails us. But it's also ~4× less-used, newer, and comes with a lot of adjacent surface area we wouldn't use. Revisit if pi-vcc proves lossy in practice.

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

**Verdict:** A thoughtful alternative to default compaction if you prefer priority-scored, deduplicated summaries with explicit action bias. The two-threshold flow (observer + reflector) is well-designed. Main hesitation: uses the expensive session model rather than a cheap dedicated summarizer, so cost is the same as a regular turn. The reflector pruning caps are aggressive — useful for keeping observation blocks compact, but you trade completeness. Not installed for now — we're fine with pi's built-in compaction (pi-continue was disabled due to synthesis failures, see above).

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

## Status Bars

We use **pi-zentui** for the status line and editor styling.

### pi-zentui (Installed)

**Repo:** [lmilojevicc/pi-zentui](https://github.com/lmilojevicc/pi-zentui) | **npm:** `npm:pi-zentui` | v0.1.2

Starship-inspired footer + Opencode-style TUI for pi.

**Footer (Starship-inspired):**
- `󰝰 dirname` — current directory with icon
- `on  branch` — git branch with icon
- `[!?↑]` — git status indicators (modified, untracked, ahead/behind, stashed)
- `via  v5.5.0` — runtime detection (Bun, Deno, Node, Python, Go, Rust, Lua, Java, Ruby, PHP)
- Right side: context usage, token counts, cost

**Editor (Opencode-inspired):**
- Bordered input box with accent-colored left rail
- Model name and provider displayed inside the editor frame
- Thinking level indicator when enabled
- Matching style for previous user messages

**Status Icons:** `!` modified, `?` untracked, `+` staged, `✘` deleted, `»` renamed, `$` stashed, `↑` ahead, `↓` behind, `⇕` diverged

**Install:** `pi install npm:pi-zentui` (config at `~/.pi/agent/zentui.json`)

### Local Customizations

The extension source was modified locally to fix crashes and tailor the UI. Changes are in the pi-zentui extension directory at `~/.pi/agent/extensions/pi-zentui/`.

**Extension source (code fixes + UI changes):**

| File | Change |
|---|---|
| `ui.ts` | Fixed `theme.fg()` hex crash → `colorize()`; rail `█` → `▌` (U+258C left half block); extracted `RAIL` constant so editor and user message rail are consistent; removed extra editor line spacing |
| `index.ts` | Fixed `setWidget` factory API crash; rewrote meta widget (right-aligned, provider dim, model/`(thinking)` muted teal via `syntaxType` theme token, org prefix stripped) |

**User config (color preferences):**

| Setting | Value | Color |
|---|---|---|
| `contextNormal` | `#facc15` | Lemon yellow |
| `tokens` | `#fa8072` | Salmon |
| `cwdText` | `#c9b8e8` | Pale lavender |

**Relevant but not edited:**

| File | Purpose |
|---|---|
| `config.ts` | Default config + `colorize()` helper. Read-only — no changes needed. |

**Config location:** `~/.pi/agent/zentui.json` (user config)

### Status Bar Alternatives Evaluated

See [[tools/pi-statusline]] for full comparison of pi-statusbar, pi-powerline-footer, and custom footer approaches.

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

## Web Fetch & Search Packages

Nine pi packages for web fetching and search were evaluated (2026-05-03). Three were selected for installation.

### Summary Comparison

| # | Package | Ver | License | Stars | Approach | Search | Fetch | Unique Strength |
|---|---|---|---|---|---|---|---|---|
| 1 | **pi-web-access** | 0.10.7 | MIT | ⭐418 | Multi-API + MCP | ✅ 4 providers | ✅ Multi-format | Video/YT, GitHub clone, PDF, zero-config |
| 2 | **@ogulcancelik/pi-web-browse** | 1.0.5 | MIT | 70¹ | Headless CDP browser | ✅ Google/DDG | ✅ Browser render | Bot bypass, persistent daemon |
| 3 | **@apmantza/greedysearch-pi** | 1.8.5 | MIT | 21 | Browser automation | ✅ AI engines² | ✅ Readability | No API keys needed |
| 4 | **pi-smart-fetch** | 0.2.35 | MIT | 18 | TLS impersonation | ❌ | ✅ Defuddle | Fingerprint bypass, site extractors |
| 5 | **@demigodmode/pi-web-agent** | 0.4.0 | AGPL-3 | 5 | Orchestrated pipeline | ✅ Internal | ✅ HTTP+browser | Research-optimized, evidence ranking |
| 6 | **@counterposition/pi-web-search** | 0.4.0 | GPL-3 | 4 | Multi-API routing | ✅ 3 providers | ✅ Jina | Smart provider routing |
| 7 | **pi-fetch** | 2.0.0 | GPL-2 | 2 | Curl + HTML→text | ❌ | ✅ Basic | Minimal, shell-based |
| 8 | **@the-forge-flow/camoufox-pi** | 0.2.1 | MIT | 0 | Camoufox (FF fork) | ✅ DDG | ✅ Stealth | C++-level anti-fingerprint |
| 9 | **@pi-lab/webfetch** | 0.1.1 | MIT | —³ | Node fetch + Readability | ❌ | ✅ Basic | LRU cache, script extraction |

¹ Part of ogulcancelik/pi-extensions monorepo (70 stars)  
² Perplexity, Bing Copilot, Google AI — queried via real browser  
³ No public repo, no community signals

### Capability Matrix

| Capability | pi-web-access | pi-web-browse | greedysearch | smart-fetch | pi-web-agent | counterposition | camoufox | pi-fetch | pi-lab |
|---|---|---|---|---|---|---|---|---|---|
| **Web search** | ✅ Exa/Perplexity/Gemini | ✅ Google/DDG | ✅ AI engines | ❌ | ✅ internal | ✅ Brave/Tavily/Exa | ✅ DDG | ❌ | ❌ |
| **Page fetch** | ✅ Multi-fallback | ✅ Browser-rendered | ✅ Readability | ✅ TLS+Defuddle | ✅ HTTP+browser | ✅ Jina Reader | ✅ Stealth FF | ✅ curl | ✅ node fetch |
| **No API keys** | ✅ (Exa MCP) | ✅ | ✅ | ✅ | ❌⁴ | ❌ | ✅ | ✅ | ✅ |
| **Anti-bot** | Fallback chain | CDP browser | Browser automation | TLS fingerprint | Headless escalation | ❌ | C++-level stealth | ❌ | ❌ |
| **YouTube** | ✅ Full | ❌ | ❌ | Partial (extract) | ❌ | ❌ | ❌ | ❌ | ❌ |
| **GitHub repos** | ✅ Clone | ❌ | ✅ API | Partial (extract) | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Video files** | ✅ Analysis+frames | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **PDF** | ✅ Text extract | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Batch fetch** | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Code search** | ✅ | ❌ | ✅ (coding_task) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **SSRF protection** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ |
| **Screenshots** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |

⁴ Search needs API keys; HTTP fetch might work but docs don't clarify

### Architecture & Quality

| Package | Source Files | Key Deps | Design Notes |
|---|---|---|---|
| **pi-web-access** | 25 TS | readability, linkedom, turndown, unpdf, p-limit | Clean flat structure, one file per provider. Most polished. |
| **pi-web-browse** | ~8 TS (in monorepo) | playwright, readability, cheerio, jsdom, turndown, undici | CDP daemon pattern, warm browser sessions. |
| **greedysearch-pi** | Extractor-based (.mjs) | jsdom, readability, turndown | Shell scripts + browser extractors, pragmatic. |
| **smart-fetch** | 31 TS (monorepo) | wreq-js, defuddle, linkedom, pi-tui, typebox | Bun monorepo, shared core, unit+integration tests. |
| **pi-web-agent** | 68 TS | readability, cheerio, jsdom, playwright-core | Most engineered: orchestration, evidence ranking, cache, presentation. |
| **counterposition** | ~12 TS | Provider-specific clients | Clean provider abstraction, smart routing logic. |
| **camoufox-pi** | 99 TS | camoufox-js, playwright-core, turndown | Heavily engineered but specialized. CLI, credentials, signal handling. |
| **pi-fetch** | 0 visible | @kreuzberg/html-to-markdown-node | Shells out to curl. "Generated with an LLM." Bare minimum. |
| **@pi-lab/webfetch** | 1 bundled .mjs | readability, fflate, linkedom, turndown, lru-cache | Single-file bundled extension. Minimal but clean. |

### Recommendations

**Primary (installed): `pi-web-access`** — 418 stars, 62 forks, most features, most polish. Zero-config Exa MCP means it works immediately. YouTube understanding, GitHub cloning, and PDF extraction are genuinely unique. Actively maintained (pushed 2026-05-02).

**TLS fingerprint bypass (installed): `pi-smart-fetch`** — Browser-like TLS/SSL + HTTP fingerprints via wreq-js for bot-defended pages. Defuddle extraction with specialized support for YouTube, Reddit, X/Twitter, GitHub, HN, and Substack. Batch fetch with bounded concurrency. Lighter alternative to a full headless browser.

**Extreme stealth (installed): `@the-forge-flow/camoufox-pi`** — Firefox fork with C++-level anti-fingerprinting patches (SpiderMonkey/Gecko). ~100% bypass rate vs ~33% for Playwright-Chromium in independent benchmarks. Heavy: ~500MB binary download on first use, 200-1300MB RSS. Only needed for Cloudflare/DataDome/PerimeterX/Turnstile-protected pages.

**For general anti-bot without the stealth weight:** `@ogulcancelik/pi-web-browse` — real Chrome CDP, 70-star ecosystem, persistent daemon for warm sessions. Battle-tested.

**For no-API-key AI search:** `@apmantza/greedysearch-pi` — queries Perplexity/Bing/Google AI through real browser, no keys needed. 21 stars.

**For research quality:** `@counterposition/pi-web-search` — smart provider routing (Brave for fast, Tavily/Exa for thorough). Requires API keys but uses them intelligently. `@demigodmode/pi-web-agent` — most sophisticated pipeline, but AGPL-3 and still early (10 open issues).

**Skip:** `pi-fetch` (too basic, LLM-generated), `@pi-lab/webfetch` (no repo, no community, no search — just a basic fetch tool).

### Installed Package Details

#### pi-web-access (v0.10.7)

**Tools:**
- `web_search` — multi-provider search with automatic fallback (Exa → Perplexity → Gemini API → Gemini Web)
- `code_search` — Exa MCP code-context search, no API key required
- `fetch_content` — fetch URLs with format auto-detection (HTML, PDF, YouTube, GitHub, local video)
- `get_search_content` — retrieve stored content from previous searches/fetches

**Key features:**
- Zero-config Exa MCP search (no API key needed)
- GitHub repos cloned locally instead of scraped
- YouTube video understanding via Gemini (transcripts, visual descriptions, chapter markers)
- Local video file analysis (MP4, MOV, WebM, AVI up to 50MB)
- Frame extraction from YouTube/local videos at exact timestamps
- PDF extraction to markdown
- Blocked page retry through Jina Reader and Gemini extraction
- Optional API keys for Exa, Perplexity, Gemini in `~/.pi/web-search.json`
- Requires Pi v0.37.3+

#### pi-smart-fetch (v0.2.35)

**Tools:**
- `web_fetch` — fetch URL with browser-like TLS/SSL fingerprints
- `batch_web_fetch` — fetch many URLs with bounded concurrency

**Key features:**
- Browser-like TLS/SSL + HTTP fingerprints via wreq-js
- Defuddle extraction: specialized extractors for YouTube, Reddit, X/Twitter, GitHub, HN, Substack
- Multiple output formats: markdown, html, text, json
- Configurable fingerprint profiles (browser, OS)
- Downloads and large file support — streams to temp files
- Client-side `<meta>` redirect following
- Global defaults configurable in `.pi/settings.json`

#### @the-forge-flow/camoufox-pi (v0.2.1)

**Tools:**
- `tff-fetch_url` — fetch URL via stealth Firefox, return HTML/markdown with optional selector/screenshot
- `tff-search_web` — DuckDuckGo search via stealth Firefox

**Key features:**
- Camoufox: Firefox fork patched at C++ level for anti-fingerprint resistance
- For sites that block conventional headless browsers (Cloudflare, DataDome, PerimeterX)
- SSRF protection: private IP ranges, link-local, loopback, cloud metadata blocked per-hop
- Scheme allow-list: only http/https accepted
- Response size caps: max_bytes (default 2MiB, max 50MiB)
- Isolate mode: one-shot browser context per call
- Lazy binary download: ~500MB Camoufox binary fetched on first use
- Screenshot support: full-page or viewport, PNG/JPEG
- CSS selector extraction

**Install note:** The `pi install` above registers the extension, but the Camoufox browser binary (~500MB) must be downloaded separately before first use:
```bash
npx camoufox fetch
chmod -R 755 ~/.cache/camoufox/  # fix execute permissions if prompted
```
Then run `/reload` inside pi — the extension caches launch state at load time, so a reload after binary install is required. Without this, `tff-fetch_url` and `tff-search_web` will fail with `browser_launch_failed`.

---

## Open Questions

- How does pi's compaction compare to Claude Code's automatic compression in practice?
- What's the extension development experience like for non-trivial tools?
- How mature is the package ecosystem — are there production-quality MCP or sub-agent extensions?
- Performance comparison on same tasks with same model (Anthropic API)?
- How well does the tree-structured session format work for long research sessions?
