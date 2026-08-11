# Wiki Log

## [2026-08-11] update | camoufox — Python vs Node cache-layout conflict fixed and documented
- Source: local investigation and repair of the `tff-search_web` / `tff-fetch_url` `browser_launch_failed` error; upstream context from https://github.com/daijro/camoufox, https://github.com/apify/camoufox-js, https://github.com/MonsieurBarti/camoufox-pi.
- Pages created: `wiki/tools/camoufox.md`.
- Pages updated: `wiki/index.md`, `wiki/tools/pi-agent.md` (camoufox-pi row cross-links the new page).
- Summary: diagnosed the root cause — `pi-setup.sh` installs the **Python** `camoufox` pip package and fetches via the Python CLI, which writes the 0.5.x **multiversion** layout (`browsers/official/<ver>-<sha8>/` + `config.json`, no top-level `version.json`) into `~/.cache/camoufox`; the `camoufox-pi` tff tools run on the **Node** `camoufox-js` port, which requires the **flat** layout + `version.json`, and throws `Version information not found at ~/.cache/camoufox/version.json` when it is absent. Fixed by reusing the already-downloaded `152.0.4-beta.28` browser (moved to flat layout, wrote `version.json`, chmod 755), removed Python metadata + redundant `browsers/` tree (~1.3 GB freed), uninstalled the pip package and its 66 MB orphaned mmdb, then verified a Node launch through the exact extension path (`Example Domain`).
- Verification: Node reports `installed version: 152.0.4-beta.28`; smoke test via `camoufox-js launchOptions` + `playwright-core firefox.launch` fetched `https://example.com` successfully. Page records all four fix options and the prevention/detection commands.

## [2026-07-29] update | Codex TRACE-log suppression workaround
- Source: local inspection and mitigation of `~/.codex/logs_2.sqlite`, with upstream context from https://github.com/openai/codex/issues/29674.
- Pages created: `wiki/tools/codex.md`.
- Pages updated: `wiki/index.md`.
- Summary: recorded the local `codex-cli 0.144.0` database measurements, the pre-change backup, and installation of a `codex_suppress_trace_logs` SQLite trigger that ignores only `TRACE` inserts while preserving higher-level diagnostics.
- Verification: a rolled-back transaction confirmed a TRACE test insert was ignored, an INFO insert was accepted, and no test rows remained; the page includes inspection and removal commands plus migration and diagnostics caveats.

## [2026-07-28] ingest | Cross-model planner–executor workflows
- Source: `sources/articles/reddit-chatgpt-codex-second-brain-1v80xhn.html`, archived from https://www.reddit.com/r/ChatGPT/comments/1v80xhn/am_i_the_last_person_to_realize_chatgpt_can/ (SHA-256 `832590bc4676e0b6c5465e284af809cba9f6b84f06cbf037286e59bb5cce54cc`).
- Pages created: `wiki/practices/cross-model-planner-executor-workflows.md`.
- Pages updated: `wiki/concepts/autonomous-loops.md`, `wiki/index.md`.
- Summary: generalized the post's ChatGPT-planner/Codex-executor pattern into manual and harness-driven workflows for read-only planning, scratchpads, specialists, independent portfolios, adversarial review, computer use, and durable issue/Markdown/PR handoffs.
- Verification note: official OpenAI documentation confirms repository search and shared-link behavior but documents the built-in ChatGPT GitHub app as read-only; the Reddit author's issue-writing feature, separate quotas, model labels, and results remain attributed community reports. The practice page adds state-pinning, least-privilege, prompt-injection, privacy, and mechanical-verification guardrails.

## [2026-07-28] ingest | Prompting examples — GPT 5.6 Sol Ultra proof-search prompt
- Source: `sources/papers/openai-2026-cycle-double-cover-prompt.pdf`, archived from https://cdn.openai.com/pdf/04d1d1e4-bc75-476a-97cf-49055cd98d31/cdc_prompt.pdf (SHA-256 `0e48deee28caba82ee5b4191d4c5c6ec4d62e5d27890fa7f0d2c8868f8b758f3`).
- Pages created: `wiki/practices/prompting-examples.md`.
- Pages updated: `wiki/index.md`.
- Summary: extracted the full prompt with only PDF line wrapping/page furniture normalized, then recorded its reusable multi-agent patterns: exact acceptance boundaries, explicit non-solutions, independent approach portfolios, family registry and blocking policy, concrete worker artifacts, domain-specific adversarial audits, root-agent synthesis, and stopping rules.
- Verification note: the model label and claimed proof outcome are attributed to the OpenAI PDF and were not independently verified; the page flags the forced-success premise, restricted reality checking, runtime floor, and high concurrency as non-portable or risk-bearing instructions.

