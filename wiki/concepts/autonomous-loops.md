---
title: Autonomous Loop Extensions for Pi Agent
tags: [concepts, pi-agent, loops, automation, optimization, research]
sources: []
links:
  - https://github.com/davebcn87/pi-autoresearch
  - https://github.com/nicobailon/pi-boomerang
  - https://github.com/nicobailon/pi-review-loop
  - https://github.com/tintinweb/pi-supervisor
  - https://github.com/samfoy/pi-ralph
  - https://github.com/tmustier/pi-extensions
  - https://github.com/nicobailon/pi-messenger
  - https://github.com/burggraf/pi-teams
  - https://github.com/lsj5031/PiSwarm
  - https://github.com/patleeman/task-factory
  - https://github.com/tintinweb/pi-schedule-prompt
  - https://github.com/akijain2000/hermes-loop
  - https://github.com/getcompanion-ai/feynman
  - https://github.com/leo-lilinxiao/codex-autoresearch
  - https://github.com/karpathy/autoresearch
  - https://github.com/ArtemisAI/pi-loop
---

# Autonomous Loop Extensions for Pi Agent

Comparison of pi extensions and related tools for autonomous iteration, goal tracking, optimization loops, multi-agent coordination, and research automation.

## Background

Karpathy's [autoresearch](https://github.com/karpathy/autoresearch) established the core pattern: edit → benchmark → keep improvements → revert regressions → repeat. The pi ecosystem has evolved several variations targeting different use cases: optimization loops, multi-agent orchestration, goal supervision, and token-efficient long runs.

