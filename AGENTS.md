# devstack - Agent Guide

Handbook, framework, and toolkit for agentic programming practices. This repo is a hybrid: part knowledge base (LLM Wiki pattern), part software (pi-agent, tools), part reference library. Mistakes to prevent: writing into `sources/` (immutable), editing wiki pages without updating `wiki/index.md` and `wiki/log.md`, and mixing knowledge-base content with project software.

## Non-Negotiables

1. **Commit after every logical work unit.** Do not wait to be asked. A logical unit is any self-contained piece of completed work: a wiki ingest, a new file, an edit to docs, a config change, scaffolding, a bug fix. If it's done, commit it. Multiple small commits are always better than one big commit at the end.
2. **Never use `git add .`, `git add -A`, or `git commit -a`.** Stage files explicitly by name.
3. **`sources/` is immutable.** Never modify a file after it has been filed there.

## Summary

- Primary purpose: personal agentic practices KB + supporting software
- `AGENTS.md` is the canonical instructions file; `CLAUDE.md` is symlinked to it
- Source-of-truth docs: `WORKLOG.md` (session history), `README.md` (repo structure + wiki schema), `wiki/index.md` (wiki catalog), `wiki/log.md` (wiki operations log)
- The wiki schema (ingest/query/lint operations, page conventions) lives in `README.md`

## Symlink Convention

All repos use `AGENTS.md` as the single instruction source. `CLAUDE.md` is a symlink:

```bash
# In any repo root:
ln -s AGENTS.md CLAUDE.md
```

This ensures Claude Code and Codex read the same file. The symlink should be committed to git. When editing instructions, always edit `AGENTS.md` directly.

## Project Overview

This repo has two distinct layers:

**Knowledge base** — the LLM Wiki pattern (Karpathy). Sources go into `sources/`, the agent compiles synthesized pages into `wiki/`, and `inbox/` is the staging area for unprocessed material. The agent owns `wiki/`; humans own `sources/` and `inbox/`.

**Software and tools** — pi-agent, RTK configs, scripts, and other software live in `projects/` and `tools/`. These follow normal development workflows, not wiki operations.

## Key Files

| Path | Purpose |
| --- | --- |
| `README.md` | Repo overview, directory roles, wiki schema, setup |
| `AGENTS.md` | This file — agent instructions |
| `WORKLOG.md` | Append-only session log — what was done, decisions, next steps |
| `wiki/index.md` | Agent-maintained catalog of all wiki pages |
| `wiki/log.md` | Append-only chronological operations log |
| `docs/` | Working project docs for this repo (dev notes, research) |

## Directory Ownership

| Directory | Owner | Mutability |
| --- | --- | --- |
| `inbox/` | Human drops, agent processes | Transient — items move to `sources/` after ingest |
| `sources/` | Human curates | Immutable once filed — agent reads, never modifies |
| `wiki/` | Agent | Agent creates, updates, cross-links; human reads |
| `docs/` | Human or agent | Project working docs, not wiki content |
| `projects/` | Human or agent | Software — normal dev workflow |
| `tools/` | Human or agent | Scripts and configs — normal dev workflow |

## Workflow Expectations

### Before Starting

- Read `WORKLOG.md` — check the latest entry for context on recent work and next steps
- Check `git status -sb`
- For wiki operations, read `wiki/index.md` to understand current wiki state

### Wiki Operations

Follow the wiki schema in `README.md` (sections: Operations, Page conventions, index/log formats, subdirectories, filing rules).

- **Ingest**: process `inbox/` items → write/update `wiki/` pages → update `wiki/index.md` → prepend to `wiki/log.md` → move originals to `sources/`
- **Query**: read `wiki/index.md` → read relevant pages → synthesize → optionally file answer as new wiki page
- **Lint**: check for orphans, stale claims, missing pages, contradictions, broken `[[wikilinks]]`

Key constraints:
- Every wiki page needs frontmatter (`title`, `tags`, `sources`, `links`) — see README.md for format
- Every new or updated page must be reflected in `wiki/index.md`
- Every operation must be logged in `wiki/log.md` (reverse-chronological)
- File sources into the correct `sources/` subdirectory by format/origin — see README.md filing rules

