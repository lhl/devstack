# Wiki Schema

Agent-maintained wiki operational guide. This is the canonical reference for how agents should create, update, and maintain the `wiki/` directory.

## Operations

**Ingest** — Process material from `inbox/` or `sources/` into the wiki:
1. Read the source material
2. Discuss key takeaways
3. Write or update summary page in `wiki/`
4. Update related concept, tool, and project pages
5. Update `wiki/index.md`
6. Append entry to `wiki/log.md`
7. Move original from `inbox/` to appropriate `sources/` subfolder

A single source may touch 5-15 wiki pages.

**Query** — Answer questions using the wiki:
1. Read `wiki/index.md` to find relevant pages
2. Read those pages, synthesize an answer
3. If the answer is substantial and reusable, file it as a new wiki page

**Lint** — Periodic health check:
- Orphan pages with no inbound links
- Stale claims superseded by newer sources
- Concepts mentioned but lacking their own page
- Missing cross-references
- Contradictions between pages

## Page conventions

**Frontmatter** — every wiki page starts with YAML frontmatter:
```yaml
---
title: Page Title
tags: [category, topic, ...]
sources:                          # files in sources/ that this page draws from
  - sources/gists/example.md
links:                            # external URLs (repos, docs, sites)
  - https://github.com/org/repo
  - https://example.com
---
```

**Wikilinks** — cross-references between wiki pages use `[[relative/path]]` from `wiki/`:
- `[[tools/pi-agent]]` — links to `wiki/tools/pi-agent.md`
- `[[concepts/llm-wiki]]` — links to `wiki/concepts/llm-wiki.md`

**Content rules:**
- One concept per page — split rather than merge
- Pages link back to their sources in `sources/` via frontmatter
- When updating an existing page (not creating new), the update should be additive — don't silently remove prior content unless it's been superseded

## index.md format

`wiki/index.md` is the catalog. Organized by category (matching subdirectories). Each entry is one line:

```markdown
# Wiki Index

## Tools

- [[tools/pi-agent]] — Pi coding agent: minimal extensible terminal coding harness (pi.dev)
- [[tools/rtk]] — RTK (Rust Token Killer): high-performance CLI proxy for 60-90% token reduction

## Concepts

- [[concepts/llm-wiki]] — The LLM Wiki pattern: compiled knowledge vs RAG

## Practices

- [[practices/multi-agent-coordination]] — Patterns for parallel agent work
```

Add new category headings as needed when a page doesn't fit existing categories. Categories should match `wiki/` subdirectories.

## log.md format

`wiki/log.md` is append-only and reverse-chronological (newest first). Each entry:

```markdown
## [YYYY-MM-DD] operation | Short description
- Source: path or URL
- Pages created: list
- Pages updated: list
```

Operations: `ingest`, `update`, `query`, `lint`.

## Wiki subdirectories

| Directory | What goes here | When to create a new subdir |
| --- | --- | --- |
| `wiki/tools/` | Individual tools, software, services | One page per tool |
| `wiki/concepts/` | Ideas, patterns, comparisons, theory | One page per concept |
| `wiki/practices/` | Workflows, playbooks, how-tos | One page per practice |
| `wiki/projects/` | Our own projects (pi-agent, devstack) | One page per project |

Create a new subdirectory only when a page doesn't fit any existing category. Prefer using an existing one.

## Filing rules for sources/

| Subdirectory | What goes here |
| --- | --- |
| `sources/gists/` | GitHub gists, external specs, standalone idea files |
| `sources/conversations/` | Exported chat sessions, research transcripts, session logs |
| `sources/articles/` | Web clippings, blog posts, newsletters |
| `sources/papers/` | PDFs, academic papers, whitepapers |

Create new subdirectories as needed (e.g., `sources/repos/` for cloned reference repos). The type is about the *format/origin* of the source, not its topic.
