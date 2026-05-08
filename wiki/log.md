# Wiki Log

## [2026-05-09] update | pi-agent — document optional pi-codex-fast extension
- Installed `@calesennett/pi-codex-fast` locally for evaluation and documented it as optional/not default.
- Captured behavior: `/codex-fast`, `pi --fast`, OpenAI/OpenAI Codex-only `service_tier: "priority"` injection, settings persistence, and status indicator.
- Decision: do not add to `pi-setup.sh` by default until there is a simple verification path proving the priority service tier is accepted and desirable for the current account/plan.
- Pages updated: wiki/tools/pi-agent.md (frontmatter links, table row, new section), wiki/index.md (tools summary updated).

## [2026-05-08] update | pi-agent — installed pi-multicodex extension
- Installed `@victor-software-house/pi-multicodex` (v2.3.1) for automatic ChatGPT Codex account rotation.
- Added to the Installed Extensions table and documented `/multicodex` commands.
- Pages updated: wiki/tools/pi-agent.md (table row, install command, new usage section), wiki/index.md (tools summary updated).
- Repo changes (committed separately): `pi-setup.sh` install command, `README.md` "Account & Quota Management" section.

## [2026-05-08] update | pi-agent — document pi-codex-conversion extension
- Fetched and analyzed https://github.com/IgorWarzocha/pi-codex-conversion for SSE/WebSocket handling.
- Added evaluated entry to the Installed Extensions table and a detailed section covering tool-swap behavior, prompt delta, native tool rewriting, passive status indicator, and the dual-transport architecture (WebSocket preferred + SSE fallback, session caching, smart continuation, retry logic, shared stream processing).
- Pages updated: wiki/tools/pi-agent.md (frontmatter link, table row, new section).

## [2026-05-06] update | pi-agent — local pi-multiloop compaction resume test
- Switched local pi install source for `pi-multiloop` from npm to `/home/lhl/pi-multiloop` to test the post-v0.1.1 compaction-aware resume fix before publishing.
- Verified the local package installs and the extension loads without errors in a print-mode smoke run.
- Pages updated: README.md (automation entry), pi-setup.sh, wiki/tools/pi-agent.md (installed table and install command).

## [2026-05-06] update | pi-agent — pi-vertex npm publish
- Tagged and pushed `lhl/pi-vertex` `v1.1.8`, created the GitHub release, and verified `@lhl/pi-vertex@1.1.8` on npm after registry propagation.
- Switched the local pi install source and setup docs from the GitHub repo URL to `npm:@lhl/pi-vertex`.
- Verified `npm info @lhl/pi-vertex version`, a temp npm install, local pi package install, and pi startup with the npm-installed package.
- Pages updated: README.md (custom provider entry), pi-setup.sh, wiki/tools/pi-agent.md (installed table source/version).

## [2026-05-06] update | pi-agent — pi-codex-status npm publish
- Published `pi-codex-status@0.1.0` to npm and created the GitHub release/tag `v0.1.0`.
- Switched the local pi install source and setup docs from the GitHub repo URL to `npm:pi-codex-status`.
- Verified npm info, global CLI statusline output, and pi `/status statusline` through the npm-installed package.
- Pages updated: README.md (UX entry), pi-setup.sh, wiki/tools/pi-agent.md (installed table and install command).

## [2026-05-06] update | pi-agent — pi-codex-status publish preflight
- Prepared the v0.1.0 publish candidate in the public status repo: user-facing README, v0.1.0 changelog fold, runtime TUI dependency, and npm publish dry-run.
- Confirmed the current package exposes only `pi-codex-status` as its CLI name.
- Pages updated: wiki/tools/pi-agent.md (CLI description).

## [2026-05-06] update | pi-agent — published Codex status extension
- Published `pi-codex-status` as a public GitHub repo: https://github.com/lhl/pi-codex-status
- Switched local pi install and setup docs from `~/pi-codex-usage` to the public GitHub source.
- Package/CLI renamed to `pi-codex-status`; `pi-codex-usage` remains a backwards-compatible CLI alias.
- Pages updated: wiki/tools/pi-agent.md (installed table, install command, usage section), README.md (UX entry), pi-setup.sh.

## [2026-05-06] update | pi-agent — installed local Codex quota status extension
- Created and installed local `~/pi-codex-usage` pi package for ChatGPT Codex quota visibility.
- Documents `/status`, `/codex-status`, `pi-codex-usage statusline`, normalized JSON output, and the private Codex usage endpoint caveat.
- Pages updated: wiki/tools/pi-agent.md (installed table, install commands, usage section), wiki/index.md (tools summary)
- Repo changes (committed separately): `pi-setup.sh` local package build/install hook and README UX entry.

