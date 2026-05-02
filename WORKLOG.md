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