## [2026-07-18] update | devstack — removed RTK completely
- Source: user decision that RTK is unused, plus local setup and installation audit.
- Removed the RTK binary installer and version check from `pi-setup.sh`; added the retired Pi optimizer package to manifest legacy removals so stale machines also converge without `--prune`.
- Removed current RTK references from repo guidance and Pi documentation, deleted the dedicated `wiki/tools/rtk.md` page, and rewrote `wiki/tools/pruning-and-compaction.md` around the remaining conversation-pruning decision; append-only historical records remain unchanged.
- Updated pages: `wiki/tools/pi-agent.md`, `wiki/tools/pruning-and-compaction.md`, `wiki/practices/ml-workflow-tips.md`, `wiki/index.md`.
- Updated repo docs/config: `AGENTS.md`, `README.md`, `docs/WIKI.md`, `pi-setup.sh`, `pi-packages.json`.

## [2026-07-18] update | pi-agent — retired pi-context-prune
- Source: user operational report of frequent extension errors plus local canonical-stack inspection.
- Removed `npm:pi-context-prune` from the canonical package list and added it to legacy removals so package sync uninstalls it even without a full `--prune` reconciliation.
- Reason: frequent runtime errors outweighed the context-saving benefit; no replacement pruning extension was installed.
- Removed the setup-time config bootstrap and current-stack references from `README.md`, `docs/TODO.md`, and the Pi/background-task wiki guidance while preserving dated research and append-only history.
- Pages updated: `wiki/tools/pi-agent.md`, `wiki/tools/pi-background-task-plugins.md`, `wiki/tools/pruning-and-compaction.md`, `wiki/index.md`.
- Repo docs/config updated: `README.md`, `docs/TODO.md`, `pi-setup.sh`, `pi-packages.json`.

## [2026-07-03] update | pi-agent — restored pi-multicodex with conditional provider registration
- Restored `https://github.com/lhl/pi-multicodex` to the canonical `pi-packages.json` stack after pushing `lhl/pi-multicodex` commit `6b12d92`.
- Fix: MultiCodex now loads commands but only registers its `openai-codex` provider override when a usable managed/imported Codex account exists; stale `needsReauth` accounts no longer break Pi startup.
- Operational model: keep plain Pi on pool-backed `codex/gpt-5.5`; use MultiCodex `openai-codex` only for personal ChatGPT Codex OAuth accounts.
- Pages updated: `wiki/tools/pi-agent.md`, `wiki/index.md`.
- Repo docs updated: `README.md`, `pi-setup.sh`, `pi-packages.json`.

## [2026-07-03] update | pi-agent — retired pi-multicodex under codex-pool
- Removed `https://github.com/lhl/pi-multicodex` from the canonical `pi-packages.json` stack and added it to legacy/prune removals.
- Reason: codex-pool is now the Codex account-rotation layer through `~/.pi/agent/models.json`; local MultiCodex accounts were all flagged `needsReauth`, so the extension registered `openai-codex` models without usable auth and broke Pi startup.
- Pages updated: `wiki/tools/pi-agent.md`, `wiki/index.md`.
- Repo docs updated: `README.md`, `pi-setup.sh`, `pi-packages.json`.

## [2026-06-29] update | pi-agent — disabled pi-web-access on Pi 0.79.7
- Removed `npm:pi-web-access` from the canonical `pi-packages.json` stack and added it to legacy/prune removals.
- Root cause: `pi-web-access@0.13.0` imports `@earendil-works/pi-ai/compat`, but Pi 0.79.7's `@earendil-works/pi-ai` package no longer exports that path.
- Pages updated: `wiki/tools/pi-agent.md`, `wiki/index.md`.
- Repo docs updated: `README.md`, `pi-setup.sh`, `pi-packages.json`.