Our own work uses loops extensively for kernel optimization (sansho, fsr4), quantization sweeps (kvcache), training runs (shisa-moe), and punchlist-driven development (shisad). We maintain a [codex-autoresearch fork](https://github.com/lhl/codex-autoresearch) with multi-loop-per-worktree support.

## Master Comparison

### Optimization Loop Extensions

These implement the edit→measure→keep/revert cycle.

| | pi-autoresearch | codex-autoresearch (our fork) |
|---|---|---|
| **npm** | `pi-autoresearch` | N/A (Codex skill) |
| **Version** | v1.3.0 | custom fork |
| **Stars** | 6.3K | fork of leo-lilinxiao |
| **Platform** | Pi | Codex |
| **Keep/revert** | Yes | Yes |
| **Confidence scoring** | Yes (MAD, ≥2.0× = green) | No |
| **TUI widget** | Yes (live dashboard) | No |
| **Multi-loop per worktree** | No | Yes (via `--results-path`, `LANE` + `RUN_TAG`) |
| **Parallel experiments** | No | Yes (up to 3 via worktrees) |
| **Dual-gate verify+guard** | Partial (`checks.sh`) | Yes |
| **Modes** | Loop only | 7 (loop/plan/debug/fix/security/ship/exec) |
| **Benchmark script** | Generates `autoresearch.sh` for you | Uses your existing scripts |
| **State files** | 5+ files (.md, .sh, .jsonl, .config.json, .checks.sh, .hooks/) | 2 files (state.json, results.tsv) |
| **Branch workflow** | Yes (creates branches, finalize skill) | No |
| **Session persistence** | `autoresearch.jsonl` survives context resets | `autoresearch-state.json` |
| **Hooks** | before.sh, after.sh | Cross-process locking |
| **Cross-run learning** | No | Yes (lessons bias future hypotheses) |
| **Escalation** | No | Yes (3 fails → refine, 5 → pivot, 2 pivots → web search, 3 → stop) |
| **CI/exec mode** | No | Yes (non-interactive, JSON output) |

**Verdict:** pi-autoresearch is more polished (TUI, confidence scoring, branch workflow) but opinionated — it wants to own the benchmark script. Our fork is leaner, supports multi-loop, and works with existing benchmark scripts. Neither fully covers our needs.

### Token-Efficient Execution

| | pi-boomerang | pi-continue |
|---|---|---|
| **npm** | `pi-boomerang` | `pi-continue` |
| **Version** | v0.6.2 | recent |
| **Stars** | 140 | — |
| **Purpose** | Token-efficient autonomous loops | Same-session continuation past context limits |
| **Mechanism** | Execute → summarize → replace history with compact handoff | Continuation Ledger artifacts + native compaction |
| **Rethrow mode** | 1-999 iterations with summaries between | No |
| **Anchor points** | Yes (multi-task checkpoints) | No |
| **Trigger** | Ctrl+Alt+B or explicit | Automatic on context fill |
| **Use case** | Long optimization sweeps that blow context | Any long session |

**Verdict:** pi-boomerang is essential for optimization loops that run 15+ iterations. pi-continue is complementary for general context management.

### Goal Supervision

| | pi-supervisor | pi-review-loop |
|---|---|---|
| **npm** | `pi-supervisor` | `pi-review-loop` |
| **Version** | v0.4.2 | v0.4.4 |
| **Stars** | 40 | 73 |
| **Purpose** | Steer agent toward defined outcome | Self-review until clean |
| **Mechanism** | Separate supervisor LLM analyzes each turn, injects steering | Review → fix → re-review loop |
| **Goal tracking** | `/supervise <outcome>` | Exit detection ("no issues found") |
| **Convergence** | 80% lenient threshold after 5 steering failures | Smart exit distinguishes "found nothing" from "fixed then clean" |
| **Supervisor model** | Default Claude Haiku (cheap) | Same model |
| **Custom rules** | `.pi/SUPERVISOR.md` | No |
| **Sensitivity** | Low/medium/high | N/A |
| **Fresh context** | No | Yes (strips prior iterations) |
| **Auto-trigger** | No | Yes (on keywords) |

**Verdict:** pi-supervisor keeps loops on track (goal enforcement). pi-review-loop is a quality gate at the end. Both useful for different stages.

### Multi-Agent Orchestration

| | pi-subagents | pi-teams | pi-messenger/pi-crew | PiSwarm | task-factory | ant-colony |
|---|---|---|---|---|---|---|
| **npm** | `pi-subagents` | `pi-teams` | `pi-messenger` / `pi-crew` | manual | `taskplane` | `@ifi/oh-pi-ant-colony` |
| **Downloads/mo** | 51.9K | — | 4.8K | — | 15.2K | — |
| **Version** | v0.21.3 | v0.9.11 | — | — | — | — |
| **Stars** | — | 89 | — | 7 | — | — |
| **Coordination** | Task delegation + chains | Shared task board + messaging | PRD → dependency DAG → wave execution | Commander → Captain → wave workers | Queue-first, Foreman workspace agent | Stigmergy (pheromone decay) |
| **Parallel exec** | Yes | Yes (tmux/Zellij/iTerm2/WezTerm) | Yes (subprocess `pi --mode json`) | Yes (isolated worktrees) | Configurable concurrency | Self-organizing |
| **Worker isolation** | Subprocess | Terminal panes | Subprocess | Git worktrees | Sequential or parallel | Adaptive |
| **Goal tracking** | Task chains | Status tracking + plan approval | Task DAG (ready/done/blocked) | JSON state + resume | Stage progression | Pheromone signals |
| **Stuck detection** | No | No | Yes (flags idle agents) | Yes (auto-retry + backoff) | No | Pheromone decay (10 min) |
| **Review gate** | No | Quality gate hooks | SHIP/NEEDS_WORK/MAJOR_RETHINK | No | No | Soldier role reviews |
| **File-based coord** | No | Agent-to-agent messaging | Yes (no daemon) | JSON state | Web UI | File + memory |
| **Templates** | No | YAML team templates | No | No | No | YAML role definitions |

**Verdict:** pi-subagents for simple delegation. pi-teams for persistent multi-agent setups. PiSwarm is closest to worktree-per-agent pattern. None solve multi-loop-on-same-worktree.

### Ralph Loop (Generic Iteration)

| | pi-ralph | @tmustier/pi-ralph-wiggum |
|---|---|---|
| **npm** | `pi-ralph` (not published) | `@tmustier/pi-ralph-wiggum` |
| **Downloads/mo** | — | 5.4K |
| **Stars** | 9 | — |
| **Mechanism** | Event-driven state machine with hat-based roles | Continuous iteration until completion |
| **Completion** | `completion_promise` (magic string) + `max_iterations` + `max_runtime_seconds` | Task completion detection |
| **Multi-agent** | Yes (hat-based role transitions) | No |
| **Presets** | 6 workflow presets | No |
| **Custom workflows** | YAML definitions | No |
| **PDD planning** | Yes | No |

**Verdict:** Too generic for optimization work. No metric tracking, no keep/revert, no benchmark integration. Useful for "keep working until the task is done" but not for measured iteration.

### Scheduling & Supporting Extensions

| Extension | npm | Purpose | Relevant? |
|---|---|---|---|
| **pi-loop** | `@pi-agents/loop` | Cron/repeating prompts — `/loop 5m check`, `schedule_wakeup` for dynamic pacing, dual-gate verify+guard | Minor — scheduling, not experiment loops. Could be useful for periodic metric monitoring |
| **pi-schedule-prompt** | `pi-schedule-prompt` | Cron-like recurring prompts | Minor — loops are event-driven not time-driven |
| **pi-continuous-learning** | `pi-continuous-learning` | Distill session patterns into reusable instincts | Interesting for building optimization intuition over time |
| **hermes-loop** | manual | Self-improving agent, skill generation from experience | Novel but unproven |
| **Feynman** | `@companion-ai/feynman` | Research agent (alphaXiv, parallel research) | Paper search only — our paper work is more manual |
| **gob** | manual | Process manager for background AI jobs | Useful if running multiple loops as background processes |

## Patterns Observed

**1. Optimization Loop** (pi-autoresearch, codex-autoresearch)
Edit → measure → statistical validation → keep/revert → repeat. Best for: kernel tuning, training sweeps, performance optimization.

**2. Goal Supervision** (pi-supervisor)
External observer steers the main agent. Best for: keeping loops on-track, enforcing methodology.

**3. Context Compression** (pi-boomerang)
Summarize completed iterations to fit more loops in context. Best for: long-running sweeps.

**4. Punchlist Execution** (codex-autoresearch plan mode, pi-ralph)
Iterate until all checklist items are done. Best for: implementation plans, task completion.

**5. Wave-Based Parallelism** (PiSwarm, pi-messenger)
Dependency-aware parallel execution across worktrees. Best for: independent tasks with known dependencies.

**6. Self-Review** (pi-review-loop)
Review own work until no issues remain. Best for: quality gate before commit.

## Convergence Detection Methods

| Method | Used by | How it works |
|---|---|---|
| Statistical confidence | pi-autoresearch | Median Absolute Deviation, ≥2.0× threshold |
| Completion promise | pi-ralph | Magic output string signals done |
| Escalation ladder | codex-autoresearch | 3→refine, 5→pivot, 2 pivots→search, 3→stop |
| Steering threshold | pi-supervisor | 80% lenient after 5 consecutive steering failures |
| Exit detection | pi-review-loop | "No issues found" vs "fixed then clean" |
| Task DAG completion | pi-messenger | All tasks done or blocked |
| Pheromone decay | ant-colony | 10-minute signal decay prevents stale work |
| Budget exhaustion | pi-autoresearch | Fixed iteration/time budget |

## Gap Analysis: What We Need

Based on our work in sansho (kernel optimization), kvcache (quantization sweeps), shisa-moe (training), fsr4 (GPU tuning), and shisad-dev (punchlist-driven development):

| Need | Available? | Best current option |
|---|---|---|
| Edit→measure→keep/revert loop | Yes | pi-autoresearch |
| Multi-loop on same worktree | No | Our codex-autoresearch fork (Codex only) |
| Use existing benchmark scripts | Partial | codex-autoresearch (yes), pi-autoresearch (wants to own script) |
| Punchlist-driven iteration | Partial | codex-autoresearch plan mode |
| Token-efficient long runs | Yes | pi-boomerang |
| Goal enforcement | Yes | pi-supervisor |
| Statistical confidence on noisy benchmarks | Yes | pi-autoresearch (MAD scoring) |
| Lane/run-tag isolation | No | Our fork only |
| Shared results between loops | No | Nothing supports this |
| CI/exec non-interactive mode | No (pi) | codex-autoresearch exec mode |

**Conclusion:** No single pi extension covers our needs. The plan is to build a new extension combining multi-loop isolation, existing-script integration, punchlist mode, and confidence scoring. See [[concepts/pi-autoloop-design]] (planned).

## Name Candidates

Available on npm as of 2026-05-03:
- `pi-autoloop` — concise, clear intent
- `pi-multiloop` — emphasizes the multi-loop differentiator
- `pi-lanes` — matches our LANE+RUN_TAG terminology
- `pi-sweep` — optimization/research connotation
- `pi-iterate` — generic but available

Taken: `pi-loop` (v0.1.5, planner-worker-judge CLI), `pi-harness` (v0.1.1)
