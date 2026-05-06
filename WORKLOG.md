# WORKLOG

Append-only session log. Each entry records what was done, why, and what's next. Never edit or delete past entries.

---

## 2026-05-06 — Correction: pi-codex-status README commit hash

**What:** Correcting the previous WORKLOG entry's pushed commit hash.

- Previous entry says the `lhl/pi-codex-status` README update was commit `a4477ee`; the actual pushed commit is `3c3d800 docs: explain codex provider setup and status math`.

**Decisions:**
- Added a correction entry instead of editing the prior WORKLOG entry to preserve append-only history.

**Next:**
- None.

## 2026-05-06 — Documented pi-codex-status provider setup and status math

**What:** Updated `lhl/pi-codex-status` README to better explain setup and status calculation.

- Added link to Pi's `openai-codex` provider docs and explained that users can run `/login` in pi with a ChatGPT Plus/Pro account.
- Added a "How it works" section describing the private Codex usage endpoint, server-reported `used_percent`, local `leftPercent = 100 - used_percent`, reset timestamp conversion, credits display, additional limits, and opportunistic `x-codex-*` header parsing.
- Updated `CHANGELOG.md` Unreleased entries.
- Verified `npm run check` and `npm pack --dry-run`.
- Committed and pushed `lhl/pi-codex-status` commit `a4477ee docs: explain codex provider setup and status math`.

**Decisions:**
- Kept the endpoint caveat explicit and linked the official ChatGPT Codex usage settings fallback.

**Next:**
- Continue polish passes before first npm publish.

## 2026-05-06 — Added pi-codex-status agent and publish docs

**What:** Copied/adapted the project hygiene docs pattern from `~/pi-multiloop` into `~/pi-codex-usage` / `pi-codex-status`.

- Read `~/pi-multiloop/AGENTS.md`, `CLAUDE.md` symlink, and `docs/PUBLISH.md`.
- Added `AGENTS.md` tailored to `pi-codex-status` architecture, auth secrecy constraints, committed `dist/` policy, verification commands, and git discipline.
- Added `CLAUDE.md -> AGENTS.md` symlink.
- Added `docs/PUBLISH.md` with preflight, verification, review, build artifact, tag, npm publish, GitHub release, and post-publish checks.
- Added `CHANGELOG.md` scaffold with `Unreleased` and `0.1.0` sections.
- Updated `README.md` to link the publish checklist and fixed the pi install wording.
- Updated `package.json` to include `CHANGELOG.md` in npm package contents and added `status` / `pi` keywords.
- Verified `npm test` and `npm pack --dry-run`.
- Committed and pushed `lhl/pi-codex-status` commit `8a7e022 docs: add agent and publish guides`.

**Decisions:**
- Kept `dist/` committed and documented as required because direct GitHub pi installs should not require a TypeScript build step.
- Did not include `AGENTS.md` or `docs/PUBLISH.md` in npm `files`; release consumers need runtime package contents, while contributor docs remain in GitHub.

**Next:**
- Add CI before npm publishing, or at minimum follow `docs/PUBLISH.md` manually for the first registry release.

## 2026-05-06 — Published pi-codex-status

**What:** Renamed and published the Codex quota extension as a public GitHub repo.

- Renamed package metadata and primary CLI from `pi-codex-usage` to `pi-codex-status`; kept `pi-codex-usage` as a backwards-compatible bin alias.
- Added repository metadata for `https://github.com/lhl/pi-codex-status` and committed built `dist/` files so `pi install https://github.com/lhl/pi-codex-status` works without a local TypeScript build step.
- Created public GitHub repo `lhl/pi-codex-status`, pushed `main`, and added topics: `pi-package`, `pi`, `codex`, `chatgpt`, `quota`, `status`.
- Switched the local pi package install from `/home/lhl/pi-codex-usage` to `https://github.com/lhl/pi-codex-status`.
- Updated `pi-setup.sh`, `README.md`, `wiki/tools/pi-agent.md`, and `wiki/log.md` to reference the public source.
- Verified `pi-codex-status statusline` and `pi --no-session --no-context-files --no-tools -p "/status statusline"`.