## [2026-06-26] update | supply-chain-security — config-file rolling age gates
- Source: live setup on the `devstack` machine (bash + miniforge + nvm); authoritative syntax/unit checks against the uv resolution docs, npm config docs, pip `install --help`, and Matteo Collina's cross-package-manager min-release-age gist.
- Pages updated: `wiki/practices/supply-chain-security.md`, `wiki/index.md`.
- Software added (separate commit): `pkg-security-setup.sh`.
- Summary: documented the new cross-shell config-file approach (one static relative-duration line per tool → rolling 1-day cooldown, no wrappers/cron) for npm (`min-release-age`, days), pnpm v11 (`minimumReleaseAge`, minutes, YAML `config.yaml`), uv (`exclude-newer`, ISO `P1D`), and pip 26.1+ (`uploaded-prior-to`, ISO `P1D`). Added a per-ecosystem unit-gotcha table.
- Correction: fixed a unit bug on the page — npm `min-release-age` is **days**, not minutes; the old `1440` value would have meant a ~4-year gate. Also updated the now-outdated claims that pip/uv age gates require a dynamically computed absolute date (both accept relative durations now).
- Verification: all four gates applied and confirmed live on-machine (npm 11.16.0=1d, pnpm 11.9.0=1440min, uv 0.11.24=P1D, pip 26.1.2=P1D); uv/pip dry-run resolves succeed honoring the config.

## [2026-06-17] ingest | AI slop concept + LLM prose techniques
- Source: `sources/conversations/2026-06-17-ai-slop-template-why-and-prose-techniques.md` (pasted research discussion) plus the shisa-v3 `antislop/` research notes.
- Pages created: `wiki/concepts/ai-slop.md`, `wiki/practices/llm-prose-techniques.md`.
- Pages updated: `wiki/index.md`.
- Related doc: `docs/ANTI-SLOP-INSTRUCTIONS.md` (the enforceable deslop checklist; cross-linked, not a wiki page).
- Summary: recorded the slop template/taxonomy, the (author-attributed, unverified) theory for why post-training converges on slop, an empirical-support section citing the alignment-narrows-diversity papers, the detection/forensics landscape from the shisa-v3 notes, and the unslop/enslop training technique. Separate practices page captures the generation-side techniques with verification status flagged.
- Verification: arXiv citations confirmed live (2509.19163, 2503.01659, 2506.17871, 2505.00047, 2503.17126, 2602.16162, 2507.20956); corrected two attributions in the shisa notes (Shaib affiliation; three authors on the fingerprints paper). Why-it-happens and social sections marked as theory; techniques marked not independently reproduced.

## [2026-06-17] update | pi-model-selection — model catalog loading architecture
- Source: investigation of missing `zai-org/GLM-5.2` from HuggingFace provider in pi's model picker.
- Pages updated: `wiki/tools/pi-model-selection.md`.
- Config updated: `~/.pi/agent/models.json` — added `zai-org/GLM-5.2` under `huggingface` provider.
- Summary: documented how pi loads its model catalog (static `models.generated.js` in `@earendil-works/pi-ai`, merged with user `models.json`), the catalog-lag pattern for new HF releases, and added GLM-5.2 to local config since it was missing from the built-in HF provider section.
- Verification: `~/.pi/agent/models.json` valid JSON; wiki page reads correctly.

## [2026-06-14] update | pi-agent — canonical vanillagreen background tasks
- Source: follow-up decision after the isolated and full-stack tests recorded in `sources/conversations/pi-background-task-plugin-smoke-test-2026-06-14.md` and `sources/conversations/pi-background-task-plugin-fullstack-test-2026-06-14.md`.
- Pages updated: `wiki/tools/pi-background-task-plugins.md`, `wiki/tools/pi-agent.md`.
- Repo docs updated: `README.md`, `docs/TODO.md`, `pi-setup.sh`, `pi-packages.json`.
- Summary: promoted `@vanillagreen/pi-background-tasks@1.6.0` into the canonical Pi package manifest, documented it under Automation & Workflow, and retained the operational caveat that the default epyc/Qwen model had poor post-wake tool-loop behavior while Haiku 4.5 handled the flow cleanly.
- Verification note: no separate config bootstrap is required; defaults are acceptable and optional tuning lives in `/extensions:settings`. The package is pinned to `1.6.0` because local npm age-gates newer `1.6.1`.

## [2026-06-14] update | pi-agent — vanillagreen full-stack background-task test
- Source: `sources/conversations/pi-background-task-plugin-fullstack-test-2026-06-14.md` from local `pi -e npm:@vanillagreen/pi-background-tasks@1.6.0` tests in the devstack repo with the canonical extension stack active.
- Pages updated: `wiki/tools/pi-background-task-plugins.md`, `wiki/tools/pi-agent.md`.
- Summary: recorded that Haiku 4.5 successfully used `bg_task` with `notifyOnOutput` / `notifyPattern`, produced both output and exit wake events, and confirmed LLM `bash` auto-backgrounding for `tail -f`; also recorded that the current default epyc/Qwen model spawned and received wakes but then showed poor tool-loop behavior.
- Verification note: no persistent package-stack change was made; `@vanillagreen/pi-background-tasks` remains out of `pi-packages.json` pending model-policy, TUI, restart-replay, and long-session context-prune checks.