### Research and Claim Hygiene

When ingesting research sources or writing wiki pages that reference external work:

- Separate **author claims** from **our verification**. If we haven't reproduced or validated something, say so explicitly.
- Don't invent implementation details. Prefer "unknown/TBD" with links to upstream evidence over plausible-sounding guesses.
- When quoting benchmarks or metrics, include context: hardware, dataset, date, methodology — whatever is needed to interpret the number.
- Contradictions are valuable. When a new source contradicts an existing wiki page, flag both sides rather than silently overwriting.

### Software Development

Software in `projects/` uses git submodules. Normal development workflow — no wiki operations required.

**Submodule convention** (for `projects/`):
- Prefer submodules over vendored snapshots — keeps the repo lean
- Record provenance: source URL, reviewed commit/tag, review date, short note on why it's here
- Do not keep `.git/` directories in snapshots; remove generated artifacts
- Research notes about a project belong in `wiki/`, not inside the submodule

### Before Claiming Done

- For wiki changes: verify `wiki/index.md` and `wiki/log.md` are updated
- For software changes: run relevant verification
- Append a session entry to `WORKLOG.md`
- Commit immediately if the logical unit is complete

### WORKLOG.md Convention

Append-only. Never edit or delete past entries. Each entry follows this format:

```markdown
## YYYY-MM-DD — Short description

**What:** One-line summary of the session's purpose.

- Bullet list of what was actually done
- Include file paths, decisions, and outcomes

**Decisions:**
- Key choices made and why (these are the hard-to-recover bits)

**Next:**
- What remains to be done
```

The WORKLOG is the rewind tape — it should capture enough context that a future session (or a human reading git history) can understand what happened and why without replaying the full conversation.

## Verification

| Scope | Check |
| --- | --- |
| Wiki ingest | `wiki/index.md` updated, `wiki/log.md` appended, source archived to `sources/` |
| Wiki lint | No orphan pages, no broken `[[wikilinks]]`, index matches actual files |
| Software | Depends on the project — run tests/builds as appropriate |
| Repo structure | No files in `sources/` modified after initial filing |

## Git Discipline

**Commit immediately when a logical unit is complete. Do not batch. Do not wait to be asked.**

A logical unit is complete when it can stand on its own. Examples:

- Scaffolding new directories or files → commit
- Adding or updating a doc → commit
- A wiki ingest (pages + index + log) → commit
- A config or schema change → commit
- A code change that works → commit
- Repo setup or cleanup → commit

How to commit:

1. `git status -sb` — review what changed
2. `git add <file> <file> ...` — stage explicitly by name, never `git add .` / `-A` / `-a`
3. `git diff --staged` — review the staged diff
4. Commit with conventional prefix: `feat:`, `docs:`, `wiki:`, `fix:`, `chore:`, `refactor:`
5. No AI attribution or bylines

Keep wiki commits separate from software commits when both happen in the same session. Leave unrelated local changes untouched.

## Writing Discipline

Wiki pages and docs are meant to be read by someone who hasn't seen the source material. Follow these conventions:

- Use each project/tool's own terminology — don't rename concepts for consistency if it loses precision.
- Expand acronyms on first use, even project-specific ones.
- One item per bullet. Don't collapse distinct mechanisms, findings, or tools into comma-separated run-on lists.
- All claims should be traceable to a source in `sources/` or an external link. If a claim isn't sourced, mark it as such.
- Keep line items scannable — a reader should understand each bullet independently.

## Coordination Hygiene

- High-conflict files: `AGENTS.md`, `README.md`, `wiki/index.md`
- Do not revert or overwrite work you did not make
- If `wiki/index.md` or `wiki/log.md` has been modified by another session, read before writing

## Blockers

- Ask for help when the wiki schema in `README.md` doesn't cover a new source type or edge case
- Escalate if sources in `sources/` appear to have been modified

## Meta: Evolving This File

- Keep weight appropriate — this is a Medium-weight repo
- Promote recurring mistakes into explicit rules
- If wiki schema rules change, update `README.md` (the schema), not this file
- Remove rules that are no longer enforced