**Decisions:**
- Chose `pi-codex-status` for the public name because the user-facing command is `/status` and the main use case is quota/status visibility, not general usage analytics.
- Committed `dist/` despite this being TypeScript so direct pi GitHub installs are usable; pi package installs run dependency install but should not require dev build tooling.

**Next:**
- Optionally publish to npm after a little more real-world usage.

## 2026-05-06 — Fixed delayed pi-codex-usage `/status` rendering

**What:** Fixed `/status` in the local `~/pi-codex-usage` pi extension so it renders immediately in interactive sessions.

- Root cause: the extension used `pi.sendMessage(..., { deliverAs: "nextTurn" })`, which queues the custom message for the next user prompt instead of emitting it immediately while idle.
- Changed `src/extension.ts` to call `pi.sendMessage(...)` without delivery options for UI sessions; print/no-UI mode still writes to stdout.
- Rebuilt and ran `npm test`; all tests pass.
- Verified `pi --no-session --no-context-files --no-tools -p "/status statusline"` still prints statusline output.
- Committed fix in `~/pi-codex-usage` as `50c00d8 fix: render status command immediately`.

**Decisions:**
- Kept slash-command output as a custom message rather than a notification so boxed/JSON output remains copyable and persisted in the session.

**Next:**
- Run `/reload` in any already-open pi session so it picks up the rebuilt `dist/extension.js`.

## 2026-05-06 — Added local pi-codex-usage quota status extension

**What:** Built and installed `~/pi-codex-usage`, a local CLI + pi package for ChatGPT Codex quota visibility.

- Implemented a Node/TypeScript package with `pi-codex-usage status`, `statusline`, `json`, and `raw` commands.
- Added a pi extension registering `/status` and `/codex-status`; it renders a Codex-style quota box, normalized JSON, raw backend output, or compact statusline.
- Reads existing OAuth credentials from `~/.pi/agent/auth.json` first and falls back to `~/.codex/auth.json`; refreshes tokens when needed.
- Fetches `https://chatgpt.com/backend-api/codex/usage` for idle-time 5h/weekly limit, credits, and additional named/per-model limits; also parses `x-codex-*` headers from provider responses to refresh the cache opportunistically.
- Stores self-cached status data in `~/.cache/pi-codex-usage/usage.json` for statusline use.
- Added tests for bar rendering, reset formatting, statusline formatting, and `x-codex-*` header parsing. `npm test` passes.
- Installed with `npm link` and `pi install /home/lhl/pi-codex-usage`.
- Updated `pi-setup.sh`, `README.md`, `wiki/tools/pi-agent.md`, `wiki/index.md`, and `wiki/log.md` to document the new local package.

**Decisions:**
- Used the Codex usage endpoint rather than relying only on `x-codex-*` headers/events because endpoint data is available while idle and includes credits plus additional named limits. Headers are still parsed as a low-cost cache refresh path after real provider calls.
- Registered `/status` for convenience and `/codex-status` as a collision-proof alias.
- Kept the package in `~/pi-codex-usage` rather than vendoring into devstack; `pi-setup.sh` builds/installs it if that local directory exists and skips with a message otherwise.

**Next:**
- Optionally publish `pi-codex-usage` to GitHub/npm so `pi-setup.sh` can install from a stable source instead of a local home-directory path.

## 2026-05-05 — Forked and hardened pi-vertex provider

**What:** Filtered `@ssweens/pi-vertex` from its monorepo into a standalone `lhl/pi-vertex` fork, then added tests, CI, linting, and real npm scripts.

