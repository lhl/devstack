---
title: "DELEGATE-52 — document corruption under delegated LLM editing"
tags: [papers, llm-evaluation, document-editing, agent-harnesses, reliability, pi-agent, codex, claude-code]
sources:
  - sources/papers/laban-2026-delegate52.pdf
  - sources/papers/laban-2026-delegate52-arxiv-html.html
  - sources/repos/delegate52/COMMIT
  - sources/repos/delegate52/model_agentic.py
  - sources/repos/delegate52/domain_base.py
  - sources/repos/delegate52/model_openai.py
  - sources/repos/delegate52/prompts/domain_documents.txt
  - sources/repos/delegate52/prompts/domain_python.txt
  - sources/articles/hacker-news-delegate52-48073246.html
  - sources/repos/pi-coding-agent/VERSION
  - sources/repos/pi-coding-agent/README.md
  - sources/repos/pi-coding-agent/dist-core-tools/edit.js
  - sources/repos/pi-coding-agent/dist-core-tools/edit-diff.js
  - sources/repos/codex/COMMIT
  - sources/repos/codex/codex-rs/core/prompt_with_apply_patch_instructions.md
  - sources/repos/codex/codex-rs/core/src/tools/spec_plan.rs
  - sources/repos/codex/codex-rs/core/src/tools/handlers/apply_patch_spec.rs
  - sources/repos/codex/codex-rs/core/src/tools/handlers/apply_patch.rs
  - sources/repos/codex/codex-rs/core/src/tools/handlers/shell_spec.rs
  - sources/repos/codex/codex-rs/tools/src/tool_config.rs
  - sources/repos/codex/codex-rs/tools/src/tool_spec.rs
  - sources/repos/codex/codex-rs/apply-patch/apply_patch_tool_instructions.md
  - sources/repos/codex/codex-rs/apply-patch/src/lib.rs
  - sources/repos/claudecode-codex-analysis/COMMIT
  - sources/repos/claudecode-codex-analysis/src/constants/prompts.ts
  - sources/repos/claudecode-codex-analysis/src/tools/FileEditTool/prompt.ts
  - sources/repos/claudecode-codex-analysis/src/tools/FileEditTool/FileEditTool.ts
  - sources/repos/claudecode-codex-analysis/src/tools/FileEditTool/types.ts
  - sources/repos/claudecode-codex-analysis/src/tools/FileEditTool/utils.ts
  - sources/repos/claudecode-codex-analysis/src/tools/FileReadTool/prompt.ts
  - sources/repos/claudecode-codex-analysis/src/tools/FileReadTool/FileReadTool.ts
  - sources/repos/claudecode-codex-analysis/src/tools/FileWriteTool/prompt.ts
  - sources/repos/claudecode-codex-analysis/src/tools/FileWriteTool/FileWriteTool.ts
  - sources/repos/claudecode-codex-analysis/src/tools/BashTool/prompt.ts
  - sources/repos/claudecode-codex-analysis/src/tools/GrepTool/prompt.ts
  - sources/repos/claudecode-codex-analysis/src/tools/GlobTool/prompt.ts
  - sources/repos/claudecode-codex-analysis/src/tools/NotebookEditTool/prompt.ts
links:
  - https://arxiv.org/abs/2604.15597
  - https://github.com/microsoft/delegate52
  - https://github.com/microsoft/delegate52/blob/main/model_agentic.py
  - https://news.ycombinator.com/item?id=48073246
  - https://platform.claude.com/docs/en/agents-and-tools/tool-use/text-editor-tool
  - https://github.com/openai/codex
  - https://docs.anthropic.com/en/docs/claude-code
  - https://pi.dev
---

# DELEGATE-52 — document corruption under delegated LLM editing

## One-line read

The DELEGATE-52 paper is a good benchmark for long-horizon *document-preservation under delegated edits*, but its "agentic tool use did not help" result is narrow: the published harness mostly offers whole-file read/write plus optional Python, not the surgical edit/patch/validation workflows used by real coding harnesses such as [[tools/pi-agent]], Codex CLI, and Claude Code.

## What the paper measures