## [2026-06-14] update | pi-agent — vanillagreen background-task smoke test
- Source: `sources/conversations/pi-background-task-plugin-smoke-test-2026-06-14.md` from an isolated local RPC-mode smoke test using temporary Pi state.
- Pages updated: `wiki/tools/pi-background-task-plugins.md`, `wiki/tools/pi-agent.md`.
- Summary: recorded that `@vanillagreen/pi-background-tasks@1.6.0` loaded via `pi -e`, registered `/bg` commands, spawned a background command, delivered a completion exit event, and supported `/bg:list`, `/bg log`, and `/bg:clear`; kept it non-canonical pending LLM-tool notifyPattern, bash auto-background, TUI, restart replay, and `pi-context-prune` full-stack tests.
- Verification note: the completion wake attempted to trigger a model turn in the temp harness, but that turn failed because the temp/default model identifier was invalid; wake event delivery itself was observed.

## [2026-06-14] update | pi-agent — background task plugin evaluation
- Source: `sources/conversations/pi-background-task-plugins-2026-06-14.md` from recent in-session package comparison plus local npm metadata checks.
- Pages created: `wiki/tools/pi-background-task-plugins.md`.
- Pages updated: `wiki/tools/pi-agent.md`, `wiki/index.md`.
- Summary: recorded the current recommendation to test `@vanillagreen/pi-background-tasks` first, keep `@richardgill/pi-tmux-bash` as the substrate alternative, treat `@trevonistrevon/pi-loop` as mostly redundant with existing scheduling/autoloop plugins, and preserve `pi-monitor` as a passive-stream pattern rather than infrastructure.
- Verification note: npm metadata was checked locally on 2026-06-14; local `npm config before` age-gates `@vanillagreen/pi-background-tasks@1.6.1`, so the first isolated test should use `@1.6.0` unless bypassing the policy intentionally.

## [2026-06-13] ingest | Arch AUR safety guide
- Source: `sources/repos/supply-chain-security/guides/arch-aur-safety.md` copied from local `github/shisa-ai/supply-chain-security/guides/arch-aur-safety.md`.
- Pages created: `wiki/practices/arch-aur-safety.md`.
- Pages updated: `wiki/practices/supply-chain-security.md`, `wiki/index.md`.
- Summary: added an AUR-specific supply-chain security page covering the AUR trust boundary, 2026-06-12 Arch malicious-package incident, affected-package intersection checks, IOC checks, AUR review checklist, build isolation, npm/Bun guardrails, network/secret controls, and compromise response.
- Verification note: confirmed the Arch incident notice and `aur-general` affected-package-list post directly on 2026-06-13; retained malware capability claims as public-analysis claims rather than locally reproduced reverse engineering.

## [2026-05-22] update | pi-agent — published pi-continue-after-compaction
- Published `pi-continue-after-compaction` as the public GitHub repo `https://github.com/lhl/pi-continue-after-compaction`.
- Switched the canonical package manifest from the local `/home/lhl/pi-continue-after-compaction` checkout to the GitHub source.
- Updated `pi-setup.sh` to rely on manifest sync without the local checkout preflight, while keeping the config bootstrap for `~/.pi/agent/continue-after-compaction.json`.
- Pages updated: `wiki/tools/pi-agent.md`, `wiki/index.md`.
- Repo changes in same logical unit: `pi-packages.json` source update, `pi-setup.sh` preflight removal, and `README.md` Context Management link update.

## [2026-05-20] update | pi-agent — canonical package manifest and sync script
- Added `pi-packages.json` as the canonical pi extension manifest and `tools/pi-sync.sh --prune` as the reconciliation path for stale machines, local path installs, and evaluation packages.
- Updated `pi-setup.sh` to call the sync script so new and existing machines share the same package workflow.
- Documented the workflow in `README.md` and `wiki/tools/pi-agent.md`, including dry-run usage and the rule that canonical plugin changes update the manifest, setup, README, and wiki together.
- Pages updated: `wiki/tools/pi-agent.md`, `wiki/index.md`.