- Compared five pi Vertex AI provider plugins: `pi-provider-vertex-anthropic`, `@twogiants/pi-anthropic-vertex`, `@carze/pi-vertex-claude`, `@isaacraja/pi-vertex-claude`, `@ssweens/pi-vertex`. `@ssweens/pi-vertex` was the clear winner on feature breadth (43 models: Gemini + Claude + Llama + 20 MaaS) but had no tests, no CI, placeholder npm scripts (`echo 'nothing to check'`), and a closed issue tracker.
- Created `https://github.com/lhl/pi-vertex` from `git filter-repo --path pi-vertex/ --path-rename pi-vertex/:` on the `lhl/pi-packages` fork, preserving 71 commits of upstream history.
- Renamed package to `@lhl/pi-vertex`, added `repository` field, updated README and CHANGELOG.
- Added Biome (`biome.json`) for linting/formatting, Vitest (`vitest.config.ts`) for testing, and a GitHub Actions CI workflow (type-check, lint, test with coverage upload).
- Replaced placeholder scripts in `package.json` with real `build` (`tsc --noEmit`), `check` (`biome check`), `test`, `test:coverage`, and `clean`.
- Added `.npmrc` with `legacy-peer-deps=true` so `npm install` works despite `@mariozechner/pi-ai` and `@mariozechner/pi-coding-agent` peer dependencies.
- Wrote 46 unit tests across 4 files:
  - `tests/utils.test.ts` — `sanitizeText`, `retainThoughtSignature`, `mapStopReason`, `calculateCost`, `convertTools`, `convertToolsForGemini`
  - `tests/auth.test.ts` — `resolveProjectId`, `resolveLocation`, `hasAdcCredentials`, `getAuthConfig`, `buildBaseUrl` (with mocked `node:fs` and `../config.js`)
  - `tests/config.test.ts` — `getConfigPath`, `loadConfig` (with mocked `node:fs` and dynamic imports to defeat module-level cache)
  - `tests/models.test.ts` — model count, required fields, ID uniqueness, publisher correctness, `getModelById`, `getModelsByEndpointType`
- Fixed minor TypeScript strictness issues in upstream source (`index.ts`, `utils.ts` implicit `any` parameters) so `tsc --noEmit` passes cleanly.
- Updated `pi-setup.sh` to install `@lhl/pi-vertex`.
- Updated `README.md` Models section with a new Custom Providers subsection documenting the Vertex provider.
- Updated `wiki/tools/pi-agent.md` Installed Extensions table to list `pi-vertex` (v1.1.5, forked from ssweens).
- Committed upstream sync + tooling + tests as a single logical unit in `lhl/pi-vertex`.

**Decisions:**
- Filtered to standalone repo rather than keeping inside `lhl/pi-packages` monorepo. Rationale: `pi-vertex` has no sibling dependencies in the monorepo, a focused repo makes CI/test iteration faster, and version tags can be repo-level instead of directory-level.
- Used Biome instead of ESLint/Prettier. Rationale: upstream `pi-leash/` in the same monorepo already uses Biome; single-tool lint+format is faster. Kept `noExplicitAny` as `warn` rather than `error` because the upstream streaming code genuinely needs `any[]` for the Google GenAI SDK response shape.
- Set `noInferrableTypes` to safe-auto-fix in Biome, which cleaned up `defaultLocation: string = "us-central1"` to `defaultLocation = "us-central1"`.
- Did NOT add integration tests for `streaming/gemini.ts` or `streaming/maas.ts`. These require mocking `@google/genai` and `@anthropic-ai/vertex-sdk`; marked as next step in `TEST_COVERAGE.md`.

**Next:**
- Add integration tests for streaming handlers (mock SDK clients, assert correct Pi event stream output).
- Add `convertToGeminiMessages` unit tests — this is the most complex untested function (~120 lines of message format conversion).
- Set up `np` or similar for automated publishing to npm when ready to release.
- Watch `ssweens/pi-packages` for upstream fixes to cherry-pick (set a monthly reminder).

---

## 2026-05-05 — pi-vertex: tests, stream lifecycle fix, maxTokens fix

