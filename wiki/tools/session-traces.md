---
title: Session Traces and Stats
tags: [tools, session-traces, cost-tracking, analytics, usage]
sources: []
links:
  - https://github.com/bivalve-ai/toaster
  - https://github.com/ygncode/pi-sessions-viewer
  - https://github.com/wesm/agentsview
  - https://github.com/ryoppippi/ccusage
  - https://ccusage.com
  - https://github.com/lhl/vibecheck/tree/main/hackathon-stats
  - https://github.com/anthropics/claude-code/issues/42796
---

Tools for viewing, analyzing, translating, and tracking costs across AI coding agent session traces. These tools operate on local session files (JSONL, JSON) produced by agents like pi, Claude Code, Codex CLI, OpenCode, and others.

## Session Location Reference

Default session directories across major AI coding agents. Tools like agentsview and toaster auto-discover from these paths; scripts can target them directly for custom analysis.

| Agent | Session Directory |
| --- | --- |
| Claude Code | `~/.claude/projects/` |
| Codex CLI | `~/.codex/sessions/` |
| Pi | `~/.pi/agent/sessions/` |
| Copilot CLI | `~/.copilot/` |
| Gemini CLI | `~/.gemini/` |
| OpenCode | `~/.local/share/opencode/` |
| OpenHands CLI | `~/.openhands/conversations/` |
| Cursor | `~/.cursor/projects/` |
| Amp | `~/.local/share/amp/threads/` |
| iFlow | `~/.iflow/projects/` |
| Zencoder | `~/.zencoder/sessions/` |
| VSCode Copilot | `~/Library/Application Support/Code/User/` (macOS) |
| OpenClaw | `~/.openclaw/agents/` |
| Kimi | `~/.kimi/sessions/` |
| Kiro CLI | `~/.kiro/sessions/cli/` |
| Kiro IDE | `~/Library/Application Support/Kiro/` (macOS) |
| Cortex Code | `~/.snowflake/cortex/conversations/` |
| Hermes Agent | `~/.hermes/sessions/` |
| Forge | `~/.forge/` |
| Piebald | `~/.local/share/piebald/` |
| Warp | `~/.warp/` (platform-dependent) |
| Positron Assistant | `~/Library/Application Support/Positron/User/` (macOS) |

### Multi-machine aggregation

Sessions accumulate on each machine you use. A simple `rsync` script can aggregate them into a single directory for unified analysis:

```bash
# Sync .claude, .codex, and .pi from remote hosts into ~/session-archive/<host>/
for host in host1 host2 host3; do
    for folder in .claude .codex .pi; do
        rsync -avz "$host:~/$folder/" "~/session-archive/$host/${folder#.}/"
    done
done
```

This gives a flat structure like `~/session-archive/host1/claude/projects/...`, `~/session-archive/host2/codex/sessions/...`, etc. — which custom scripts can scan alongside local sessions.

### Token economics auditing

A comprehensive Python script for multi-agent, multi-machine cost auditing. Discovers sessions from local dirs and aggregated `~/session-archive/` directories, caches parsed turns in SQLite for fast re-runs, applies LiteLLM pricing data, and writes CSV/Parquet summaries.

```bash
./audit.py --discover    # discover and parse all sessions
./audit.py --rerun       # re-audit from cache
```

Key patterns:

- **Multi-source discovery** — Scans standard agent directories (`~/.claude/projects/`, `~/.codex/sessions/`, etc.) plus aggregated archives
- **SQLite caching** — Parsed turns cached with schema versioning for incremental re-runs
- **Pricing-aware** — Fetches pricing from LiteLLM's `model_prices_and_context_window.json` with local fallback
- **Output formats** — CSV summaries + Parquet turn-level data for downstream analysis
- **Multi-model** — Handles Claude, GPT, Gemini, and other provider token formats in a unified pipeline

## Overview