## [2026-05-15] update | pi-agent — added standalone auto-compaction continue watchdog
- Added standalone local package `/home/lhl/pi-continue-after-compaction` to the canonical Pi package manifest.
- Documented the reason-guarded behavior: sends `continue` only after auto-threshold compaction when no next turn starts; manual `/compact` and `/pi-vcc` remain manual.
- Captured the upgrade-safe implementation strategy: runtime metadata monkeypatch attaches `reason` / `willRetry` to compaction extension events until pi exposes those fields natively.
- Pages updated: `wiki/tools/pi-agent.md`, `wiki/index.md`.
- Repo changes in same logical unit: `pi-packages.json` adds the standalone checkout; `pi-setup.sh` preflights the checkout and bootstraps `~/.pi/agent/continue-after-compaction.json`; `README.md` documents the extension under Context Management.

## [2026-05-15] update | pi-agent — installed lhl pi-goal fork
- Added `git:github.com/lhl/pi-goal` to the canonical Pi package manifest.
- Documented the fork as a goal/punchlist workflow that interacts with `pi-tasks` `TaskList`.
- Pages updated: `wiki/tools/pi-agent.md`, `wiki/index.md`.
- Repo changes in same logical unit: `pi-packages.json` adds the fork; `README.md` Task Management links to `lhl/pi-goal`; `pi-setup.sh` continues to install through `tools/pi-sync.sh --prune`.

## [2026-05-12] ingest | Supply chain security playbook and Python secure defaults
- Source: user-supplied supply-chain security guide, local fish wrapper changes, Socket Mini Shai-Hulud/TanStack report.
- Pages created: `wiki/practices/supply-chain-security.md`.
- Pages updated: `wiki/index.md`.
- Summary: documented secure-by-default fish wrappers for `uv` and `pip` with a 1-day age gate, no sdist builds / wheels-only defaults, explicit unsafe escape hatches, and broader package-manager/CI defenses across Python, npm, pnpm, Bun, and GitHub Actions.
- Incident note: linked the ongoing Mini Shai-Hulud campaign and captured relevant TanStack/PyPI implications: trusted publishing can be abused if attackers execute inside CI, lifecycle scripts remain a key vector, age gates and egress control help, and developer tool directories such as `.claude/` / `.vscode/` are part of the persistence surface.

## [2026-05-11] update | pi-agent — switched pi-tasks install to lhl fork
- Updated the pi-agent extension record to install task management from `https://github.com/lhl/pi-tasks` instead of upstream `npm:@tintinweb/pi-tasks`.
- Documented fork-specific behavior: no system-reminder context injection, prompt-queued `TaskExecute`, `TaskCreateMany`, and auto-continue-with-prompts rather than subagent launches.
- Pages updated: `wiki/tools/pi-agent.md`, `wiki/index.md`.
- Repo changes in same logical unit: `pi-setup.sh` removes the legacy upstream package before installing the fork; `README.md` Task Management now links to `lhl/pi-tasks`.

## [2026-05-10] update | DELEGATE-52 harness comparison expanded with pi, Codex, Claude Code
- Source: local Codex CLI snapshot (`/home/lhl/github/other/codex`), local Claude Code analysis snapshot (`/home/lhl/github/lhl/claudecode-codex-analysis/src`), plus pi edit-tool diff implementation.
- Pages updated: `wiki/papers/delegate52-document-corruption.md`, `wiki/index.md`.
- Summary: expanded the harness analysis from a two-column DELEGATE-52-vs-pi comparison into a four-way table covering read/search surfaces, edit primitives, unchanged-text data paths, ambiguity handling, staleness rails, diff/audit surfaces, validator loops, and residual full-rewrite risk.
- Takeaway: production coding harnesses differ materially: pi uses exact multi-replacements, Codex centers shell plus grammar-constrained `apply_patch`, and Claude Code uses dedicated read/search/edit/write tools with read-before-edit and staleness checks. DELEGATE-52's basic agent remains a weak baseline rather than a general verdict on agentic editing.

## [2026-05-10] ingest | DELEGATE-52 document corruption and agentic harness analysis
- Source: arXiv 2604.15597 (PDF + arXiv HTML), microsoft/delegate52 harness snapshot (`model_agentic.py`, prompts, model wrapper), Hacker News discussion 48073246, local pi-coding-agent README/edit-tool snapshot.
- Pages created: `wiki/papers/delegate52-document-corruption.md`.
- Pages updated: `wiki/index.md` (new Papers section).
- Summary: documented the benchmark's round-trip-relay method and headline degradation results; separated the credible full-document delegation warning from the narrower "tool use did not help" result; compared the paper's full-read/full-write/basic-Python harness to pi-style exact replacement, diff/test/git-driven coding workflows.