**What:** Second pass on `lhl/pi-vertex` fork — added the highest-impact missing tests, fixed two runtime bugs, and improved model output capacity.

- Added 27 comprehensive unit tests for `convertToGeminiMessages` in `tests/convert-to-gemini.test.ts`. Covers: user text/images, assistant text/thinking/tool calls, tool results (single + merged consecutive), cross-provider signature stripping, `skip_thought_signature_validator` escape hatch for Gemini 3, redacted/empty thinking filtering, and a full multi-turn conversation.
- Added 3 unit tests for `streaming/index.ts` dispatch in `tests/streaming-dispatch.test.ts`. Verifies gemini vs maas routing and unknown endpoint type errors. Uses `vi.mock` on `../streaming/gemini.js` and `../streaming/maas.js` to isolate dispatch logic.
- Fixed `streamAnthropic()` in `streaming/maas.ts` to call `stream.end()` before returning. Previously it pushed `{ type: "done" }` but relied on the caller (`streamMaaS`) to end the stream — fragile if called from elsewhere or if an error happened between `done` and the outer finally. Now consistent with `streamGemini()` which already called `stream.end()`.
- Removed hardcoded `maxTokens / 2` halving in `streaming/gemini.ts` and `streaming/maas.ts`. Every model was silently capped at half its advertised output capacity (e.g., Claude Opus 4.6's 32K limit was reduced to 16K). Now uses full `model.maxTokens` unless `options.maxTokens` explicitly overrides.
- Bumped version to `1.1.6`, updated `CHANGELOG.md` and `TEST_COVERAGE.md`. Updated `wiki/tools/pi-agent.md` version string to v1.1.6.
- Pushed to `https://github.com/lhl/pi-vertex`. All 76 tests pass, `npm run build` (tsc --noEmit) passes, `npm run check` (biome) passes.

**Decisions:**
- Used `vi.mock` with factory functions returning stub streams for dispatch tests. This is cleaner than trying to mock the full Pi event stream protocol.
- For `convertToGeminiMessages` tests, built typed fixture factories (`user()`, `assistant()`, `toolResult()`) that produce full `Message` objects matching the Pi `types.ts` interface. This ensures tests catch type-level mismatches if the upstream protocol changes.
- Kept `noExplicitAny` as `warn` in Biome. The `convertToGeminiMessages` return type is genuinely `any[]` because the Gemini SDK content format is not fully typed in our code; using `unknown[]` would require casting at every call site without improving safety.

**Next:**
- Add integration tests for `streaming/gemini.ts` (mock `@google/genai` `generateContentStream` with fake `GenerateContentResponse` chunks).
- Add integration tests for `streaming/maas.ts` (mock `@anthropic-ai/vertex-sdk` `messages.stream()` with fake SSE events, and mock `streamSimpleOpenAICompletions` for the OpenAI-compatible MaaS path).
- Add `index.ts` extension registration tests (mock Pi ExtensionAPI).
- Set up `np` or `semantic-release` for automated npm publishing from GitHub Actions.
- Continue monitoring `ssweens/pi-packages` commits for upstream fixes to cherry-pick.

---

## 2026-05-05 — Compaction: switched from pi default to pi-vcc

**What:** Pi's default auto-compaction started failing with `400 status code (no body)` after one compact-and-retry on long sessions, blocking progress. Evaluated alternatives and switched to `@sting8k/pi-vcc` as the override compactor.

- Diagnosed the failure as pi core's single-pass summarizer receiving a span larger than the summarizer LLM's input window. Persists independent of `pi-continue` (which had already been removed from `~/.pi/agent/settings.json`).
- Compared five approaches: settings tuning, `pi-grounded-compaction`, `pi-agentic-compaction`, `@sting8k/pi-vcc`, `@pi-unipi/compactor`. Details in `wiki/tools/pi-agent.md` under "Why we moved off default compaction".
- Installed `@sting8k/pi-vcc` via `pi install npm:@sting8k/pi-vcc` and wrote `~/.pi/agent/pi-vcc-config.json` with `overrideDefaultCompaction: true` so it handles `/compact` and auto-threshold, not just `/pi-vcc`.
- Updated `pi-setup.sh` to drop `pi-continue`, install `pi-vcc`, and bootstrap the config file on fresh installs (preserves existing config if present).
- Updated `README.md` Context Management section with the new plugin and a pointer to the wiki evaluation.
- Updated `wiki/tools/pi-agent.md` Compaction Landscape: marked pi-continue removed, pi-vcc installed; added new detail sections for `pi-grounded-compaction` and `@pi-unipi/compactor`; added the "Why we moved off default compaction" subsection.
- Added an `AGENTS.md` rule requiring `pi-setup.sh` + `README.md` + `wiki/tools/pi-agent.md` to be updated together whenever the pi plugin stack changes.

**Decisions:**
- Picked pi-vcc over `@pi-unipi/compactor` despite the latter's XML resume snapshots and BM25 recall. Rationale: smaller surface area (0 deps vs `@pi-unipi/core` + optional `better-sqlite3` + 18-package ecosystem), ≈4× more real-world usage (3,299 vs 774 downloads/mo), visible quality-iteration history in release notes (v0.3.7 "reduce junk in compacted summaries"), recall reads raw JSONL directly (no index to stale). Migration cost to UniPi compactor later is low if we find pi-vcc lossy in practice.
- Kept `overrideDefaultCompaction: true` rather than the default `false`. The default only runs pi-vcc on explicit `/pi-vcc`; we want it to replace the failing code path, not sit alongside it.
- Committed in three logical units: `AGENTS.md` rule → wiki documentation → setup+README. Kept wiki commit separate from software/setup commit per repo discipline.

**Next:**
- Dogfood pi-vcc on real long sessions. Watch for: (1) lost behavioral preferences that would have been synthesized by an LLM summary, (2) cases where `vcc_recall` regex+OR fails to surface relevant prior context. If either becomes a pattern, reconsider `@pi-unipi/compactor` for its BM25 recall and XML resume.
- If the wiki `compaction-landscape` section grows further, consider splitting into its own page (`wiki/tools/pi-compaction.md`) and linking from `pi-agent.md`.

---

## 2026-05-03 — pi-zentui local customizations documented

**What:** Documented local code fixes and UI changes to pi-zentui in the wiki.

- Added "Local Customizations" subsection to `wiki/tools/pi-agent.md` under the Status Bars section:
  - `ui.ts`: fixed `theme.fg()` hex crash → `colorize()`, rail `█` → `❯` (white), removed extra editor line spacing
  - `index.ts`: fixed `setWidget` factory API crash, rewrote meta widget (right-aligned, provider dim/model teal, `(thinking)` teal, org prefix stripped)
  - `zentui.json`: `contextNormal` → `#facc15` (lemon), `tokens` → `#fa8072` (salmon)
  - `config.ts` noted as read-only (default config + colorize helper)
- Updated `wiki/index.md` (description for pi-agent), `wiki/log.md` (prepended entry)
- Committed: wiki: document pi-zentui local customizations

**Decisions:**
- Used tables in wiki page to organize file-level changes vs color config vs read-only files
- Separated user config from extension source edits — clear owner distinction

**Next:**
- Reload pi (`/reload`) so the color changes take effect

---

## 2026-05-03 — pi-zentui rail: `┃` → `▌` (U+258C left half block)

**What:** Switched rail from `┃` to `▌` (U+258C LEFT HALF BLOCK) — softer, more compact.

- Changed `RAIL` constant in `ui.ts`: `┃` (U+2503) → `▌` (U+258C)
- Committed: wiki: update pi-zentui rail to ▌ (U+258C left half block)

**Next:**
- Reload pi (`/reload`) to apply all pending changes

---

## 2026-05-03 — pi-zentui rail: unified to ┃ (U+2503) via RAIL constant

**What:** Unified rail character across editor and user message, switched from `❯` to `┃`.

- Added `const RAIL = "┃"` (U+2503 HEAVY VERTICAL LINE) at top of `ui.ts` — single source of truth
- Editor rail in `PolishedEditor.render`: `❯` → `RAIL`
- User message rail in `patchUserMessageComponent`: already `┃` but now also uses `RAIL` constant
- Wiki updated: `wiki/tools/pi-agent.md` (ui.ts row), `wiki/log.md` (new entry prepended)
- Committed: wiki: update pi-zentui rail character to ┃ (U+2503)

**Next:**
- Reload pi (`/reload`) to apply rail + color changes

---

## 2026-05-03 — pi-zentui color refinements

**What:** Two color refinements to match muted UI teal and add pale lavender to working folder.

- **Model name teal:** Changed hardcoded bright teal `#5eead4` → `syntaxType` theme token in `index.ts` meta widget (both model name and `(thinking)` suffix)
  - The `syntaxType` token is the muted teal used throughout the rest of the pi UI
- **Working folder:** Changed `cwdText` in `zentui.json` from `syntaxOperator` → `#c9b8e8` (pale lavender)
- Wiki updated: `wiki/tools/pi-agent.md` (index.ts row, cwdText row added), `wiki/log.md` (new entry prepended)
- Committed: wiki: update pi-zentui color refinements

**Note:** `index.ts` and `zentui.json` are outside the devstack repo — changes made directly to `~/.pi/agent/` paths. Need `/reload` inside pi to pick up the changes.

**Next:**
- Reload pi (`/reload`) so the color changes take effect

---

## 2026-05-03 — Web fetch/search package survey + installation

**What:** Evaluated 9 pi packages for web fetch/search, installed 3, documented everything.

- Surveyed all 9 web fetch/search packages on pi.dev + npm: @pi-lab/webfetch, pi-fetch, @ogulcancelik/pi-web-browse, @demigodmode/pi-web-agent, @the-forge-flow/camoufox-pi, @counterposition/pi-web-search, pi-web-access, @apmantza/greedysearch-pi, pi-smart-fetch
- Installed pi-web-access (v0.10.7) — primary, 418 stars, videos/YT/GitHub/PDF/zero-config
- Installed pi-smart-fetch (v0.2.35) — TLS-fingerprinted fetches, Defuddle site extractors
- Installed @the-forge-flow/camoufox-pi (v0.2.1) — extreme stealth for anti-bot-protected pages
- Added comprehensive comparison to wiki/tools/pi-agent.md: overview table, capability matrix, architecture analysis, recommendations, installed package details
- Updated README.md installed components table
- Updated wiki/log.md, wiki frontmatter links

**Decisions:**
- pi-web-access is the default web tool — most features, most polish, largest community
- pi-smart-fetch is the lightweight anti-bot layer (TLS fingerprinting, no headless browser)
- camoufox-pi is the nuclear option for Cloudflare/DataDome/etc — heavy but effective
- Skipped pi-fetch (LLM-generated, too basic), @pi-lab/webfetch (no repo/community)

**Next:**
- Smoke test all three packages on real pages ✅ — all three operational after camoufox reload fix
- Test pi-web-access YouTube understanding and GitHub cloning

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

## 2026-05-03 — README updated with installed components table

**What:** Added Installed Components section to README.md.

- Pi Extensions table: 5 entries with install method, version, purpose
- Standalone Tools table: 4 entries (3 installed, 1 pending)
- Cross-reference to wiki/tools/ for detailed docs

**Decisions:**
- Single source of truth: wiki pages have full details; README has quick-reference tables

**Next:**
- Test pi-continue mid-run guard in a long continuous session

## 2026-05-04 — pi-backtask review

**What:** Reviewed the local `pi-backtask/` extension implementation for policy, RPC, result-flow, and runtime issues.

- Inspected `pi-backtask/pi-backtask.ts`, `README.md`, `HANDOFF.md`, commit history, and local `@tintinweb/pi-tasks` RPC behavior.
- Ran gob smoke checks for JSON status/stop metadata using temporary jobs and removed them afterward.
- Attempted the documented TypeScript check; bare `npx tsc` resolves to the placeholder package in this repo, and `npx -p typescript tsc` requires missing peer/node type dependencies.
- Identified issues to report: RPC `confirm` still spawns, stopped RPC agents are reported as failures, session JSONL parsing misses Pi v3 `message` envelopes, reactive-output debounce can emit empty alerts, policy values fail open, shell/background policy bypasses exist, and gob-backed tasks are not reattached after pi restart.

**Decisions:**
- Treated this as a review-only pass: no changes were made inside `pi-backtask/`.
- Left unrelated untracked file `writing/202604-supply-chain-security.md` untouched.

**Next:**
- Fix high-priority policy/RPC/result-flow issues in `pi-backtask.ts`, then add a reproducible TypeScript check with explicit dev dependencies.

## 2026-05-04 — pi-backtask caveats and bug fixes

**What:** Documented pi-backtask design/security caveats and fixed the review bugs that were practical in the single-file extension.

- Updated `pi-backtask/pi-backtask.ts`:
  - Policy settings now merge global then project overrides and fail closed on invalid explicit policy/tool values.
  - RPC `confirm` policy now hard-gates pi-tasks spawns instead of notifying and continuing.
  - RPC stop now marks the background task as killed, emits the `status: "stopped"` lifecycle path, and avoids poller misclassification as failed.
  - Session result parsing now handles Pi v3 JSONL `message` envelopes as well as the older top-level role/content shape.
  - Reactive output debounce now batches actual pending output instead of sending empty alerts, checks output before last-line de-dupe, resets regex state, and clears timers on completion/shutdown.
  - Slash-command parsing now handles quoted leading arguments for `/bg run` and `/bg agent` examples.
  - RPC spawn startup failures no longer return success IDs, and fast RPC starts register the subagent mapping before polling begins.
  - Bash background-pattern interception now remains active when shell policy is denied.
- Updated `pi-backtask/README.md` and `pi-backtask/HANDOFF.md` with design/security caveats: policy is not a sandbox, shell access can bypass agent gates, interception is best-effort, gob process survival is stronger than extension reattachment, injected output is untrusted, and agents share the working tree.
- Verified `pi-backtask.ts` with esbuild bundling and `git diff --check`; gob temporary job list is clean.
- Committed in submodule: `0e3fcea fix: harden backtask policy and rpc flow`.

**Decisions:**
- Did not attempt to sandbox arbitrary shell access or implement gob-job reattachment; these are now documented caveats rather than hidden guarantees.
- Kept pi-tasks `confirm` as a rejection/manual-approval gate instead of adding an interactive approval protocol.
- Left unrelated untracked file `writing/202604-supply-chain-security.md` untouched.

**Next:**
- If stronger guarantees are needed later, add real shell command classification or run agents in disposable worktrees/containers.
- Add a small package/tsconfig or test harness if pi-backtask should have fully reproducible local type checks.

## 2026-05-04 — pi-backtask reviewer handoff refreshed

**What:** Updated `pi-backtask/HANDOFF.md` so it is suitable to send to a colleague after the bugfix pass.

- Refreshed metadata with current line count and latest bugfix commit reference.
- Added a "Latest Bugfix Pass" section summarizing policy, RPC stop, session parsing, reactive output, slash parsing, startup-race, and bash interception fixes.
- Updated caveats and protocol wording to avoid overclaiming sandbox behavior or automated test coverage.
- Committed in submodule: `eaf4252 docs: refresh reviewer handoff`.

**Decisions:**
- Kept the bugfix commit `0e3fcea` called out explicitly even though the handoff docs commit is newer, so reviewers can separate implementation from documentation changes.

**Next:**
- Send `pi-backtask/HANDOFF.md` to reviewers alongside the branch/commit range.
