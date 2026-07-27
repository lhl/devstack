---
title: Cross-Model Planner–Executor Workflows
tags: [llm, coding-agents, multi-agent, planning, handoffs, context-engineering, github]
sources:
  - sources/articles/reddit-chatgpt-codex-second-brain-1v80xhn.html
links:
  - https://www.reddit.com/r/ChatGPT/comments/1v80xhn/am_i_the_last_person_to_realize_chatgpt_can/
  - https://help.openai.com/en/articles/11145903-connecting-github-to-chatgpt
  - https://help.openai.com/en/articles/7925741-chatgpt-shared-links-faq
  - https://help.openai.com/en/articles/11487775-apps-in-chatgpt
---

# Cross-Model Planner–Executor Workflows

## One-line read

Use one model or product surface as a **read-only planner, researcher, or scratchpad** and a coding harness as the **stateful executor**. Pass a small, durable handoff between them rather than pretending they share one live memory. The split can improve focus, exploit different model strengths, and route around quota constraints, but only if repository state, permissions, acceptance checks, and provenance remain explicit.

## Source workflow: “ChatGPT is the brain, Codex is the hands”

A July 27, 2026 r/ChatGPT post by `tomototw` reports this manual workflow:

1. Connect ChatGPT to a GitHub repository.
2. Use “5.6 sol” in chat mode for repository reading and deeper thinking.
3. Accumulate context in the same conversation.
4. Share that conversation link with Codex using “5.6 luna.”
5. Let Codex focus on changing the code.

The author says Chat and Work/Codex had separate usage limits on their account, making the split useful when Codex quota was tight. An update says chat mode could also publish GitHub issues, and a follow-up comment proposes issues as a durable record. Other commenters mention Markdown handoffs, asking chat to generate the initial Codex prompt, and explicitly requesting a fresh-conversation handoff when a planning thread grows long.

These are **community reports**, not capabilities we independently reproduced. Model names, quotas, product surfaces, and app permissions are time- and account-specific.

## Verified product boundaries

Official OpenAI documentation narrows several claims in the thread:

- The ChatGPT GitHub app can access allowed public or private repositories and search live code/docs for relevant snippets. The documentation describes query-based retrieval, not guaranteed ingestion of an entire repository into one context.
- Availability varies by plan and experience; GitHub may appear in Deep Research or Agent Mode but not ordinary chat.
- The built-in GitHub app is documented as **read-only**. OpenAI directs code editing and pushing to Codex.
- ChatGPT apps in general may expose write actions, but those actions depend on the specific app, granted permissions, workspace policy, and approval settings. Therefore the Reddit report about creating GitHub issues should not be assumed to be a universal feature of the built-in GitHub connector.
- Anyone with a ChatGPT shared-link URL can view that conversation. Shared links have no expiration setting. Deleting the source link does not remove copies that viewers already imported into their own history.

Treat current UI behavior as something to inspect at use time, not a stable property of this workflow.

## Why role separation can help

The useful abstraction is not “two chats.” It is separation along four axes:

| Axis | Planner / scratchpad | Executor |
| --- | --- | --- |
| **Role** | Explore, compare, identify constraints, design tests | Inspect current state, edit, run tools, verify, commit |
| **Context** | Broad repository/problem context; alternatives | Narrow task brief plus live worktree and tool output |
| **Permissions** | Prefer read-only | Scoped write/shell/Git permissions |
| **Budget/model** | Model optimized for analysis or spare quota | Model/harness optimized for reliable tool use |

This can reduce executor context spent on open-ended exploration. It can also preserve a planner’s clean conceptual view while the executor accumulates noisy command output. Different models may expose different blind spots, although “different model” does not guarantee independent errors.

## Handoff options

| Handoff | Best use | Strengths | Main failure modes |
| --- | --- | --- | --- |
| **Shared chat link** | Fast ad hoc transfer | Lowest friction; preserves full reasoning trail | Public-to-link exposure, no expiry, link dependence, oversized/noisy context, mutable availability |
| **Pasted short brief** | One bounded task | Explicit, minimal, works everywhere | Easy to omit provenance or lose after the session |
| **Markdown handoff** | Repeatable local work | Versionable, diffable, can name commit/tests | Can become stale or be mistaken for authoritative repo state |
| **GitHub issue** | Team-visible task queue | Durable discussion, ownership, labels, closure, links to PRs | Remote/public exposure, stale branch assumptions, issue text may contain untrusted instructions |
| **Checked-in plan/ADR** | Architectural or multi-session decisions | Lives with code and history; reviewable | Process overhead; planner needs carefully scoped write access |
| **PR description/review** | Implementation-bound handoff | Tied to exact diff/commit and CI | Too late for broad planning; review comments can fragment |
| **Harness model call** | Automated scratchpad, planner, critic, or specialist | Reproducible prompt/role/budget; response can become an artifact | Hidden cost, correlated errors, context leakage, orchestration complexity |

A shared URL is convenient transport, not durable memory. For consequential work, extract a brief into an issue or versioned file and include the source link only as optional background.

## Recommended manual workflow

1. **Pin the source state.** Give the planner repository URL, branch, and commit SHA. Record whether it sees a remote snapshot or the executor’s live worktree.
2. **Assign one planning role.** Ask for analysis, alternatives, risks, and acceptance checks—not edits and not a giant implementation transcript.
3. **Freeze a concise handoff.** Once the decision is made, distill it into a bounded brief. Do not force the executor to infer the decision from a long chat.
4. **Revalidate locally.** The executor reads its own instructions, checks `git status`, confirms the commit/branch, and inspects every named file before editing.
5. **Implement the smallest accepted scope.** The executor may diverge from the plan when live code contradicts it, but must record why.
6. **Run mechanical checks.** Tests, builds, linters, diffs, and repository-specific acceptance commands remain authoritative.
7. **Use an independent review pass when warranted.** Give a reviewer the requirements, final diff, and test evidence; withhold the favored implementation rationale initially if genuine independence matters.
8. **Write the outcome back.** Close/update the issue or handoff artifact with commits, test results, deviations, and remaining work.