## [2026-05-10] update | Token reduction landscape — removed pi-rtk-optimizer, installed pi-context-prune
- Audited the pi-rtk-optimizer / rtk stack against documented failure modes (rtk #690 Playwright, #1282 pipe corruption, #720 gh comments, #1152 curl JSON, #1080 npx, #1335 exclude_commands, #640 auto-allow injection); confirmed via `pi-rtk-optimizer` 0.7.1 source review (npm pack) that v0.6.0 removed local bypass tables in favor of pure delegation to `rtk rewrite`, so the binary's bugs propagate; documented what the pi extension *did* sidestep (auto-allow #640, read-tool source-filter destruction) vs what it didn't (Linux pipe corruption, Playwright, gh comments, curl JSON).
- Surveyed alternatives: lean-ctx, snip, caveman, headroom, pi-dynamic-context-pruning, pi-context-pruning, hermes-context-manager. Established two-category framework (per-command output summarizers vs context-level dedup/pruning) and a lossless-vs-lossy transform table; cited third-party benchmarks (implicator.ai's caveman audit, vexp.dev manual-vs-automated, lean-ctx 'fix inflated savings' release).
- Installed `pi-context-prune` 0.9.1, bootstrapped `~/.pi/agent/context-prune/settings.json` with `enabled: true`, `pruneOn: "agent-message"`, default summarizer/thinking. Reasoning: recoverable transform via `context_tree_query`, prompt-cache-friendly batching, no bash data-path interception. Removed `pi-rtk-optimizer` via `pi remove`; left rtk binary on PATH for explicit `rtk proxy`/`rtk gain` use.
- Pages created: `wiki/tools/pruning-and-compaction.md` (full landscape analysis, audit, alternatives, decision rationale, operational details, open questions, provenance).
- Pages updated: `wiki/tools/pi-agent.md` (Installed Extensions table, usage section, Extensions section now points to pruning-and-compaction page; Compaction Landscape cross-link), `wiki/index.md` (new tools entry; rtk entry annotated with current status).
- Repo changes (committed in same logical unit per AGENTS.md): `pi-setup.sh` (removed `pi install npm:pi-rtk-optimizer`, added `pi install npm:pi-context-prune` + config bootstrap, updated rtk binary install comment), `README.md` (Context Management section now leads with pi-context-prune; rtk entry historicized with link to wiki page).

## [2026-05-10] update | pi-agent — document message queue keybindings
- Added Keybindings section to wiki/tools/pi-agent.md covering the default `Alt+Enter` (queue follow-up) and `Alt+Up` (restore queued messages) bindings.
- Documented remapping recipe to match ChatGPT Codex-style `Tab` / `Shift+Tab` in `~/.pi/agent/keybindings.json`, with `/reload` to apply.
- Included comparison table: Submit (Enter), Queue follow-up (Alt+Enter / Tab), Restore queued (Alt+Up / Shift+Tab).
- Pages updated: wiki/tools/pi-agent.md (new Keybindings section before Open Questions).

## [2026-05-09] ingest | Session Traces and Stats tools
- Source: research via GitHub repos
- Pages created: wiki/tools/session-traces.md
- Pages updated: wiki/index.md

## [2026-05-09] update | pi-agent — document optional pi-codex-fast extension
- Installed `@calesennett/pi-codex-fast` locally for evaluation and documented it as optional/not default.
- Captured behavior: `/codex-fast`, `pi --fast`, OpenAI/OpenAI Codex-only `service_tier: "priority"` injection, settings persistence, and status indicator.
- Decision: do not add to `pi-setup.sh` by default until there is a simple verification path proving the priority service tier is accepted and desirable for the current account/plan.
- Pages updated: wiki/tools/pi-agent.md (frontmatter links, table row, new section), wiki/index.md (tools summary updated).

## [2026-05-08] update | pi-agent — pi-zentui Codex quota footer
- Updated `lhl/pi-zentui` so the footer replaces dollar cost with Codex quota remaining when the active model is `openai-codex` or `multicodex`.
- Display format: `5h:82% · 7d:41% ↺2d4h`; only the percentage values change color (green normally, yellow under 50%, orange under 25%, red under 5%).
- Data source priority: `pi-multicodex` status footer first, then `pi-codex-status` cache (`~/.cache/pi-codex-status/usage.json`).
- Pages updated: wiki/tools/pi-agent.md (pi-zentui local customizations).

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
