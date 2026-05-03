# Wiki Log

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
