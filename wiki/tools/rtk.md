---
title: RTK (Rust Token Killer)
tags: [tools, token-optimization, cli, rust]
sources:
  - https://github.com/rtk-ai/rtk
  - https://www.rtk-ai.app
links:
  - https://github.com/rtk-ai/rtk
  - https://www.rtk-ai.app
  - https://formulae.brew.sh/formula/rtk
---

# RTK (Rust Token Killer)

RTK is a high-performance CLI proxy that filters and compresses command outputs before they reach your LLM context, reducing token consumption by 60-90%.

## Overview

| Attribute | Value |
|-----------|-------|
| **Version** | 0.38.0 (as of 2026-05-03) |
| **Language** | Rust |
| **License** | MIT |
| **Author** | Patrick Szymkowiak |
| **Repository** | github.com/rtk-ai/rtk |

## Installation

### Homebrew (recommended)
```bash
brew install rtk
```

### Quick Install (Linux/macOS)
```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```
Installs to `~/.local/bin`. Add to PATH if needed.

### Cargo
```bash
cargo install --git https://github.com/rtk-ai/rtk
```

### Pre-built Binaries
Download from [releases](https://github.com/rtk-ai/rtk/releases):
- macOS: `rtk-x86_64-apple-darwin.tar.gz` / `rtk-aarch64-apple-darwin.tar.gz`
- Linux: `rtk-x86_64-unknown-linux-musl.tar.gz` / `rtk-aarch64-unknown-linux-gnu.tar.gz`
- Windows: `rtk-x86_64-pc-windows-msvc.zip` (WSL recommended for full support)

### Verify Installation
```bash
rtk --version   # Should show "rtk 0.38.0"
rtk gain        # Show token savings stats
```

## Token Savings

Based on a 30-minute Claude Code session with medium-sized TypeScript/Rust projects:

| Operation | Frequency | Standard Tokens | RTK Tokens | Savings |
|-----------|-----------|-----------------|------------|---------|
| `ls` / `tree` | 10x | 2,000 | 400 | -80% |
| `cat` / `read` | 20x | 40,000 | 12,000 | -70% |
| `grep` / `rg` | 8x | 16,000 | 3,200 | -80% |
| `git status` | 10x | 3,000 | 600 | -80% |
| `git diff` | 5x | 10,000 | 2,500 | -75% |
| `git log` | 5x | 2,500 | 500 | -80% |
| `git add/commit/push` | 8x | 1,600 | 120 | -92% |
| `cargo test` / `npm test` | 5x | 25,000 | 2,500 | -90% |
| `ruff check` | 3x | 3,000 | 600 | -80% |
| `pytest` | 4x | 8,000 | 800 | -90% |
| `go test` | 3x | 6,000 | 600 | -90% |
| **Total** | | **~118,000** | **~23,900** | **-80%** |

## Supported Command Categories

### Files
- `rtk ls .` — Token-optimized directory tree
- `rtk read file.rs` — Smart file reading
- `rtk read file.rs -l aggressive` — Signatures only (strips bodies)
- `rtk smart file.rs` — 2-line heuristic code summary
- `rtk grep "pattern" .` — Grouped search results
- `rtk diff file1 file2` — Condensed diff

### Git
- `rtk git status` — Compact status
- `rtk git log -n 10` — One-line commits
- `rtk git diff` — Condensed diff
- `rtk git commit -m "msg"` → "ok abc1234"
- `rtk git push` → "ok main"

### Test Runners
- `rtk cargo test` — Rust tests (NDJSON, -90%)
- `rtk pytest` — Python tests (-90%)
- `rtk go test` — Go tests (NDJSON, -90%)
- `rtk jest` / `rtk vitest` — JS tests (failures only)
- `rtk test <cmd>` — Generic test wrapper

### Build & Lint
- `rtk cargo build` / `rtk cargo clippy` — -80%
- `rtk ruff check` — Python linting (JSON, -80%)
- `rtk golangci-lint run` — Go linting (JSON, -85%)
- `rtk lint` — ESLint grouped by rule/file
- `rtk tsc` — TypeScript errors grouped by file

### Containers
- `rtk docker ps` — Compact container list
- `rtk docker logs <container>` — Deduplicated logs
- `rtk kubectl pods` — Compact pod list

### AWS
- `rtk aws ec2 describe-instances` — Compact instance list
- `rtk aws lambda list-functions` — Name/runtime/memory (strips secrets)
- `rtk aws s3 ls` — Truncated with tee recovery

### Analytics
- `rtk gain` — Summary stats
- `rtk gain --graph` — ASCII graph (last 30 days)
- `rtk discover` — Find missed savings opportunities

## Auto-Rewrite Hook

The most effective way to use rtk. The hook transparently intercepts Bash commands and rewrites them to rtk equivalents before execution.

### Setup
```bash
rtk init -g                 # Install hook + RTK.md (recommended)
rtk init --show             # Verify installation
```

### How It Works

```
Without rtk:                          With rtk:

Claude --git status--> shell --> git  Claude --git status--> RTK --> git
  ^                               ^    |                      |        |
  |      ~2,000 tokens (raw)      |    |   ~200 tokens        | filter |
  +-------------------------------+    +---- (filtered) ------+--------+
```

Four strategies applied per command type:
1. **Smart Filtering** — Removes noise (comments, whitespace, boilerplate)
2. **Grouping** — Aggregates similar items (files by directory, errors by type)
3. **Truncation** — Keeps relevant context, cuts redundancy
4. **Deduplication** — Collapses repeated log lines with counts

## Supported AI Tools

RTK integrates with 12+ AI coding tools:

| Tool | Install Command | Method |
|------|-----------------|--------|
| **Claude Code** | `rtk init -g` | PreToolUse hook |
| **GitHub Copilot** | `rtk init -g --copilot` | PreToolUse hook |
| **Cursor** | `rtk init -g --agent cursor` | hooks.json |
| **Gemini CLI** | `rtk init -g --gemini` | BeforeTool hook |
| **Codex** | `rtk init -g --codex` | AGENTS.md + RTK.md |
| **Windsurf** | `rtk init --agent windsurf` | .windsurfrules |
| **Cline / Roo Code** | `rtk init --agent cline` | .clinerules |
| **Pi** | Via pi-rtk-optimizer | Delegates to `rtk rewrite` |

## Windows Support

| Feature | WSL | Native Windows |
|---------|-----|----------------|
| Filters | Full | Full |
| Auto-rewrite hook | Yes | No (CLAUDE.md fallback) |
| `rtk init -g` | Hook mode | CLAUDE.md mode |

**Recommendation:** Use WSL for full support. On native Windows, use rtk explicitly (`rtk cargo test`, etc.).

## Configuration

`~/.config/rtk/config.toml` (macOS: `~/Library/Application Support/rtk/config.toml`):

```toml
[hooks]
exclude_commands = ["curl", "playwright"]  # skip rewrite for these

[tee]
enabled = true          # save raw output on failure (default: true)
mode = "failures"       # "failures", "always", or "never"
```

### TEE Recovery
When a command fails, RTK saves full unfiltered output:
```
FAILED: 2/15 tests
[full output: ~/.local/share/rtk/tee/1707753600_cargo_test.log]
```

## Relation to Pi Extensions

RTK is the core engine that pi-rtk-optimizer delegates to:

- **pi-rtk-optimizer** wraps RTK for pi — runs `rtk rewrite` for command rewriting
- **sherif-fanous/pi-rtk** also delegates to `rtk rewrite`
- Both extensions require RTK binary on PATH

RTK itself integrates directly with Claude Code, Cursor, Windsurf, Cline, and others via hooks. For pi, the extension approach is used because pi lacks Claude Code's hook system.

## Global Flags

```bash
-u, --ultra-compact    # ASCII icons, inline format (extra token savings)
-v, --verbose          # Increase verbosity (-v, -vv, -vvv)
```

## Uninstall

```bash
rtk init -g --uninstall     # Remove hook, RTK.md, settings.json entry
cargo uninstall rtk          # Remove binary
```