- **Benchmark:** 52 professional domains across code/configuration, science/engineering, creative/media, structured records, and everyday documents.
- **Work environments:** each domain has six environments with a seed document, 5-10 invertible edit tasks, and an 8-12k token distractor context.
- **Seed documents:** real public documents, generally 2-5k tokens, textual/unencoded, and selected to avoid toy/template data.
- **Evaluation primitive:** round-trip backtranslation. A model applies a forward edit and then an inverse edit; if it preserved everything, the reconstructed document should be equivalent to the seed.
- **Main metric:** `RS@k = sim(seed, reconstructed_after_k/2_round_trips)`, where `sim` is domain-specific parser/similarity logic.
- **Main workflow:** 10 round trips = 20 delegated interactions. Each edit step is an independent session; the model carries state only through the current document set.

This is a clever way to measure document corruption without a human-written reference for every intermediate edit. It also naturally amplifies rare collateral errors: a per-edit failure that is hard to see after one interaction becomes visible after 20.

## Headline results to keep

At 20 interactions, the top models in the paper still degrade substantially:

| Model | RS@2 | RS@20 |
| --- | ---: | ---: |
| Gemini 3.1 Pro | 96.8 | 80.9 |
| Claude 4.6 Opus | 94.2 | 73.1 |
| GPT 5.4 | 94.3 | 71.5 |
| GPT 5.2 | 92.7 | 66.1 |
| Claude 4.6 Sonnet | 92.2 | 66.0 |
| Kimi K2.5 | 91.1 | 64.1 |

Important interpretation notes:

- The paper's headline "25% corruption" is a drop in reconstruction score, not necessarily a byte/token corruption rate.
- Short-horizon performance can be misleading. The paper highlights GPT 5 and Kimi K2.5 as near-tied after two interactions but far apart by 20 interactions.
- The Python domain is the main outlier: 17/19 models reach the paper's "ready" threshold there, aligning with the intuition that code has strong syntax, tests, and tooling.
- Degradation worsens with larger documents, longer relays, and distractor context.
- Critical failures dominate total degradation: the paper argues models often stay near-perfect for some rounds and then suffer sparse large drops, not merely smooth "death by a thousand cuts."

## The agentic harness as implemented

The paper's direct/non-agentic path asks the model to output complete fenced file blocks. The generic document prompt says the output should be one or several text blocks, each starting with a filename fence, and must produce the target files. The Python prompt similarly asks the model to rewrite the program and output the full target files.

The agentic path (`model_agentic.py`) exposes five OpenAI function-calling tools:

- `read_file(filename)` — read the **full** contents of one workspace file.
- `write_file(filename, content)` — create or overwrite a file with **full file content**.
- `delete_file(filename)` — delete a workspace file.
- `run_python(code)` — execute Python against `./workspace/<filename>` with a 30-second timeout and output truncation.
- `finish()` — signal completion.

Other relevant implementation details:

- The system prompt says: "You can approach the task in whatever way you find most effective: programmatically or directly by writing files."
- It does **not** provide `str_replace`, `insert`, `apply_patch`, range reads, grep/search, diff preview, or a required validator/test step.
- It hardcodes `temperature=1.0` for agentic OpenAI calls. The direct OpenAI wrapper also defaults to `temperature=1.0` when no override is supplied.
- The agentic loop allows up to 25 LLM turns and 500k cumulative tokens.
- The only mandatory completion gate is write-before-finish: `finish()` is rejected until the model has called `write_file` or `run_python` at least once.
- The harness logs `agentic_operation_sequence`, tool calls, files read, token usage, latency, and clean finish status, so operation-conditioned analysis should be possible from run logs.

## Tool-use result: useful but narrow

The paper compares direct vs agentic operation for four GPT-family models and finds all four worse with tools:

| Model | Direct RS@20 | Agentic RS@20 | Difference |
| --- | ---: | ---: | ---: |
| GPT 5.4 | 71.5 | 68.3 | -3.2 |
| GPT 5.2 | 66.1 | 63.4 | -2.7 |
| GPT 5.1 | 60.5 | 52.1 | -8.4 |
| GPT 4.1 | 49.5 | 40.4 | -9.1 |