## [2026-05-05] update | Compaction decision: install pi-vcc with overrideDefaultCompaction
- Trigger: pi default auto-compaction failing with `400 status code (no body)` after one compact-and-retry, blocking long sessions. Persisted after pi-continue was removed from settings.
- Root cause: pi's single-pass summarization hands the whole span to the summarizer LLM; when span + prompt exceeds the summarizer's input window the provider rejects with 400.
- Options compared: settings tuning, `pi-grounded-compaction` (single-pass with model presets), `pi-agentic-compaction` (multi-call agentic loop), `@sting8k/pi-vcc` (zero-LLM extraction), `@pi-unipi/compactor` (zero-LLM + FTS5 + XML resume).
- Decision: `@sting8k/pi-vcc` with `overrideDefaultCompaction: true` — smallest surface area, most real-world usage (4× downloads vs UniPi compactor), visible quality-iteration history in release notes, lineage-aware recall that can't go stale.
- Pages updated: wiki/tools/pi-agent.md (new "Why we moved off default compaction" section, updated Evaluated Compaction Extensions table, added pi-grounded-compaction and @pi-unipi/compactor sections, marked pi-continue removed)
- Repo changes (committed separately): AGENTS.md rule for pi plugin/toolchain sync, pi-setup.sh + README.md pi-vcc install and config bootstrap
- Source: direct package docs (pi.dev, GitHub READMEs), pi core compaction.md, local failure observation

## [2026-05-04] update | pi-agent — pi-continue disabled
- Documented "Compaction cancelled" synthesis failure (not model-specific)
- Marked pi-continue as disabled in status table
- Added known issue section with root cause analysis and workaround
- Removed from pi-setup.sh and README.md

## [2026-05-04] create | ML Workflow Tips practice page
- Source: https://llm-tracker.info/howto/ML-Workflow-Tips, local config (~/.config/atuin/config.toml, nvm.fish)
- Pages created: wiki/practices/ml-workflow-tips.md
- Covers: mamba + uv, nvm.fish, Starship, byobu/tmux, Atuin config

## [2026-05-04] ingest | LLM Wiki concept page
- Source: sources/conversations/RESEARCH-llmwiki.md, sources/gists/karpathy-llm-wiki.md, sources/gists/rohitg00-llm-wiki-v2.md
- Pages created: wiki/concepts/llm-wiki.md
- Pages updated: wiki/index.md

## [2026-05-03] update | pi-zentui rail: `┃` → `▌` (U+258C left half block)
- Changed `RAIL` constant from `┃` (U+2503 HEAVY VERTICAL LINE) → `▌` (U+258C LEFT HALF BLOCK)
- Pages updated: wiki/tools/pi-agent.md (ui.ts row)
- Editor rail (`PolishedEditor.render` in `ui.ts`): `❯` → `┃` (U+2503 HEAVY VERTICAL LINE)
- User message rail: already `┃` via `currentRailColor`, now also uses shared `RAIL` constant (both places reference same var)
- Added `const RAIL = "┃"` at top of `ui.ts` — single source of truth for the rail character
- Pages updated: wiki/tools/pi-agent.md (ui.ts row updated)

## [2026-05-03] update | pi-zentui color refinements: model/thinking teal → syntaxType, cwdText → pale lavender
- Changed model name and `(thinking)` suffix color in `index.ts`: hardcoded bright teal `#5eead4` → `syntaxType` theme token (muted teal, matches rest of UI)
- Changed `cwdText` in `zentui.json`: `syntaxOperator` → `#c9b8e8` (pale lavender for working folder)
- Pages updated: wiki/tools/pi-agent.md (index.ts row updated, cwdText row added to config table)

## [2026-05-03] update | pi-zentui local customizations documented
- Documented local code fixes and UI changes to pi-zentui extension:
  - `ui.ts`: fixed `theme.fg()` hex crash → `colorize()`, changed rail `█` → `❯` (white), removed extra editor line spacing
  - `index.ts`: fixed `setWidget` factory API crash, rewrote meta widget (right-aligned, provider dim/model teal, `(thinking)` teal, org prefix stripped)
  - `zentui.json` user config: `contextNormal` → `#facc15` (lemon), `tokens` → `#fa8072` (salmon)
  - `config.ts` noted as read-only (default config + colorize helper, no changes needed)
- Pages updated: wiki/tools/pi-agent.md (added Local Customizations subsection under Status Bars), wiki/index.md (updated description)

## [2026-05-03] update | Switched statusbar from pi-statusbar to pi-zentui
- Removed pi-statusbar (git:github.com/mjakl/pi-statusbar) — uninstalled via `pi remove`
- Installed pi-zentui (npm:pi-zentui, v0.1.2) — Starship-inspired footer + Opencode-style TUI
- Pages updated: README.md (extensions table), wiki/tools/pi-agent.md (installed table + new Status Bars section), wiki/tools/pi-statusline.md (added pi-zentui as recommended option, added to frontmatter links)

## [2026-05-03] ingest | Pi status line / powerline footer
- Pages created: wiki/tools/pi-statusline.md
- Pages updated: wiki/index.md

## [2026-05-03] ingest | Pi model selection & customization
- Pages created: wiki/tools/pi-model-selection.md
- Pages updated: wiki/index.md

