# Wiki Index

## Concepts

- [[concepts/ai-slop]] — AI slop: the template/taxonomy, why-it-happens theory, detection & forensics research landscape, unslop/enslop training, links to shisa-v3 antislop work
- [[concepts/autonomous-loops]] — Autonomous loop extensions for Pi: optimization, multi-agent, goal supervision, comparison tables
- [[concepts/llm-wiki]] — The LLM Wiki pattern: agent-compiled knowledge base vs RAG, implementations, ecosystem

## Papers

- [[papers/delegate52-document-corruption]] — DELEGATE-52 paper analysis: long-horizon document corruption, weak agentic harness baseline, and comparison to pi, Codex CLI, and Claude Code editing workflows

## Practices

- [[practices/arch-aur-safety]] — Arch User Repository safety guide: AUR threat model, June 2026 malicious package incident checks, review checklist, build isolation, npm/Bun guardrails, and response baseline
- [[practices/llm-prose-techniques]] — Getting better prose out of LLMs: base models, logit bias, prefill, named-writer anchoring, decompose/tic-hunt, voice corpus, sampling; companion to the deslop checklist
- [[practices/ml-workflow-tips]] — ML dev environment setup: mamba + uv, nvm.fish, Starship, byobu/tmux, Atuin
- [[practices/supply-chain-security]] — Package supply-chain security playbook: age gates, wheels-only Python wrappers, frozen installs, lifecycle-script blocking, GitHub Actions hardening, Arch AUR, and Mini Shai-Hulud/TanStack incident notes

## Tools

- [[tools/pi-agent]] — Pi coding agent: minimal extensible terminal coding harness (pi.dev), canonical `pi-packages.json` package sync workflow, pi-zentui customization log, Codex quota status, account rotation, pi-tasks/pi-goal forks, GitHub-sourced compaction watchdog, optional Codex fast mode
- [[tools/pi-background-task-plugins]] — Pi background task plugin evaluation: @vanillagreen/pi-background-tasks vs tmux-bash, pi-loop, pi-monitor, gob, and minimal alternatives
- [[tools/pi-model-selection]] — Pi model selection & customization: how the model catalog loads (static models.generated.js + models.json merge), favorites, scoping, sticky models, extensions
- [[tools/pi-statusline]] — Pi status line / powerline footer: colorful segments, presets, themeable TUI bar
- [[tools/pruning-and-compaction]] — Token reduction landscape: per-command output summarizers vs context-level dedup/pruning, lossless-vs-lossy transforms, rtk failure-mode audit, why we removed pi-rtk-optimizer and installed pi-context-prune
- [[tools/rtk]] — RTK (Rust Token Killer): high-performance CLI proxy for 60-90% token reduction (binary on PATH; auto-rewrite extension removed — see pruning-and-compaction)
- [[tools/outline-edit]] — CLI for Outline knowledge base with local markdown cache
- [[tools/realitycheck]] — Framework for rigorous claim/source/prediction tracking with vector search
- [[tools/session-traces]] — Session trace viewing, cost tracking, and analytics: toaster, pi-sessions-viewer, agentsview, ccusage