The paper's own explanation is mostly about overhead and tool choice:

- Models invoke roughly 8-12 tools per task.
- Input-token consumption rises roughly 2-5x.
- Models still often favor manual file writing over code execution.
- Better models use code execution more often; the paper cites GPT 5.4 using code execution far more than GPT 4.1.

**Our interpretation:** this supports the claim "this basic harness did not help." It does not establish "agentic editing tools do not help" in general.

## Where the Hacker News critique lands

The top HN thread's main critique, led by Simon Willison, is correct on the narrow agentic claim:

- `read_file` + `write_file` is mechanically close to full-file round-tripping: the model reads a whole file, internally edits/regenerates it, and overwrites the whole file.
- The harness gives the model `run_python`, but the prompt only weakly nudges programmatic transformation.
- Modern coding agents put substantial design effort into editing primitives that avoid regenerating unchanged content.

The counterpoints are also worth preserving:

- Many real-world non-technical users are not using a careful harness. For them, the paper's direct/full-document delegation pattern is a genuine warning.
- Some agent-tool builders are skeptical that `str_replace` materially improves modern frontier-model *single-edit* accuracy over full rewrite; speed, cost, and latency may be the larger everyday reasons for patch tools.
- Even if the single-edit accuracy delta is small, DELEGATE-52 is a compounding benchmark. A small reduction in collateral-change probability can matter over 20 interactions.

The deeper point is not "`str_replace` always beats full rewrite." It is that serious document/code editing systems should avoid asking the model to reproduce unchanged authoritative text unless the task genuinely requires it.

## Harness comparison: DELEGATE-52 vs pi, Codex, and Claude Code

Local source snapshots make the harness gap more concrete. The paper's basic agent is not merely "less polished" than production coding agents; it has a different edit data path.

| Dimension | DELEGATE-52 basic agent | Pi coding harness | Codex CLI | Claude Code |
| --- | --- | --- | --- | --- |
| Read/search surface | `read_file` returns a whole file; no range read or search primitive. | `read` supports offsets/limits; `bash` and other tools support grep/find-style narrowing. | Shell/unified exec is the main read/search surface; models use `rg`, `sed`, `python`, tests, and other commands. | Dedicated `Read` supports offsets/limits and line numbers; dedicated `Glob` and `Grep` replace shell search. |
| Primary edit primitive | `write_file(filename, content)` overwrites full files; `run_python` is optional. | `edit` applies one or more targeted `oldText` to `newText` replacements; `write` is available for new files or full rewrites. | `apply_patch` is a grammar-constrained freeform tool with add/update/delete file hunks; shell scripts can also transform files. | `Edit` applies exact `old_string` to `new_string` replacements with optional `replace_all`; `Write` is for creates or complete rewrites; `NotebookEdit` handles cells. |
| Unchanged text path | Usually regenerated when the model uses `write_file`. | Usually copied by the runtime outside edited spans. | Usually copied by the patch runtime outside patch hunks, or by deterministic shell/Python code. | Usually copied by the runtime outside the selected replacement string. |
| Ambiguity handling | Whole-file overwrite accepts whatever text the model emits. | Edits must match unique, non-overlapping regions; missing/duplicate/overlapping edits fail. | Patch application verifies expected context/old lines against current files and fails when they cannot be found. | `old_string` must be unique unless `replace_all` is set; missing or multiple matches fail. |
| Staleness and concurrency | No read-after-write or stale-file guard beyond workspace state. | File mutation queue serializes edits; exact current-file matching catches many stale-target cases. | Patch verification runs against current filesystem state; sandbox/approval flow mediates mutation. | Existing-file edits/writes require prior non-partial `Read`; modified-since-read files are rejected unless content is unchanged. |
| Diff/audit surface | Operation logs exist, but no mandatory diff preview before `finish()`. | `edit` computes/render diffs; normal workflow uses `git status`, `git diff`, tests, and commits. | `apply_patch` produces structured patch/update events; shell/git diff remains available. | Edit/write results include structured patches; file history, IDE/LSP notifications, and git diff paths exist. |
| Tool-choice nudge | Weak: "programmatically or directly by writing files." | Tool prompt says use `edit` for precise changes and `write` for new/full rewrites. | Prompt says the agent can run terminal commands and apply patches; current tool plan registers `apply_patch` when enabled. | System prompt says use `Read`, `Edit`, `Write`, `Glob`, and `Grep` instead of shell equivalents; `Write` prompt explicitly prefers `Edit` for existing files. |
| Validator loop | None required in the agent loop. | Harness exposes shell/tests; repo instructions often require verification and commits. | Shell/test execution is first-class; no generic mandatory validator. | Bash/test execution is available; no generic mandatory validator, but LSP notifications and file history improve feedback. |
| Residual full-rewrite risk | High, because full rewrite is the main mutation path. | Medium: `write` and broad replacement blocks can still round-trip too much text. | Medium: shell heredocs or broad patches can still rewrite files. | Medium-low for local edits; `Write` still fully overwrites when chosen. |

