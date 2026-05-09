# Wiki Index

## Concepts

- [[concepts/autonomous-loops]] — Autonomous loop extensions for Pi: optimization, multi-agent, goal supervision, comparison tables
- [[concepts/llm-wiki]] — The LLM Wiki pattern: agent-compiled knowledge base vs RAG, implementations, ecosystem

## Practices

- [[practices/ml-workflow-tips]] — ML dev environment setup: mamba + uv, nvm.fish, Starship, byobu/tmux, Atuin

## Tools

- [[tools/pi-agent]] — Pi coding agent: minimal extensible terminal coding harness (pi.dev), plugin stack, pi-zentui customization log, Codex quota status, account rotation, optional Codex fast mode
- [[tools/pi-model-selection]] — Pi model selection & customization: favorites, scoping, sticky models, extensions
- [[tools/pi-statusline]] — Pi status line / powerline footer: colorful segments, presets, themeable TUI bar
- [[tools/pruning-and-compaction]] — Token reduction landscape: per-command output summarizers vs context-level dedup/pruning, lossless-vs-lossy transforms, rtk failure-mode audit, why we removed pi-rtk-optimizer and installed pi-context-prune
- [[tools/rtk]] — RTK (Rust Token Killer): high-performance CLI proxy for 60-90% token reduction (binary on PATH; auto-rewrite extension removed — see pruning-and-compaction)
- [[tools/outline-edit]] — CLI for Outline knowledge base with local markdown cache
- [[tools/realitycheck]] — Framework for rigorous claim/source/prediction tracking with vector search
- [[tools/session-traces]] — Session trace viewing, cost tracking, and analytics: toaster, pi-sessions-viewer, agentsview, ccusage
