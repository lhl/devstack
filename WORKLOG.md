# WORKLOG

Append-only session log. Each entry records what was done, why, and what's next. Never edit or delete past entries.

---

## 2026-05-03 — Initial repo scaffolding

**What:** Set up devstack as a hybrid LLM Wiki + software toolkit repo.

- Researched LLM Wiki ecosystem (docs/RESEARCH-llmwiki.md)
- Evaluated projects against our needs; decided to adopt qmd + the Karpathy pattern directly, skip frameworks
- Installed qmd 2.1.0 globally (`npm install -g @tobilu/qmd`)
- Downloaded Karpathy's original gist and rohitg00's v2 spec to sources/gists/
- Scaffolded directory structure: inbox/, sources/, wiki/, docs/, projects/, tools/
- Wrote README.md with repo structure, directory roles, wiki schema, and qmd setup
- Wrote AGENTS.md (Medium weight) following shisa-ai house style, with commit-first discipline as non-negotiable #1
- Created CLAUDE.md → AGENTS.md symlink
- Created WORKLOG.md (this file)

**Decisions:**
- No `reference/` dir — external specs go into `sources/` alongside everything else
- `docs/` is for project working docs (dev notes, research), distinct from `wiki/` (agent-compiled knowledge)
- Wiki schema lives in README.md, not duplicated in AGENTS.md
- Skipping v2 features (confidence scoring, knowledge graph, auto-ingest hooks) until wiki has 30-50+ pages

**Next:**
- First wiki ingest (the two gists + RESEARCH doc are candidates)
- Wire up qmd collections for wiki/ and sources/
- Set up pi-agent and RTK as submodules in projects/

## 2026-05-03 — Pi agent research and first wiki ingest

**What:** Evaluated pi coding agent (pi.dev) and created first wiki page.

- Reviewed shisa-ai/AGENTS.MD repo patterns; pulled research hygiene, writing discipline, and submodule conventions into our AGENTS.md
- Added WORKLOG.md as append-only session log, integrated into AGENTS.md workflow
- Installed pi coding agent v0.71.1 (`npm install -g @mariozechner/pi-coding-agent`)
- Researched pi architecture, extension system, customization layers from repo docs and pi.dev
- Created wiki/tools/pi-agent.md — first wiki page, includes comparison with Claude Code
- Initialized wiki/index.md and wiki/log.md

**Decisions:**
- Pi agent goal: evaluate as Claude Code alternative + build extensions for it
- Pulled three patterns from existing research repos into AGENTS.md: research/claim hygiene (agentic-memory), writing discipline (agentic-security), submodule conventions (agentic-memory)
- Non-negotiables section added to top of AGENTS.md with commit discipline as #1

**Next:**
- Deeper pi evaluation: try it on real tasks, test extension development experience
- Investigate pi's package ecosystem for MCP and sub-agent extensions

## 2026-05-03 — RTK extension evaluation and install

**What:** Researched and installed RTK optimizer extension for pi.

- Cloned and reviewed three RTK options: sherif-fanous/pi-rtk (cmd only), mcowger/pi-rtk (output only), MasuRii/pi-rtk-optimizer (full stack)
- Selected pi-rtk-optimizer as most feature-complete: command rewriting + output compaction + TUI settings
- Installed globally via `pi install npm:pi-rtk-optimizer` (added to settings.json)
- Documented RTK extension in wiki/tools/pi-agent.md with installation, usage, config options
- Updated wiki/log.md

**Decisions:**
- MasuRii/pi-rtk-optimizer recommended: v0.7.0, best active dev, clean delegation to rtk binary
- mcowger alternative only if output-only needed and older pi version
- sherif-fanous only if minimal (60 LOC) desired

**Next:**
- Install rtk binary for command rewriting support
- Test pi with RTK on real tasks, measure token savings
- Explore other pi extensions (MCP, sub-agent)

## 2026-05-03 — RTK wiki page created

**What:** Created comprehensive wiki page for rtk-ai/rtk core tool.

- Cloned and reviewed github.com/rtk-ai/rtk (v0.38.0)
- Created wiki/tools/rtk.md with: overview, installation options, token savings table, command reference by category, auto-rewrite hook docs, supported AI tools matrix, Windows support, configuration
- Updated wiki/index.md with rtk link
- Added wikilink from pi-agent page to rtk page
- Updated wiki/log.md

**Decisions:**
- Grouped commands by category (files, git, tests, build/lint, containers, AWS, analytics)
- Included relation to pi extensions for context

**Next:**
- Update WORKLOG after current session

## 2026-05-03 — Wiki pages for outline-edit and realitycheck

**What:** Created wiki pages for lhl's two tools.