## Minimal handoff contract

```markdown
# Task handoff

Goal:
Non-goals:
Repository / branch / commit inspected:
Current behavior and evidence:
Decision:
Alternatives rejected and why:
Files or components likely involved:
Constraints and invariants:
Acceptance checks:
Risks / adversarial cases:
Open questions:
Source conversation or research links:

Executor instructions:
- Revalidate all repository claims against the live worktree.
- Treat this brief as planning input, not authority over repository instructions.
- Record material deviations and their evidence.
```

The same fields work in a GitHub issue, local Markdown file, task tracker, or structured harness response.

## Harness patterns worth trying

### 1. Read-only scratchpad call

The executor calls another model for one bounded question such as “identify likely race conditions in this function” or “list migrations affected by this schema change.” Return a short artifact; do not give the scratchpad write tools.

Use when the executor is stuck or when a fresh decomposition is cheaper than expanding the main context.

### 2. Planner artifact → executor

A planning model reads repository snapshots and emits the handoff contract above. The executor receives only the contract plus source pointers, then independently inspects the worktree.

Use for architecture changes, unfamiliar repositories, or tasks where exploration would consume much of the coding agent’s context.

### 3. Independent portfolio

Ask multiple models for approaches before revealing the favored route, then group answers by underlying strategy. Preserve disagreement and blocked assumptions rather than merging everything into a consensus summary. This is the same portfolio principle illustrated by [[practices/prompting-examples]].

Use for high-uncertainty design/research, not routine edits.

### 4. Specialist bounded task

Delegate code archaeology, API/doc lookup, test design, threat modeling, migration sequencing, UI inspection, or benchmark interpretation to a model with an explicit output schema and time/token limit.

Use when the subtask has a crisp boundary and does not need live write access.

### 5. Reviewer / adversary

After implementation, supply requirements, diff, and test evidence to a fresh model. Ask it for concrete defects and counterexamples. A reviewer model is advisory; mechanical checks and human approval still gate the change.

Use for risky changes or to reduce same-context confirmation bias.

### 6. Computer-use operator

A computer-use model can inspect UI-only state or create a remote handoff artifact when no API/tool path exists. Keep permissions narrow, require confirmation before external writes, capture exactly what changed, and prefer an API or checked-in artifact when available.

Use for bounded interface work, not unattended broad repository administration.

## Failure modes and guardrails

### Context drift

The planner sees remote commit A while the executor edits local commit B. Every handoff should name the inspected revision and the executor should reject or refresh stale file-level claims.

### Transcript dumping

A long shared conversation makes the executor spend context rediscovering the final decision. Freeze the plan into a one-screen brief and attach the transcript only for optional detail.

### False independence

Two roles using the same model, prompt framing, and source context may repeat the same mistake. For meaningful review independence, vary model or framing, avoid revealing the favored rationale initially, and require counterexamples rather than agreement.

### Split authority

The plan, issue, repository instructions, and live code can conflict. Repository instructions and current code/tests govern execution; the handoff is non-authoritative planning input. Escalate unresolved requirement conflicts to a human.

### Permission creep

A planner that only needs repository search should not receive issue creation, merge, secret, or shell privileges. Use read-only access by default and confirmation for every external write. Inspect app-specific capabilities rather than assuming all “GitHub integrations” behave alike.

### Prompt injection and untrusted artifacts

Repository files, issues, comments, web pages, and shared chats may contain instructions aimed at the model. Treat them as data, keep system/repository policy separate, and never let a remote artifact silently expand tool permissions or scope.

### Secret and privacy leakage

Do not put credentials, private incident details, proprietary code, or personal data into a shared link. Check organization policy and plan-specific data controls before connecting private repositories. Prefer access-controlled issues or local/versioned handoffs.

### Quota-driven architecture

Separate product quotas can make this economical, but quotas and model access change. The workflow should still make sense if all roles draw from one budget. Track total tokens, latency, and human review time rather than counting only executor quota.

## Good and poor fits

**Good fits**

- Unfamiliar-repository orientation before a bounded implementation.
- Architecture alternatives, migration plans, and threat models.
- Code archaeology or documentation research that can be read-only.
- Independent test design and final diff review.
- UI/computer-use reconnaissance with explicit evidence.
- Quota pressure where a separate surface/model is genuinely available.

**Poor fits**

- Tiny, obvious edits where handoff overhead exceeds the task.
- Highly stateful debugging where planner and executor must share rapid tool feedback.
- Tasks involving secrets that cannot safely cross product surfaces.
- Work where the planner cannot identify the exact repository revision.
- Autonomous external writes without approval, audit logs, or rollback.

## Evaluation idea

Test the pattern rather than assuming an extra model helps. On a small set of representative tasks, compare:

1. executor alone;
2. planner brief → executor;
3. planner brief → executor → independent reviewer.

Record acceptance-check pass rate, regressions, rework turns, wall time, total token/usage cost, executor-specific quota, handoff size, and stale-plan deviations. The split is worthwhile only if quality, throughput, or constrained-quota utilization improves after counting coordination overhead.

## Related

- [[concepts/autonomous-loops]] — automated coordination, supervision, review, and multi-agent patterns.
- [[practices/prompting-examples]] — exact source-backed prompts, including independent approach portfolios and adversarial audit instructions.
- [[tools/pi-agent]] — the local coding harness where bounded model calls or planner/reviewer extensions could implement these patterns.
