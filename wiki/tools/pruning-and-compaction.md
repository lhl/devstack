---
title: Token Reduction — Pruning and Compaction Landscape
tags: [tools, token-optimization, pi-extension, context-management, rtk, pi-context-prune]
sources:
  - https://github.com/rtk-ai/rtk
  - https://github.com/MasuRii/pi-rtk-optimizer
  - https://github.com/championswimmer/pi-context-prune
  - https://github.com/complexthings/pi-dynamic-context-pruning
  - https://github.com/yvgude/lean-ctx
  - https://github.com/edouard-claude/snip
  - https://github.com/JuliusBrussee/caveman
  - https://github.com/chopratejas/headroom
  - https://www.implicator.ai/caveman-claude-code-skill-cuts-output-20-your-bill-barely-notices-2/
  - https://vexp.dev/blog/claude-code-token-optimization-manual-vs-automated
links:
  - https://github.com/championswimmer/pi-context-prune
  - https://github.com/championswimmer/pi-context-prune/blob/main/PRUNING.md
  - https://github.com/rtk-ai/rtk/issues
  - https://github.com/MasuRii/pi-rtk-optimizer
  - tools/pi-agent.md
  - tools/rtk.md
---

# Token Reduction — Pruning and Compaction Landscape

A working analysis of the agentic-coding token-reduction landscape and the specific reasoning behind our current setup. Captures the architectural framework, the rtk audit (and why we removed `pi-rtk-optimizer` on 2026-05-10), the alternatives surveyed, and the operational details of the chosen replacement (`pi-context-prune`).

This page is opinionated and dated. Verdicts here reflect our environment (pi as harness, mixed Anthropic/OpenAI usage, autoloop-heavy workflows). Re-evaluate when major version bumps land.

## TL;DR

**Decision (2026-05-10):** Removed `pi-rtk-optimizer`. Installed `pi-context-prune`. Kept the `rtk` binary on PATH for explicit `rtk proxy` / `rtk gain` use only.

**Why:** `rtk`-class tools are *per-command output summarizers* — they hook the bash tool and replace e.g. `git log` output with a compact summary. Their failure mode is structural: any time you semantically summarize, you can destroy the bytes that mattered (a Playwright locator, a JSON identifier, the precise grep match positions piped to `wc -l`). The independent bug tracker for `rtk` documents real, repeatable instances of this. `pi-rtk-optimizer` is a thin wrapper around `rtk rewrite` and propagates those bugs; on top, it adds its own secondary summarizer (`aggregateTestOutput`, 12K-char hard truncate) that has the same failure shape.

`pi-context-prune` solves a different problem — *context-level redundancy*. As a session ages, the same file gets read multiple times, the same `ls` runs repeatedly, error tool-results accumulate after the underlying issue is fixed. The extension summarizes completed tool-call batches into a compact note and prunes the originals from future LLM-call context, while keeping the originals retrievable on demand via a `context_tree_query` tool. The transform is *recoverable*, not lossy. It also lives at the right layer for prompt-prefix caching: with `pruneOn: "agent-message"` the cache is busted once per work batch, not once per tool turn.

The two architectures are orthogonal. You can in principle run both. We chose to run only the recoverable one.

## Architectural Framework

Token-reduction tools for agentic coding fall into two distinct architectural categories with different failure profiles. Confusing them is the source of most of the confusion in the marketing.

### Category A — Per-command output summarizers

Hook the agent's bash (or Read / Grep / etc.) tool. Replace the raw output of one command with a compressed summary before it reaches the model.