## [2026-05-03] update | camoufox-pi install fix: documented permissions + reload step
- Root cause: camoufox-pi cached failed launch state from before binary install; reload after fetch fixed it
- Also needs `chmod -R 755 ~/.cache/camoufox/` after fetch (binary permissions prompt)
- Pages updated: wiki/tools/pi-agent.md (install commands + install note), README.md

## [2026-05-03] update | Web fetch/search packages evaluated + installed
- Surveyed 9 pi packages for web fetch/search capabilities
- Installed: pi-web-access (v0.10.7), pi-smart-fetch (v0.2.35), @the-forge-flow/camoufox-pi (v0.2.1)
- Pages updated: wiki/tools/pi-agent.md (added Web Fetch & Search Packages section with 9-package comparison tables, capability matrix, architecture analysis, recommendations, installed package details; added to installed extensions table)

## [2026-05-03] update | pi install -l missing npm install documented
- `pi install -l` registers extension path but does not run `npm install` — likely a pi-agent bug
- Pages updated: wiki/tools/pi-agent.md (replaced shiki global install note with local npm install steps for all git-cloned extensions)

## [2026-05-03] update | pi-code-previews installed
- Source: github.com/mattleong/pi-code-previews (v0.1.14, local git clone)
- Pages updated: wiki/tools/pi-agent.md (added to installed extensions table, updated usage section)

## [2026-05-03] update | pi-code-previews evaluated
- Source: github.com/mattleong/pi-code-previews (npm: pi-code-previews, v0.1.14)
- Pages updated: wiki/tools/pi-agent.md (added Rendering & UI Extensions section; fixed pi version number)

## [2026-05-03] update | Two observational memory extensions compared
- Source: github.com/elpapi42/pi-observational-memory (v2.3.0) vs github.com/GitHubFoxy/pi-observational-memory
- Pages updated: wiki/tools/pi-agent.md (added 19-row comparison table: architecture, background observer, summary assembly, memory layers, compaction model, pruning, auto-trigger, crash recovery, temporal reasoning, commands, UI, tests, code size)

## [2026-05-03] update | pi-extension-observational-memory (Foxy) evaluated
- Source: github.com/GitHubFoxy/pi-observational-memory (npm: pi-extension-observational-memory)
- Pages updated: wiki/tools/pi-agent.md (added detailed analysis of Foxy's version, distinct from elpapi42's pi-observational-memory; comparison table vs pi-agentic-compaction)

## [2026-05-03] update | pi-agentic-compaction evaluated
- Source: github.com/laulauland/pi-agentic-compaction
- Pages updated: wiki/tools/pi-agent.md (added Compaction Landscape section with evaluated extensions table + detailed pi-agentic-compaction gains/losses analysis)

## [2026-05-03] update | pi-continue extension installed
- Source: github.com/Tiziano-AI/pi-continue (v0.6.0)
- Pages updated: wiki/tools/pi-agent.md (added pi-continue to installed extensions table, usage section with commands and Continuation Ledger docs)

## [2026-05-03] ingest | Autonomous Loop Extensions Comparison
- Source: npm registry, 15+ GitHub repos, pi.dev/packages, codex-autoresearch fork analysis
- Pages created: wiki/concepts/autonomous-loops.md (master comparison with tables, gap analysis, name candidates)
- Pages updated: wiki/index.md (added Concepts section)

## [2026-05-03] update | Pi Community Extensions & Autoloop/Goal Comparison
- Source: github.com/qualisero/awesome-pi-agent, github.com/ifiokjr/oh-pi, github.com/can1357/oh-my-pi, github.com/davebcn87/pi-autoresearch, github.com/mikeyobrien/pi-autoloop, github.com/nqh-packages/pi-goal, github.com/vurihuang/pi-goal-driven, github.com/tmustier/pi-extensions
- Pages updated: wiki/tools/pi-agent.md (added Community Distributions section + Autonomous Loop/Goal Extensions comparison)
- Pages updated: wiki/index.md

## [2026-05-03] ingest | outline-edit and realitycheck
- Source: github.com/lhl/outline-edit, github.com/lhl/realitycheck
- Pages created: wiki/tools/outline-edit.md, wiki/tools/realitycheck.md
- Pages updated: wiki/index.md

## [2026-05-03] ingest | RTK (Rust Token Killer)
- Source: github.com/rtk-ai/rtk, rtk-ai.app
- Pages created: wiki/tools/rtk.md (comprehensive overview, command reference)
- Pages updated: wiki/index.md

## [2026-05-03] update | Pi RTK Optimizer Extension
- Source: github.com/MasuRii/pi-rtk-optimizer
- Pages updated: wiki/tools/pi-agent.md (added RTK section with comparison table)

## [2026-05-03] ingest | Pi Coding Agent
- Source: pi.dev docs, github.com/badlogic/pi-mono
- Pages created: wiki/tools/pi-agent.md
- Pages updated: wiki/index.md
