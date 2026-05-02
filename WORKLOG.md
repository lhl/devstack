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
- Wire up qmd collections
- Set up pi-agent and RTK in projects/