| Tool | Lang | Distinguisher | Notes |
|---|---|---|---|
| **rtk** | Rust | Compiled per-command filters, large registry, ~75–90% claimed savings | What we ran via `pi-rtk-optimizer`. Failure modes audited below. |
| **lean-ctx** | Rust | MCP server + shell hook; 49+ tools; explicit `raw=true` escape hatch | Same architectural class as rtk. Their own [v2.14.0 release notes](https://github.com/yvgude/lean-ctx/releases/tag/v2.14.0) admit shell-hook compression was broken when stdout was piped (which is *always* the case for agent hooks). [v2.12.9](https://github.com/yvgude/lean-ctx/releases/tag/v2.12.9) was titled "fix inflated savings" — their own measurements were wrong. Better engineered surface area than rtk, same architectural ceiling. |
| **snip** | Go | Declarative YAML filter pipelines instead of compiled filters | The selling point is filter inspectability/extensibility (you edit YAML, no recompile). Smaller user base (~170⭐ vs rtk's 30k+), less battle-tested. |
| **caveman** | Python skill | Compresses *model output* (not tool output) | Independent benchmark by [implicator.ai](https://www.implicator.ai/caveman-claude-code-skill-cuts-output-20-your-bill-barely-notices-2/) measured 12–23% reduction vs claimed 65–75%. Its own [issue #234](https://github.com/JuliusBrussee/caveman/issues/234) confirms the headline number is overstated; [issue #112](https://github.com/JuliusBrussee/caveman/issues/112) reports it silently overwriting inline code despite reporting "Validation passed". Output tokens are 0.6–2.5% of a typical bill, capping real savings at 1–3% even if the headline numbers were honest. |

**Failure mode all of Cat A shares:** semantic summarization is lossy by design. The fact that rtk converts `grep -n "pattern" file` output into "12 matches in 3 files" is the *feature*, but it's also the bug when you piped that output into `wc -l` and got the wrong number, or when the agent needed the line numbers it just summarized away. Switching from rtk to lean-ctx or snip is a sideways move within the same category.

### Category B — Context-level dedup and pruning

Don't touch any individual command's output. Instead, look at the *running conversation history* and remove redundancy: same file read 8 times → keep latest, error fixed three turns ago → drop the error tool-result, completed tool-call batch from 20 turns ago → replace with a compact summary while keeping the original retrievable.

| Tool | Type | Architecture | Notes |
|---|---|---|---|
| **pi-context-prune** ([championswimmer](https://github.com/championswimmer/pi-context-prune)) | pi extension, 83⭐ | Summarizes completed tool-call batches; exposes `context_tree_query` to recover any original output on demand | Architecturally the cleanest match for "clip repetition without regressions". Originals preserved and queryable. **What we run.** |
| **pi-dynamic-context-pruning** ([complexthings](https://github.com/complexthings/pi-dynamic-context-pruning)) | pi extension | Dedup duplicate tool outputs, superseded-write removal, error purging, recency protection, plus an LLM-callable `compress` tool | More features, larger blast radius. [Open issue #5](https://github.com/complexthings/pi-dynamic-context-pruning/issues/5) notes compression blocks accumulate without bound and don't integrate with pi's built-in compaction. Multiple maintained forks (PSU3D0/pi-dcp, zenobi-us/pi-dcp, edmundmiller, wassname). |
| **pi-context-pruning** ([JSPM listing](https://jspm-packages.deno.dev/package/pi-context-pruning@1.0.2)) | pi extension | Port of OpenCode's proactive pruning algorithm | Less sophisticated; just prunes old tool outputs after each turn. |
| **headroom** ([chopratejas](https://github.com/chopratejas/headroom)) | Standalone proxy / SDK, 1.7k⭐ | Sits between agent and provider. Reversible compression with retrieval. | Provider-agnostic (Claude/Codex/Cursor/Cline). 102 open issues at audit time. Codex auth breakage ([#71](https://github.com/chopratejas/headroom/issues/71)), Anthropic compression result discarded (#296), various dashboard/encoding bugs. The proxy architecture means it works with anything but adds another moving piece in the data path. |
| **hermes-context-manager** | Hermes Agent plugin | "Silent-first" — compression hidden from main model | Same dedup + summarize + truncate stack, ported from `pi-dynamic-context-pruning`. |

**Why Cat B is fundamentally safer:** the transforms can be made *lossless* (exact-duplicate detection and removal) or *recoverable* (full output kept on disk + a re-read tool). Cat A's summary-of-output is permanent and lossy.

### Lossless vs Lossy transforms

Mixing these together is what causes the confusion. The "regressions like rtk does" all come from rows 6–8.

| Transform | Loss profile | Examples |
|---|---|---|
| 1. Exact duplicate dedup (read same file twice → keep latest) | Lossless | `pi-dynamic-context-pruning`, `headroom`, `hermes-context-manager` |
| 2. Superseded write removal (you wrote `foo.ts` 3 times → keep last) | Lossless w.r.t. current state, lossy w.r.t. history | `pi-dynamic-context-pruning` |
| 3. Run-length encoding ("this line ×100") | Lossless | Theoretically trivial; not seen as a primary feature in any of the surveyed tools |
| 4. ANSI-strip on text destined for a model | Effectively lossless | `pi-rtk-optimizer`, `lean-ctx`, almost all of them |
| 5. Tail-truncate with re-read tool | Lossy in context, recoverable on disk | `pi-context-prune`'s `context_tree_query`, `lean-ctx` raw mode |
| 6. Truncate without recovery | Lossy and permanent | `pi-rtk-optimizer`'s 12K-char hard truncate, raw `rtk` |
| 7. Semantic summarization (50 grep matches → "50 matches in 12 files") | Lossy and permanent | `rtk`'s per-command filters, `pi-rtk-optimizer`'s `aggregateTestOutput` |
| 8. Schema conversion (curl JSON → field types) | Lossy and *destroys identifiers* | `rtk curl` ([rtk #1152](https://github.com/rtk-ai/rtk/issues/1152)) |

Categories 1–5 are what "clip repetitions/logspam without regressions" actually looks like. `pi-context-prune` operates at row 5 (with row 1 as a side effect via batch summarization). `rtk`-class tools operate at rows 4, 6, 7, and 8.

## RTK Audit (the failure modes that drove us off it)

> **Source provenance:** the per-issue catalog below was first written up in an earlier independent analysis we received and which we cross-checked against the live `rtk-ai/rtk` issue tracker, the `pi-rtk-optimizer` source on npm, and our own `rtk gain` data. Where we directly verified something, it's noted; where we're relying on the third-party catalog, the issue numbers below are the upstream references and intended as starting points for re-verification.

`rtk` 0.38.0 — installed via `curl … install.sh`, ran for ~weeks via `pi-rtk-optimizer`. Personal `rtk gain` showed 75.8% savings across 776 commands, consistent with user reports in the 75–90% range across HN/Reddit/blog posts. Savings are not in dispute. Task fidelity is.

### Issues (cross-referenced from upstream `rtk-ai/rtk`)

| # | Failure mode | Architecture / scope |
|---|---|---|
| **#690** | Playwright filter strips locator details, DOM snapshots, expected/received diffs, and call-log on test failures. Filer measured 3–5× more iterations debugging through rtk than raw because the agent literally couldn't see why the test failed → net token cost up. | rtk binary, per-command filter; affects both raw `rtk init -g` and `pi-rtk-optimizer` (delegates to `rtk rewrite`). |
| **#1282** | Silent corruption when stdout is piped/redirected. `grep -n '^- \[ \]' TODO.md > /tmp/pending.txt` followed by `wc -l` returned wrong numbers because rtk's compact "(N matches in MF)" format went into the file. Architectural complaint: rtk inverted the standard `IsTerminal`-aware default (`ls --color=auto`, `git diff` etc.). | rtk binary. `pi-rtk-optimizer`'s `rewrite-pipeline-safety.ts` only fixes this on Windows (`platform === "win32"` early-return). On Linux/macOS the bug propagates. |
| **#720** | `rtk gh issue view --comments` and `rtk gh pr view --comments` silently drop all comments. Agent concludes "no comments exist" when comments do exist. Worse than truncation because the data is never fetched. | rtk binary. `pi-rtk-optimizer` 0.6.0 explicitly removed its local `gh` bypass tables in favor of pure delegation to `rtk rewrite`, so the bug propagates. |
| **#1152** | `rtk curl` runs JSON output through schema-conversion mode, replacing values with their types. Reproduced in our own setup: `rtk curl -sf http://localhost:9222/json/version` (CDP) returned types instead of the actual WebSocket URL. Our `rtk gain` shows 99.6% savings on a single curl call — that's the schema-conversion mode kicking in. | rtk binary. |
| **#1418** | `rtk ls` returned the literal string `(empty)` regardless of input. 0.37.1-specific; resolved in 0.38.0. Illustrative of how aggressive command-specific filters can regress in point releases. | rtk binary. |
| **#1080** | `rtk npx` breaks for any npx package not in rtk's known-tools registry. | rtk binary. |
| **#1335** | `exclude_commands` in `~/.config/rtk/config.toml` had no effect on either `rtk rewrite` or the Claude Code hook in 0.36.0; only `rtk proxy <cmd>` reliably bypassed. Status on 0.38 unverified — needs a fresh test (`rtk rewrite curl … <expected-bypass>` should return original, exit 1). | rtk binary. Critical because this is the documented mitigation for #690 / #1152 / #720. If exclude_commands doesn't work, the documented escape hatch is fictional. |
| **#640** | Security review (Claude-Opus-authored per the filer) flagged shell injection in `rtk err` / `rtk test` / `rtk summary` — accept free-form args joined with spaces and passed unescaped to `sh -c`. Worse, the Claude Code rewrite hook auto-grants `permissionDecision: "allow"`, bypassing the normal permission prompt. A model that gets coerced into running `cargo test; <payload>` could be rewritten through the auto-allow hook into a shell injection without user prompt. Status of fix at audit time: open. | rtk binary + Claude Code hook. **Sidestepped by `pi-rtk-optimizer`** because pi's permission flow stays in the loop on the rewritten command (auto-allow is Claude-Code-specific). Still relevant if anyone in the stack runs `rtk init -g` for Claude Code. |

### Third-party engagement

- [Madplay's blog post](https://madplay.github.io/en/post/rtk-reduce-ai-coding-agent-token-usage) — most useful third-party prose review. Deployed it, found savings real, hit two of the same gotchas (Bash-only hook scope, over-aggressive Playwright compression). Workaround: `rtk proxy` and exception lists.
- Tyler Folkman's "I Cut My AI Agent Costs 7x" (paywalled Substack) uses rtk + context-mode as Layer 1 + 2. No isolated A/B.
- No rigorous task-success eval published anywhere as of 2026-05-10.

### What `pi-rtk-optimizer` did and didn't sidestep

`pi-rtk-optimizer` 0.7.1 since v0.6.0 delegates *all* rewrite decisions to the installed `rtk rewrite` binary (Breaking change in v0.6.0 changelog: removed local rewrite-rule tables). So it has identical command-rewrite behavior to whatever `rtk init -g` would do.

| Concern | `pi-rtk-optimizer` status |
|---|---|
| #640 auto-allow shell injection | **Sidestepped.** Pi's permission flow stays on the rewritten command. |
| Read-tool source-filter destruction (would be analogous to #1080-shape on the read path) | **Sidestepped** by config defaults (`readCompaction.enabled: false`, `sourceCodeFilteringEnabled: false`). |
| #1282 pipe/redirect corruption | **Not sidestepped on Linux.** `rewrite-pipeline-safety.ts` early-returns unless `process.platform === "win32"`. |
| #690 Playwright stripping | **Not sidestepped.** `rtk rewrite playwright test` still calls into rtk's filter. |
| #720 gh comments dropped | **Not sidestepped.** v0.6.0 removed local `gh` bypass tables. |
| #1152 rtk curl JSON destruction | **Not sidestepped.** Our `rtk gain` confirms heavy `rtk curl` use. |
| #1080 rtk npx | **Not sidestepped** (delegated). |

It also *adds* its own #690-shape risks via secondary compaction (runs *after* `rtk rewrite` already filtered):
- `aggregateTestOutput` (`src/techniques/test-output.ts`) keeps at most 5 failures, truncates each failure's first line to 70 chars and subsequent lines to 65 chars. Stacks with rtk's own test summarizer.
- Hard 12000-char truncate on bash output (a single Rust panic + backtrace blows past 12K).
- `compactGitOutput`, `aggregateLinterOutput`, `filterBuildOutput`, `groupSearchOutput` — second pass on already-rtk'd output.
- `stripRtkHookWarnings` + `sanitizeRtkEmojiOutput` suppress rtk's own diagnostic warnings (`src/techniques/rtk.ts`), which can hide future rtk warnings that match the marker prefixes (`[rtk] /!\\`, `⚠`, `[WARN]`).

### "What about suggest mode?"

`pi-rtk-optimizer` config supports `mode: "suggest"`. Looking at `src/index.ts`:
```ts
if (config.mode === "suggest") {
    if (suggestionNotices.remember(suggestionKey) && ctx.hasUI) {
        ctx.ui.notify(`RTK suggestion: ${decision.rewrittenCommand}`, "info");
    }
}
```

Two things to know:
1. The suggestion goes to the **TUI human only** via `ctx.ui.notify` — it's not injected into agent context. The model never sees it. Suggest mode = the agent runs raw commands with no rtk in the path.
2. Pi-rtk-optimizer's `tool_result` compaction handler is *not* gated on `config.mode`, only on `config.enabled && config.outputCompaction.enabled`. So in suggest mode you keep the JS-side compactions (`compactGitOutput`, `aggregateTestOutput`, `groupSearchOutput`, `stripAnsi`, the 12K truncate) without `rtk rewrite` being called.

Suggest mode is a real configuration: **none of the rtk-binary failure modes apply, but you keep some token savings**. We considered this as the fallback before deciding to remove the extension entirely.

### "What about full disable?"

Setting `enabled: false` short-circuits every functional handler in `src/index.ts` (each one starts with `if (!config.enabled) return {};`). The only thing that keeps running is `before_agent_start → ensureRuntimeStatusFresh()`, which spawns `rtk --version` periodically because it's gated by `guardWhenRtkMissing` rather than `enabled`. To stop that too, set `guardWhenRtkMissing: false`. To unload the extension code entirely: `pi remove npm:pi-rtk-optimizer` (what we did).

## Why pi-context-prune

Architecturally clean fit for what we actually want:

1. **Recoverable, not lossy.** The originals stay in the session index. `context_tree_query` is an LLM-callable tool the agent can use to fetch back any pruned output by id. If a summary turns out to have dropped detail, the agent can retrieve.

2. **Right layer for prompt caching.** With `pruneOn: "agent-message"` (the recommended default), pruning happens once per user → final-agent-reply span — i.e. per work batch. After the prune, the new shorter context becomes stable until the next batch, so prompt-prefix caching can kick in. Aggressive modes (`every-turn`) bust the cache after every tool round, which can cost more than the tokens saved despite shrinking raw context. The README's [PRUNING.md](https://github.com/championswimmer/pi-context-prune/blob/main/PRUNING.md) has the deep dive.

3. **Doesn't touch the bash data path.** Commands run raw. The agent gets full `git log`, full `cargo test` output, full `curl` JSON. The trade-off: we don't get the per-command rtk savings on those individual outputs *while they're hot*. We do get the savings retroactively, when those tool results age out of the active window and get batched + summarized.

4. **Originals are never modified on disk.** Pruning only affects the next request's context build. The session JSONL stays intact for `vcc_recall` (our session-level history search via `pi-vcc`) and post-hoc analysis.

5. **Smaller surface area than the rtk stack.** No external binary dependency, no schema-conversion modes, no command-specific filters with their own bug surfaces. The summarizer model is whatever you configure (default = session model).

### Modes — what each one trades

| Mode | Trigger | Cache impact | Use when |
|---|---|---|---|
| `every-turn` | After each tool-calling turn | Worst — busts cache every turn | Debugging the extension. Not recommended for real work. |
| `on-context-tag` | When `context_tag` is called | Depends on tag cadence | You use the [`pi-context`](https://github.com/ttttmr/pi-context) extension and think in milestones. |
| `on-demand` | Only when you run `/pruner now` | Best — nothing changes until you say so | Long investigations where you want explicit control. |
| `agent-message` | When agent sends final text-only response or loop ends | Good — one bust per work batch | **Default.** Best balance for normal coding workflows. |
| `agentic-auto` | Model decides via `context_prune` tool | Variable — depends on model judgment | Long autonomous runs after prompt-tuning. |

We run `agent-message`.

### Operational details

**Install:**
```bash
pi install npm:pi-context-prune
```

**Config:** `~/.pi/agent/context-prune/settings.json`
```json
{
  "enabled": true,
  "showPruneStatusLine": true,
  "summarizerModel": "default",
  "summarizerThinking": "default",
  "pruneOn": "agent-message",
  "remindUnprunedCount": true,
  "batchingMode": "turn"
}
```

Default `enabled` ships as `false` — the install does not auto-activate. Our `pi-setup.sh` writes this file with `enabled: true` if it doesn't exist, preserving any existing user config.

**Slash commands:**
- `/pruner` — interactive settings modal (mode, summarizer model, thinking level, etc.)
- `/pruner now` — flush pending batches and summarize/prune immediately
- `/pruner show` — show pending batches and last prune stats

**LLM-callable tools registered:**
- `context_tree_query` — retrieve full original output of any pruned tool call by id. Always registered.
- `context_prune` — only registered when `pruneOn === "agentic-auto"`. Lets the model trigger pruning when it judges context is large.

**Ephemeral nudge:** when `remindUnprunedCount: true` and `pruneOn: "agentic-auto"`, the extension injects a small `<pruner-note>` reminder before each LLM call telling the model how many unpruned tool-call results have piled up. No-op in other modes.

## Layered Stack — How This Composes

We run three context-management extensions, each at a different layer:

1. **`pi-context-prune`** — *tool-call batch level.* Per work batch, summarize the originals and prune from future context. Originals retrievable via `context_tree_query`. New today.
2. **`pi-boomerang`** — *subagent level.* When you launch an autonomous task via `/boomerang`, only its summarized result returns to the parent context. The subagent's full transcript stays in its own session.
3. **`@sting8k/pi-vcc`** — *session level.* When the running session approaches `contextWindow - reserveTokens`, pi-vcc replaces pi's default summarization (which can 400 on long spans) with a deterministic algorithmic extraction (goal / files / commits / outstanding / preferences + rolling transcript). Older history stays searchable via `vcc_recall`. Documented at [[tools/pi-agent#compaction-landscape]].

These are orthogonal and stack without conflict. None touches the bash data path; all of them operate on the conversation history.

## Sanity Check — Are Output-Side Optimizations Even The Right Layer?

A point worth repeating from the surveyed alternatives. From [implicator.ai's caveman analysis](https://www.implicator.ai/caveman-claude-code-skill-cuts-output-20-your-bill-barely-notices-2/) and [vexp.dev's manual-vs-automated piece](https://vexp.dev/blog/claude-code-token-optimization-manual-vs-automated):

> Output tokens make up only 0.6 to 2.5 percent of a typical Claude Code bill, capping real savings at 1 to 3 percent. Real cost lever is input-side: prompt caching, tool-return discipline, and memory-file compression beat output tricks.

This validates the architectural choice: input/context-side dedup is where the tokens actually live. Bash-output filters (rtk-class) are a real but smaller win, and one that comes with the failure modes catalogued above. Output-text compressors (caveman) are essentially a rounding error on cost.

## What We Did Not Install (And Why)

| Tool | Why not |
|---|---|
| `pi-rtk-optimizer` (re-installed in suggest mode) | Real fallback if we miss the JS-side compactions. Not currently needed because pi-context-prune covers the high-volume case (batch-level pruning). Re-evaluate if specific commands (lots of repetitive `git status` in a single batch) start dominating in-flight context before pruning kicks in. |
| `pi-dynamic-context-pruning` | More feature surface (dedup + compress tool + error purging) but [issue #5](https://github.com/complexthings/pi-dynamic-context-pruning/issues/5) on unbounded compression-block growth is unresolved at audit time. Could revisit one of the maintained forks (PSU3D0, zenobi-us, edmundmiller, wassname) if pi-context-prune's batch-level approach turns out to miss things. |
| `lean-ctx` | Same architectural class as rtk. Better engineered surface area, slightly more honest changelog (their own 'fix inflated savings' release), but the architectural ceiling is the same. Not worth replacing rtk with another instance of the same category. |
| `snip` | Same architectural class as rtk, smaller user base. Filter-DSL inspectability is a real plus if we ever wanted to engineer per-command filters carefully — but we'd rather not be in that business. |
| `caveman` | Output-side compression. ~1–3% of bill at honest measurement. Has correctness regressions in its own validator (issue #112). Skip. |
| `headroom` | Provider-side proxy. Adds a moving piece in the data path. 102 open issues at audit time, including provider-auth breakage and discarded-compression-result bugs. Could revisit when more battle-tested. |
| `hermes-context-manager` | For Hermes Agent, not pi. Architectural cousin of pi-dynamic-context-pruning. |
| `sherif-fanous/pi-rtk`, `mcowger/pi-rtk` | Older / less-featureful alternative `rtk` wrappers for pi. Same Cat A failure modes apply. |

## Open Questions / What to Watch

- **Does `rtk` 0.38's `exclude_commands` actually work?** Critical for anyone keeping the binary around. Verify with `rtk rewrite curl <something>` after adding `curl` to `[hooks] exclude_commands`. Should return the original command and exit 1. If it does — the documented escape hatch is real and `rtk proxy` becomes a usable manual tool. If it doesn't — the binary is genuinely only useful for explicit `rtk gain` and `rtk proxy <cmd>` invocations.
- **Does `pi-context-prune` summarization quality drop on long autonomous runs?** Need to compare summaries against `context_tree_query` retrievals on real autoloop sessions. If summaries miss critical state, raise `summarizerThinking` or change `summarizerModel` to a larger model.
- **Do we ever need the bash-side savings back?** If batch-level pruning leaves too much in-flight context (e.g., a single batch with 100 `git status` calls and a `cargo test`), reinstall `pi-rtk-optimizer` in suggest mode with `aggregateTestOutput: false` and the 12K truncate disabled. That gives ANSI strip + safe git/search/lint grouping without `rtk rewrite` in the path.
- **Cross-extension interactions during compaction.** `pi-context-prune` rewrites future-request context; `pi-vcc` overrides pi's `/compact` and auto-threshold compaction. They operate on different events but rewrite related data. If we see weird state loss after a `/compact`, this is the first place to look.

## Provenance

- **rtk failure-mode catalog.** Originally received as an external analysis; cross-checked against the upstream `rtk-ai/rtk` issue tracker (issue numbers as references), our own `pi-rtk-optimizer` source-level audit (npm tarball at v0.7.1, via `npm pack`), and our `rtk gain` data. We did not personally reproduce every issue end-to-end; the audit is more "shapes that match our priors and that the upstream tracker corroborates" than "we hit every one of these in our own sessions."
- **`pi-rtk-optimizer` audit.** Direct source review of the 0.7.1 npm package (`src/index.ts`, `src/command-rewriter.ts`, `src/output-compactor.ts`, `src/rewrite-pipeline-safety.ts`, `src/runtime-guard.ts`, `src/techniques/*`).
- **`pi-context-prune` analysis.** Direct source review of the 0.9.1 npm package, plus the upstream README and PRUNING.md.
- **Third-party measurements.** Cited inline (implicator.ai, vexp.dev, lean-ctx release notes, caveman issue tracker).
- **Installed `rtk gain` numbers.** Our own session, verified at audit time: 75.8% across 776 commands, with `rtk curl` showing 99.6% on a single call (the schema-conversion smoking gun).

## Related

- [[tools/pi-agent]] — overall pi extension stack; this page is the deep dive on the token/context-management slice.
- [[tools/rtk]] — the RTK Rust binary itself (still on PATH for explicit use).
- pi-vcc compaction analysis lives in [[tools/pi-agent#compaction-landscape]].