### Pi harness notes

- Pi's built-in `edit` tool accepts an array of replacements, and each `oldText` is matched against the original file, not incrementally after prior edits.
- The implementation rejects empty, missing, duplicate, and overlapping replacements, then applies the matched edits in reverse order so offsets remain stable.
- The implementation normalizes line endings, strips/restores byte order marks, and has a fuzzy fallback for trailing whitespace, smart quotes, Unicode dashes, and special spaces.
- The tool renders a diff preview/result and uses a per-file mutation queue, so the user and harness see patches rather than only final file contents.
- Pi still has a `write` tool and shell access, so it is not immune to full rewrites. The difference is that normal coding-agent workflow strongly favors targeted edits, git diffs, tests, and explicit commits.

### Codex CLI notes

- Codex's open-source harness is terminal-first: shell/unified-exec tools are the main way to read/search files and run validators.
- Codex adds an `apply_patch` tool when the environment supports it. The tool is a freeform grammar, not JSON, with explicit add-file, delete-file, update-file, and move operations.
- Patch application parses hunks, reads the current file, searches for expected context/old lines, and returns correctness errors when expected lines cannot be found.
- Codex also intercepts `apply_patch` invocations sent through shell-like tools and tells the model to use the dedicated `apply_patch` tool instead.
- Compared with DELEGATE-52, Codex is a patch/programmatic harness, not a read/write harness. Compared with pi and Claude Code, it leans more on shell discipline for file reads/searches rather than dedicated file-read/search functions.

### Claude Code notes

- Claude Code exposes dedicated `Read`, `Edit`, `Write`, `Glob`, `Grep`, `Bash`, and `NotebookEdit`-style tools in the inspected source.
- `Read` returns line-numbered content and supports offset/limit. `Edit` instructions require a prior `Read`; the implementation rejects edits when the file has not been read or when only a partial view was read.
- `Edit` replaces an exact `old_string` with `new_string`, requires uniqueness unless `replace_all` is true, and rejects stale files modified since the read unless the content is unchanged.
- `Write` is still a full-content overwrite, but its prompt says to prefer `Edit` for modifying existing files and to use `Write` only for new files or complete rewrites; existing-file writes also require a prior read.
- The system prompt explicitly tells the model to use `Read` instead of `cat`/`head`/`tail`/`sed`, `Edit` instead of `sed`/`awk`, `Write` instead of heredocs/echo redirection, and `Glob`/`Grep` instead of `find`/`grep`/`rg`.
- This matches the Hacker News nuance: Claude Code here does not need the Anthropic text-editor `insert` command to avoid whole-file round-tripping; its core protection is exact replacement plus read/staleness/diff rails.

### Cross-harness takeaways