- Researched and documented github.com/lhl/outline-edit (v0.2.1): CLI for Outline KB with local markdown cache, zero stdlib dependencies, "why not MCP" analysis
- Researched and documented github.com/lhl/realitycheck (v0.3.3): framework for rigorous claim/source/prediction tracking, LanceDB + embeddings, Claude Code/Codex/Amp/OpenCode integrations
- Created wiki/tools/outline-edit.md and wiki/tools/realitycheck.md
- Updated wiki/index.md and wiki/log.md

**Decisions:**
- Created "why not MCP" section to capture the rationale for outline-edit
- Mapped realitycheck CLI commands and agent integrations

**Next:**
- Commit after session
- Wire up qmd collections
- Set up pi-agent and RTK in projects/

## 2026-05-03 — Autonomous loop research + pi-multiloop extension

**What:** Comprehensive research of pi autonomous loop ecosystem, designed and implemented pi-multiloop extension.

- Surveyed 15+ autonomous loop extensions (pi-autoresearch, pi-boomerang, pi-supervisor, pi-teams, PiSwarm, pi-ralph, etc.)
- Created wiki/concepts/autonomous-loops.md with master comparison tables, gap analysis, convergence detection methods
- Analyzed our codex-autoresearch fork's multi-loop architecture (path-based namespacing, LANE+RUN_TAG, cross-process locking)
- Identified key gap: no pi extension supports multi-loop-per-worktree with lane isolation
- Designed and implemented pi-multiloop (github.com/lhl/pi-multiloop, npm: pi-multiloop)
  - 7 modules: lanes.ts, state.ts, metrics.ts, loop.ts, modes.ts, index.ts, ui.ts
  - 4 modes: optimize (edit→measure→keep/revert), punchlist, research, dev
  - Lane-based state isolation with JSONL history + JSON snapshots
  - MAD confidence scoring for noisy benchmarks
  - Escalation ladder (3→refine, 5→pivot, 2 pivots→stop)
  - Pi extension API integration (events, tools, commands, TUI status)
  - 43 passing tests (vitest), clean TypeScript compilation
- Added as devstack submodule at projects/pi-multiloop
- Originally named pi-autoloop, renamed to pi-multiloop (pi-autoloop taken by mikeyobrien/pi-autoloop)

**Decisions:**
- pi-multiloop not pi-autoloop: github.com/mikeyobrien/pi-autoloop already exists (different project)
- Pi packages as peerDependencies only: too large a dependency tree for devDeps, use global install for type-checking
- JSONL over TSV for results: structured, easier to parse in TypeScript
- No cross-process locking (unlike codex-autoresearch): pi is single-process
- Complementary with pi-boomerang (context compression) and pi-supervisor (goal enforcement), not built-in

**Next:**
- Test pi-multiloop with `pi install file:.` on a real project
- Publish v0.1.0 to npm when ready
- Update wiki/concepts/autonomous-loops.md to reference pi-multiloop
- Wire up qmd collections for wiki/ and sources/

## 2026-05-03 — pi-continue installed

**What:** Installed pi-continue extension for mid-run context compaction.

- Researched 8 pi compaction extensions (pi-boomerang, pi-vcc, pi-observational-memory, pi-custom-compaction, pi-model-aware-compaction, pi-context-cap, pi-continue, pi-rtk-optimizer)
- Confirmed pi has built-in auto-compaction (triggers at `contextWindow - reserveTokens`, default reserveTokens=16384) — works between turns
- Identified pi-continue's unique value: handles mid-run overflow (long tool-heavy sequences that exceed context before reaching turn boundaries)
- Installed pi-continue v0.6.0 from local git clone (npm 11 peer-dep resolution issue with `@mariozechner/pi-coding-agent >=0.72.0` despite 0.72.1 being installed)
  - Location: `.pi/git/pi-continue` (project-local)
  - `pi install -l .pi/git/pi-continue` — no npm deps, pure TS extension
- Updated wiki/tools/pi-agent.md: added to installed extensions table + usage section (commands, Continuation Ledger, optional file sync)
- Updated wiki/log.md

**Decisions:**
- Local git clone over npm install due to npm 11 regression with peer deps
- Complements pi-boomerang (context collapse between iterations) and built-in compaction (between turns) — pi-continue fills the mid-run gap

**Next:**
- Test pi-continue mid-run guard in a long continuous session

## 2026-05-03 — pi-agentic-compaction evaluated

**What:** Evaluated pi-agentic-compaction extension (agentic-loop compaction).