| Tool | Scope | Approach | Output |
| --- | --- | --- | --- |
| [toaster](#toaster) | Multi-agent | Universal format (TOAST) + translation | Local library, resume targets |
| [pi-sessions-viewer](#pi-sessions-viewer) | Pi-only | Web UI + SSE live updates | Browser viewer, GitHub Gists |
| [agentsview](#agentsview) | 22+ agents | SQLite + web UI + CLI | Dashboard, cost tracking, stats |
| [ccusage](#ccusage) | Multi-agent (per package) | CLI parsing of JSONL files | Terminal tables, JSON reports |

## toaster

[bivalve-ai/toaster](https://github.com/bivalve-ai/toaster) — A local-first universal session store for AI agents. Ingests native session files into **TOAST** (Transferable Open Agent Session Trace), a universal standard format for preserving agent histories, tool calls, tool results, metadata, provenance, and known losses.

**Native session sources:** pi, Claude Code, Codex CLI, OpenCode export JSON.

**Key capabilities:**

- **Scan** — Discover native sessions without writing: `toaster scan`, `toaster scan --app pi`
- **Ingest** — Pull sessions into `~/toast-library/` as portable TOAST artifacts + human-readable README: `toaster ingest --all --yes`
- **Resume** — Translate a saved session back into a target agent's native format: `toaster resume <id> --in pi`
- **Translate** — Low-level format conversion between agents: `toaster translate --to claude <path>`
- **Redact** — Regex-based or OPF (OpenAI Privacy Filter) redaction with alias mapping for cloud-safe mirrors
- **Mirror** — Create redacted/aliased copies of the entire library: `toaster mirror --cloud-safe-local --alias --yes`
- **Corpus testing** — Read/validate/write/reread pipeline over a directory of sessions

**Supported native session locations:**

| Agent | Path |
| --- | --- |
| pi | `~/.pi/agent/sessions/--<cwd-encoded>--/<timestamp>_<id>.jsonl` |
| Claude Code | `~/.claude/projects/<cwd-encoded>/<id>.jsonl` |
| Codex | `~/.codex/sessions/YYYY/MM/DD/rollout-<ts>-<id>.jsonl` |
| OpenCode | `<cwd>/<session-id>.opencode.json` |

**Install:** `npm i -g toaster-cli` or `npx toaster-cli scan`. Requires Node 22+.

**Status:** Early software. Supported native stores inferred from real session files, not stable public specs. Losses are tracked in TOAST and returned to the caller. Privacy: fully local, no telemetry/analytics/cloud.

## pi-sessions-viewer

[ygncode/pi-sessions-viewer](https://github.com/ygncode/pi-sessions-viewer) — A local web viewer for [[tools/pi-agent]] sessions. Renders sessions using the same HTML/CSS as pi's `/export` command, with live incremental updates via SSE as you chat.

**Key capabilities:**

- **Session browser** — Grid view of all sessions, grouped by project
- **Tree navigation** — Full session tree with filters (same UI as `/export`)
- **Live updates** — New messages append without page refresh via SSE
- **Follow mode** — Auto-scrolls to latest message; pauses when you scroll up to read history
- **Share** — Create secret GitHub Gists directly from the browser (requires `gh` CLI)
- **`/view` command** — Type `/view` inside pi to open the current session in the browser

**Install:** Go 1.21+ required. `go build -o pi-sessions-viewer .` then copy to `~/.pi/agent/bin/`. Optional macOS LaunchAgent for auto-start.

**Pi integration:** Copy `view-sessions.ts` to `~/.pi/agent/extensions/` for the `/view` command. Copy `skill/` to `~/.pi/agent/skills/pi-sessions-viewer` to suggest the viewer when relevant.

**Architecture:** Go server (default port 27183) reads JSONL from `~/.pi/agent/sessions/`, generates HTML using pi's export templates (embedded in binary), watches files for changes, pushes SSE events to browser. Frontend fetches new entries via `/api/session` and appends incrementally.

## agentsview

[wesm/agentsview](https://github.com/wesm/agentsview) — The most comprehensive tool in this category. A single binary that auto-discovers, syncs, and indexes sessions from 22+ AI coding agents into a local SQLite database, then serves a rich web UI and CLI for browsing, full-text search, cost tracking, and analytics.

**Key capabilities:**

- **Session browser** — Full-text search across all message content (FTS5), keyboard-first navigation (`j`/`k`/`[`/`]`, `Cmd+K`), live SSE updates
- **Cost tracking** — `agentsview usage daily|monthly|session` with per-model breakdown, prompt-caching-aware calculations, automatic LiteLLM pricing (offline fallback). Positioned as a ccusage replacement with 100x faster queries via indexed SQLite.
- **Statusline** — `agentsview usage statusline` for shell prompts and status bars
- **Analytics** — Activity heatmaps, tool usage breakdowns, velocity metrics, project breakdowns, session archetypes (automation vs. quick/standard/deep/marathon), grade distribution
- **Stats** — `agentsview stats` emits window-scoped analytics with versioned JSON schema (`schema_version: 1`): totals, duration/user-message/peak-context/tools-per-turn distributions, cache economics, tool/model/agent mix, hourly temporal breakdown. Optional git outcome metrics (commits/LOC/files changed) and GitHub PR counts.
- **Export** — HTML export and GitHub Gist publishing
- **Desktop app** — Tauri-based desktop application (macOS / Windows)
- **Docker** — Published image `ghcr.io/wesm/agentsview:latest` with optional PostgreSQL backend

**Supported agents (22+):**

Claude Code, Codex CLI, Copilot CLI, Gemini CLI, OpenCode, OpenHands CLI, Cursor, Amp, iFlow, Zencoder, VSCode Copilot, Pi, OpenClaw, Kimi, Kiro CLI, Kiro IDE, Cortex Code, Hermes Agent, Forge, Piebald, Warp, Positron Assistant.

**Install:** `curl -fsSL https://agentsview.io/install.sh | bash`, download from [GitHub Releases](https://github.com/wesm/agentsview/releases), or `docker run ghcr.io/wesm/agentsview:latest`.

**Tech:** Go backend, Svelte frontend, SQLite (default) or PostgreSQL. Managed Caddy for TLS in serve mode. Written by Wes McKinney.

## ccusage

[ryoppippi/ccusage](https://github.com/ryoppippi/ccusage) — A family of CLI tools for analyzing AI coding agent token usage and costs from local session files. The flagship `ccusage` package targets Claude Code; companion packages cover Codex, OpenCode, pi, and Amp. All share a common architecture: parse JSONL, apply pricing data, render terminal tables.

**Packages:**

| Package | Agent | npm |
| --- | --- | --- |
| `ccusage` | Claude Code | `npx ccusage@latest` |
| `@ccusage/codex` | OpenAI Codex | `npx @ccusage/codex@latest` |
| `@ccusage/opencode` | OpenCode | `npx @ccusage/opencode@latest` |
| `@ccusage/pi` | Pi | `npx @ccusage/pi@latest` |
| `@ccusage/amp` | Amp | `npx @ccusage/amp@latest` |
| `@ccusage/mcp` | MCP server | `npx @ccusage/mcp@latest` |

**Key capabilities:**

- **Reports** — `daily`, `weekly`, `monthly`, `session`, `blocks` (5-hour billing windows)
- **Statusline** — `ccusage statusline` for Claude Code status bar hooks (Beta)
- **Filters** — `--since`/`--until` date ranges, `--project` for specific projects, `--instances` grouping
- **Model breakdown** — `--breakdown` for per-model cost split
- **JSON output** — `--json` for programmatic consumption
- **Offline mode** — Pre-cached pricing data, no network required
- **Compact mode** — `--compact` for narrow terminals / screenshots
- **MCP server** — `@ccusage/mcp` exposes usage data to Claude Desktop and other MCP-compatible tools

**Website:** [ccusage.com](https://ccusage.com) with full VitePress documentation. Sponsored development with video feature on YouTube.

**Status:** Active — regular releases, growing monorepo, community sponsorship. Small bundle size ([packagephobia badge](https://packagephobia.com/result?p=ccusage)).

## Comparison

| Dimension | toaster | pi-sessions-viewer | agentsview | ccusage |
| --- | --- | --- | --- | --- |
| Agents supported | 4 (pi, Claude, Codex, OpenCode) | 1 (pi) | 22+ | 5+ (per package) |
| UI | CLI only | Web UI | Web UI + CLI + desktop | CLI only |
| Cost tracking | No | No | Yes (SQLite-indexed, 100x faster) | Yes (per-session parse) |
| Session translation | Yes (cross-agent) | No | No | No |
| Export | TOAST JSON | GitHub Gist | HTML, Gist | JSON tables |
| Live updates | No | Yes (SSE) | Yes (SSE) | No |
| Redaction | Yes (regex + OPF) | No | No | No |
| Database | Flat files (TOAST) | Flat files (reads JSONL) | SQLite / PostgreSQL | Flat files (reads JSONL) |
| Desktop app | No | No | Yes (Tauri) | No |
| Docker | No | No | Yes | No |
| Language | TypeScript | Go + TypeScript | Go + Svelte | TypeScript |

## Use Cases

- **Session portability across agents** → toaster (translate/resume between pi, Claude Code, Codex, OpenCode)
- **Live browser-based session viewing for pi** → pi-sessions-viewer (real-time SSE updates while chatting)
- **Comprehensive multi-agent cost tracking and analytics** → agentsview (single binary, rich dashboards, 22+ agents)
- **Quick CLI cost check for a single agent** → ccusage (fast `npx ccusage`, minimal overhead, pretty tables)
- **Cost tracking integrated into shell prompts/status bars** → ccusage `statusline` or agentsview `usage statusline`
- **Session redaction for cloud storage/sharing** → toaster (regex-based local or OPF-powered redaction)

## DIY Script-Based Analysis

Session JSONL files are line-delimited JSON — simple to parse with scripts for custom analysis beyond what off-the-shelf tools provide.

### Example: hackathon weekend stats (vibecheck)

[lhl/vibecheck — hackathon-stats/](https://github.com/lhl/vibecheck/tree/main/hackathon-stats) — A Python script (`analyze_sessions.py`) that parses Claude Code and Codex CLI JSONL sessions to produce aggregate and per-session statistics: tokens (input/cache/output), wall/active time, turn counts, tool call counts, user messages. Supports `--json` output for piping to `jq`. Adapted from the [fsr4-rdna3-optimization session analysis methodology](https://github.com/lhl/vibecheck/tree/main/fsr4-rdna3-optimization/session-analysis).

Key stats it extracts:

- **Active vs idle time** — Computes active time by detecting gaps >5 minutes between events (wall time minus idle gaps)
- **Token breakdown** — Separates cache-create, cache-read, input, and output tokens per session
- **Tool-level summaries** — Handles Claude Code and Codex CLI in the same pass, producing comparable metrics
- **Date filtering** — `--date-from` / `--date-to` for time-bounded analysis

### Example: thinking quality regression analysis

[anthropics/claude-code#42796](https://github.com/anthropics/claude-code/issues/42796) — A user analyzed 6,852 session JSONL files (17,871 thinking blocks, 234,760 tool calls) to correlate thinking redaction rollout (`redact-thinking-2026-02-12`) with measured quality regression. Demonstrates the power of raw session trace analysis for root-cause diagnosis:

- **Thinking depth estimation** — Used `signature` field correlation (0.971 Pearson) with content length to estimate thinking depth even after redaction
- **Read:Edit ratio** — Tracked file read vs file edit tool calls as a proxy for research-before-action behavior (dropped from 6.6:1 to 2.0:1)
- **Stop-hook violations** — Built an automated guard (`stop-phrase-guard.sh`) that caught ownership-dodging and lazy-completion 173 times in 17 days after the regression
- **Frustration indicators** — Measured user frustration language in prompts (+68% increase)
- **Session archetype shifts** — Prompts per session dropped 22%, write-vs-edit precision halved

The methodology shows what's possible with ad-hoc JSONL analysis: behavioral metrics, temporal correlations, and quantitative evidence for qualitative UX complaints.

### Example: release-line efficiency stats

A systematic methodology for extracting release-line development statistics from agent session traces. At each release close, a pipeline of custom scripts (`phase_metrics.py`, `agent_log_rollup.py`, `review_run_rollup.py`, `scc_snapshot.py`) generates per-phase efficiency reports from session traces and git history. Demonstrates what's extractable beyond simple token/cost counts:

**Per-phase efficiency metrics:**

| Metric | What it reveals |
| --- | --- |
| Wall time vs parent active time vs sub-session active time | How much calendar time is idle (quota pauses, breaks) vs actual agent engagement |
| Review runs and lanes per phase | Release-close churn — how many review fanout rounds needed to converge |
| Commits per phase | Net output efficiency — how many commits land from how much session time |
| Sub-session tokens per phase | Token economics at phase granularity (not just daily rollups) |

**Agent tool split analysis** — Track a single long-lived parent session that spawns fanout sub-sessions across agents (e.g., one agent for autonomous fanouts, another for release-close preflight/authoring), revealing which agents are used for which phases and the token profiles of each (cache-dominated vs precision-editing patterns).

**Release-over-release trending** — Each status report includes a comparison section tracking churn metrics across releases, giving objective evidence for whether process improvements are actually reducing iteration cycles.

**Process optimization validation** — Quantify which tooling/process improvements actually paid off: e.g., scoped-allowlist staleness rules that reduce full-fanout runs, or preflight claim checks that eliminate entire classes of release-close findings. Tie each optimization to measurable outcomes.

**Post-milestone issue analysis** — Per-issue breakdowns with review runs, lanes, distinct targets, commits, and sub-session tokens. Identifies which issues are "one-round fixes" vs multi-round churn loops and why (e.g., docs-parity truth-scoping vs straightforward code changes).

These reports are generated via a command pipeline: tag boundaries → rollup JSONs from session logs → template population → human interpretation. Every metric tied to explicit git refs and command records.

### Why DIY?

- **Custom metrics** — The tools above give you token counts and costs; scripts give you _any_ metric derivable from the raw traces (tool call sequences, thinking patterns, concurrency, agent collaboration patterns)
- **Cross-tool comparison** — Standardize metrics across Claude Code, Codex, pi, and others in a single script
- **CI/pipeline integration** — JSON output feeds into dashboards, alerts, or cost monitoring
- **Session archeology** — Long-term trend analysis over months of accumulated traces, not just the last 30 days

## Related Pages

- [[tools/pi-agent]] — Pi coding agent (the target agent for several of these tools)
- [[tools/realitycheck]] — Claim/source/prediction tracking (complementary analytical workflow)

## See Also

- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code) — Curated list where ccusage is featured
- [DeepWiki: ccusage](https://deepwiki.com/ryoppippi/ccusage) — AI-generated wiki from the codebase