- The key safety property is not the name `str_replace`; it is whether unchanged authoritative text travels through the model output channel. Pi, Codex, and Claude Code all provide normal mutation paths where unchanged text is copied by tooling rather than regenerated by the model.
- The strongest production harnesses combine multiple layers: targeted edit primitives, search/range reads, shell/programmatic transforms, diff display, stale-file checks or exact current-file matching, and tests/parsers outside the model.
- DELEGATE-52's `run_python` tool is the most promising part of its basic agent, but the prompt does not strongly prefer parse-transform-emit scripts, and the average result suggests models often fell back to manual writing.
- A fair "agentic editing" benchmark should compare named harness designs, not just "with tools" vs "without tools": basic read/write, exact replacement, grammar patches, programmatic-first transforms, and validator-in-the-loop workflows are different systems.
- Production coding harnesses still cannot guarantee document preservation. They reduce one failure mode: collateral corruption caused by asking the model to reproduce unchanged text.

## Why real-world harness experience is not a formal counterexample

Our operational experience in pi — many code/doc edits through `read`, `edit`, `write`, `bash`, git diffs, tests, and commits — is evidence that a real harness can avoid obvious full-file-round-trip corruption in daily coding work. The Codex and Claude Code sources show the same general product direction: production coding agents invest in patches, exact replacements, search/range reads, shell execution, diff surfaces, and permission/staleness rails.

That is not a controlled measurement against DELEGATE-52. Reasons production coding workflows differ from the benchmark:

- Coding repos have strong external checks: syntax, tests, type systems, linters, formatters, and runtime smoke tests.
- Agents usually inspect targeted ranges or search results, then apply small patches; the benchmark often requires full-document structural transformations.
- Git provides a persistent audit/rollback layer; benchmark scoring happens after autonomous relays.
- Human oversight catches many mistakes that an automated benchmark would count.
- Long-running sessions include repository instructions, accumulated context, and workflow conventions; DELEGATE-52 intentionally isolates each edit step.
- Production harnesses still expose escape hatches (`write`, shell heredocs, broad patches), so the advantage depends on tool choice and prompting, not mere tool availability.

So the right conclusion is not "the paper is wrong." It is: **the paper measures an unsafe delegation pattern and a weak agentic baseline; production coding harnesses are different systems that should be benchmarked separately.**

## What a stronger harness ablation should test

A useful follow-up would rerun DELEGATE-52 with named harness variants:

1. **Direct full rewrite** — the paper's baseline.
2. **Current basic agent** — `read_file`, `write_file`, `delete_file`, `run_python`, `finish`.
3. **Pi-style exact replacement** — offset/limit reads, multi-replacement `edit`, diff preview, shell tests/parsers, git checkpoints.
4. **Codex-style grammar patch** — shell/unified exec for exploration and validators, plus `apply_patch` add/update/delete hunks.
5. **Claude-Code-style dedicated tools** — `Read`, `Edit`, `Write`, `Glob`, `Grep`, `NotebookEdit`, read-before-edit, uniqueness, staleness checks, structured patches.
6. **Programmatic-first harness** — strongly prefer parse-transform-emit scripts; require justification before whole-file rewrite.
7. **Validator-in-the-loop harness** — domain parsers, schema checks, syntax checks, and round-trip-specific invariants before finish.

Metrics to log beyond RS@20:

- Bytes/tokens regenerated by the model.
- Diff size per edit.
- Collateral changes outside intended spans.
- Operation-conditioned scores (`run_python` vs `write_file` vs patch tools).
- Parser/test validation pass rate before and after retry.
- Cost, latency, and input/output-token overhead.
- Distractor files read/touched.
- Human-review or auto-review interventions if interactive modes are tested.

## Practical guidance for using LLMs on authoritative documents

- Avoid whole-document rewrites for small edits.
- Prefer targeted patch tools or deterministic scripts.
- For structured data, parse-transform-emit where possible.
- Always inspect diffs; use word diffs for prose and semantic diffs/parsers for structured formats.
- Add validators for non-code documents when feasible: schema checks, parsers, record counts, totals, checksums, expected headings, citation counts.
- Use git or another checkpointing system before delegating edits.
- Treat repeated AI "cleanup" passes as lossy unless the unchanged content is protected by tooling.

## Bottom line

DELEGATE-52 is valuable because it gives harness builders a broad, long-horizon target. The main corruption result is credible for full-document delegation and should concern anyone building document agents for non-technical users. The agentic null result should be cited carefully: it is a result about one basic harness, not a general result about real-world coding-agent harnesses.
