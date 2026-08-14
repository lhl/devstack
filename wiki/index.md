# Wiki Index

## Concepts

- [[concepts/ai-slop]] — AI slop: the template/taxonomy, why-it-happens theory, detection & forensics research landscape, unslop/enslop training, links to shisa-v3 antislop work
- [[concepts/autonomous-loops]] — Autonomous loop extensions for Pi: optimization, multi-agent, goal supervision, comparison tables
- [[concepts/llm-wiki]] — The LLM Wiki pattern: agent-compiled knowledge base vs RAG, implementations, ecosystem

## Papers

- [[papers/delegate52-document-corruption]] — DELEGATE-52 paper analysis: long-horizon document corruption, weak agentic harness baseline, and comparison to pi, Codex CLI, and Claude Code editing workflows

## Practices

- [[practices/arch-aur-safety]] — Arch User Repository safety guide: AUR threat model, June 2026 malicious package incident checks, review checklist, build isolation, npm/Bun guardrails, and response baseline
- [[practices/cross-model-planner-executor-workflows]] — Cross-model “brain and hands” workflows: planner/scratchpad/reviewer roles, durable handoff contracts, GitHub and shared-link boundaries, harness patterns, security guardrails, and evaluation
- [[practices/llm-prose-techniques]] — Getting better prose out of LLMs: base models, logit bias, prefill, named-writer anchoring, decompose/tic-hunt, voice corpus, sampling; companion to the deslop checklist
- [[practices/ml-workflow-tips]] — ML dev environment setup: mamba + uv, nvm.fish, Starship, byobu/tmux, Atuin
- [[practices/prompting-examples]] — Source-backed prompt examples with exact extracts, reusable patterns, and caveats; includes OpenAI's GPT 5.6 Sol Ultra multi-agent Cycle Double Cover proof-search prompt
- [[practices/supply-chain-security]] — Package supply-chain security playbook: config-file rolling min-release-age gates (npm/pnpm/uv/pip via `pkg-security-setup.sh`), per-ecosystem unit gotchas, wheels-only Python wrappers, frozen installs, lifecycle-script blocking, GitHub Actions hardening, Arch AUR, and Mini Shai-Hulud/TanStack incident notes

## Tools

- [[tools/camoufox]] — Camoufox stealth Firefox (backing `tff-fetch_url` / `tff-search_web` via `camoufox-pi`): cache-layout conflicts, native bindings, Playwright/Juggler compatibility, Linux GTK/X11/ALSA dependencies, repairs, health checks, and upstream follow-ups
- [[tools/codex]] — OpenAI Codex CLI/App: local state, excessive SQLite TRACE-log write-pressure workaround, verification, and reversal
- [[tools/pi-agent]] — Pi coding agent: minimal extensible terminal coding harness (pi.dev), canonical `pi-packages.json` package sync workflow, pi-zentui customization log, codex-pool model config, conditional MultiCodex personal-account rotation, Codex quota status, pi-tasks/pi-goal forks, web-access extension compatibility notes, GitHub-sourced compaction watchdog, optional Codex fast mode
- [[tools/pi-background-task-plugins]] — Pi background task plugin evaluation: @vanillagreen/pi-background-tasks vs tmux-bash, pi-loop, pi-monitor, gob, and minimal alternatives
- [[tools/pi-model-selection]] — Pi model selection & customization: how the model catalog loads (static models.generated.js + models.json merge), favorites, scoping, sticky models, extensions
- [[tools/pi-statusline]] — Pi status line / powerline footer: colorful segments, presets, themeable TUI bar
- [[tools/pi-zentui]] — Canonical Pi footer/editor extension: stale-context shutdown failure, lifecycle-safe async refresh fix, verification, operations, and permanent follow-ups
- [[tools/pruning-and-compaction]] — Conversation-level pruning landscape, why devstack retired pi-context-prune, and the current simpler compaction stack
- [[tools/outline-edit]] — CLI for Outline knowledge base with local markdown cache
- [[tools/realitycheck]] — Framework for rigorous claim/source/prediction tracking with vector search
- [[tools/session-traces]] — Session trace viewing, cost tracking, and analytics: toaster, pi-sessions-viewer, agentsview, ccusage