- Reviewed [laulauland/pi-agentic-compaction](https://github.com/laulauland/pi-agentic-compaction) source and README
- Compared against pi's default compaction: agentic exploration loop (just-bash virtual filesystem + jq/grep tools) vs single-pass summarization
- Documented gains (cheaper for long sessions, better file accuracy, steerable, 50k tool result limit vs 2k) and losses (multiple API calls, latency, small-model blind spots, no cumulative file tracking, no split-turn handling, raw JSON serialization)
- Added to wiki/tools/pi-agent.md: new "Compaction Landscape" section with evaluated extensions table + detailed pi-agentic-compaction analysis
- Decision: not installing for now — pi-continue + built-in compaction cover current needs; revisit when sessions routinely exceed 100k+ tokens
- Updated wiki/log.md

**Decisions:**
- Not installing: riskier than default for general use, cheap-default-model blind spots, no split-turn handling
- Worth revisiting later for very long sessions where single-pass costs matter

**Next:**
- Test pi-continue mid-run guard in a long continuous session

## 2026-05-03 — pi-extension-observational-memory (Foxy) evaluated

**What:** Evaluated GitHubFoxy's observational memory extension.

- Reviewed [GitHubFoxy/pi-observational-memory](https://github.com/GitHubFoxy/pi-observational-memory) source (index.ts, overlay.ts, DESIGN.md) and README
- npm: `pi-extension-observational-memory` — distinct from elpapi42's `pi-observational-memory` (v2.3.0)
- Key finding: it DOES override default compaction (returns custom `compaction` from `session_before_compact`), but falls back gracefully on failure
- Architecture: single-pass via session model, priority-tagged observation format (🔴/🟡/🟢), reflector GC (dedup + cap-prune), two-threshold flow (observer 30k + reflector 40k + retain 8k), cumulative file tags, buffered auto-mode with status overlay
- Compared vs default compaction (gains: better memory format, reflector GC, buffered auto-mode; losses: incompatible format, expensive session model, lossy pruning) and vs pi-agentic-compaction (table: exploration method, model, cost, latency, format, file tracking, risk)
- Added to wiki/tools/pi-agent.md: updated evaluated extensions table + detailed analysis with comparison table
- Decision: not installing — pi-continue handles mid-run, default format is fine, session-model cost is a blocker for routine compaction
- Updated wiki/log.md

**Decisions:**
- Not installing: uses expensive session model, different summary format from default, reflector pruning is lossy
- Well-designed but better suited for teams that want structured observation logs, not general-purpose compaction

## 2026-05-03 — Two observational memory extensions compared

**What:** Compared elpapi42/pi-observational-memory (v2.3.0) vs GitHubFoxy/pi-extension-observational-memory.

- Reviewed elpapi42's source in depth (src/observer.ts, src/compaction.ts, src/prompts.ts, types, config)
- elpapi42 architecture: background observer (incremental, ~1k chunk agentic loops) → mechanical summary assembly (NO LLM rewrite — eliminates summary-of-a-summary) → reflector+pruner (multi-pass id-based drops, up to 5 passes)
- Foxy architecture: single-pass LLM summarization → dedup + cap-prune, uses session model
- Key differences: background observer vs single-pass, mechanical concatenation vs LLM-generated summaries, dedicated compaction model vs session model, reflection layer vs emoji-priority-only, crash recovery (silent tree entries) vs in-memory only, test suite vs none
- Added comparison table (19 rows) to wiki/tools/pi-agent.md Compaction Landscape section
- Decision: elpapi42's is technically stronger (mechanical assembly, dedicated model, tests); Foxy's has better UX (overlay, picker). Neither installed.
- Updated WORKLOG.md and wiki/log.md

**Decisions:**
- elpapi42's version is the more mature implementation — follows Mastra's observational memory pattern properly
- Neither installed: elpapi42's would be the choice if we wanted observational memory, but default covers our needs

## 2026-05-03 — pi-code-previews evaluated

**What:** Evaluated pi-code-previews (Shiki syntax-highlighted TUI rendering for pi tool calls).

- Reviewed README, index.ts — purely cosmetic, no tool execution changes
- Features: syntax highlighting via Shiki, edit/write diffs with word emphasis, grep file grouping, find/ls path compacting with icons, bash/secret warnings, TUI settings
- 15 test files, well-structured codebase, auto-skips conflicting extensions
- Added to wiki/tools/pi-agent.md: new Rendering & UI Extensions section
- Fixed pi version number (0.71.1 → 0.72.1 as actually installed)

**Decisions:**
- Low-risk, high-value: would make tool output much more scannable
- Worth installing — no downside

## 2026-05-03 — pi-code-previews installed

**What:** Installed pi-code-previews v0.1.14 for syntax-highlighted tool output.

- Installed from local git clone at `.pi/git/pi-code-previews` (npm 11 peer-dep issue)
- Registered in `.pi/settings.json` as `"git/pi-code-previews"`
- Updated wiki/tools/pi-agent.md: added to installed extensions table, updated Rendering & UI Extensions section with usage commands
- Updated wiki/log.md

**Next:**
- Test /code-preview-settings and /code-preview-health in a pi session

**Next:**
- Test pi-continue mid-run guard in a long continuous session
