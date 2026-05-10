---
title: "DELEGATE-52 — document corruption under delegated LLM editing"
tags: [papers, llm-evaluation, document-editing, agent-harnesses, reliability, pi-agent]
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
links:
  - https://arxiv.org/abs/2604.15597
  - https://github.com/microsoft/delegate52
  - https://github.com/microsoft/delegate52/blob/main/model_agentic.py
  - https://news.ycombinator.com/item?id=48073246
  - https://platform.claude.com/docs/en/agents-and-tools/tool-use/text-editor-tool
  - https://pi.dev
---

# DELEGATE-52 — document corruption under delegated LLM editing

## One-line read

The DELEGATE-52 paper is a good benchmark for long-horizon *document-preservation under delegated edits*, but its "agentic tool use did not help" result is narrow: the published harness mostly offers whole-file read/write plus optional Python, not the surgical edit/patch/validation workflow used by real coding harnesses such as [[tools/pi-agent]].

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

## Comparison: DELEGATE-52 harness vs pi-style coding harness

| Dimension | DELEGATE-52 agentic harness | Pi-style coding workflow |
| --- | --- | --- |
| File inspection | `read_file` returns whole file contents. | `read` can inspect files with offsets/limits; `bash`, grep/find/ls-style tools can narrow scope. |
| Primary edit primitive | `write_file(filename, content)` overwrites full file; `run_python` is optional. | `edit` does exact targeted replacements; `write` is mainly for new files or full rewrites; `bash` enables scripted transforms. |
| Unchanged text | Often regenerated when the model uses `write_file`. | Usually not regenerated for small/local edits; unchanged spans remain byte-identical because the tool replaces only matched regions. |
| Ambiguity handling | `write_file` accepts whatever full content the model emits. | Pi's built-in edit tool requires targeted `oldText` matches to be unique/non-overlapping, and rejects missing/ambiguous edits. |
| Diff/audit loop | Harness logs operations, but there is no mandatory diff review before `finish()`. | Normal workflow uses `git status`, `git diff`, tests/builds, and explicit commits after logical units. |
| Validation | No required parser/test/format check in the agent loop. | Coding tasks routinely run tests, type checks, linters, parsers, or domain-specific commands. |
| Session model | Each benchmark edit is independent except for the document state. | Interactive sessions retain task context, user steering, repo instructions, WORKLOG, git state, and compaction/recall. |
| User role | Autonomous benchmark run. | Human can steer, inspect diffs, interrupt, and require commits/checkpoints. |
| Model settings | OpenAI calls use `temperature=1.0` in the published code path. | Real harnesses often tune model choice/thinking/settings for editing; exact defaults vary by provider/session. |

The key structural difference is that pi's edit tool changes the *data path*. With full rewrite, the model must faithfully re-emit unchanged content. With exact replacement, unchanged content is copied by the tool/runtime, not regenerated by the model.

That does not make pi immune to document corruption:

- A model can choose `write` or a broad `edit` block and still cause collateral changes.
- A bad `oldText`/`newText` patch can implement the wrong transformation perfectly.
- Non-code documents often lack tests, parsers, or reviewers.
- Long context and distractors can still cause the model to miss instructions or edit the wrong region.

But it explains why large-scale coding-agent use often does not resemble the paper's failure mode. Most coding edits are local, tool-mediated, diff-reviewed, and mechanically validated; many DELEGATE-52 edits ask a model to transform and then reconstruct entire semi-structured documents.

## Why our pi experience is not a formal counterexample

Our operational experience in pi — many code/doc edits through `read`, `edit`, `write`, `bash`, git diffs, tests, and commits — is evidence that a real harness can avoid obvious full-file-round-trip corruption in daily coding work. It is not a controlled measurement against DELEGATE-52.

Reasons it differs from the benchmark:

- Coding repos have strong external checks: syntax, tests, type systems, linters, formatters, and runtime smoke tests.
- We usually inspect small ranges and apply small patches; the benchmark often requires full-document structural transformations.
- We use git as a persistent audit/rollback layer; benchmark scoring happens after autonomous relays.
- Human oversight catches many mistakes that an automated benchmark would count.
- Pi sessions include repository instructions and accumulated context; DELEGATE-52 intentionally isolates each edit step.

So the right conclusion is not "the paper is wrong." It is: **the paper measures an unsafe delegation pattern and a weak agentic baseline; a pi-like harness is a different system that should be benchmarked separately.**

## What a stronger harness ablation should test

A useful follow-up would rerun DELEGATE-52 with harness variants:

1. **Direct full rewrite** — the paper's baseline.
2. **Current basic agent** — `read_file`, `write_file`, `delete_file`, `run_python`, `finish`.
3. **Patch harness** — range read/view, search, exact `str_replace`, insert, delete range, diff preview, undo.
4. **Programmatic-first harness** — strongly prefer parse-transform-emit scripts; require justification before whole-file rewrite.
5. **Validator-in-the-loop harness** — domain parsers, schema checks, syntax checks, and round-trip-specific invariants before finish.
6. **Pi-like workflow harness** — exact replacements, shell tools, git diff, tests/parsers, commit/checkpoint semantics, and explicit retry on validation failure.

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
