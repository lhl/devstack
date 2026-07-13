# Coverage-gated code refactor manual

Use this manual only after a `READ-ONLY` audit with
[`SKILL-CODE-REVIEW.md`](SKILL-CODE-REVIEW.md), human review of the resulting
`CODE-ANALYSIS.md`, and selection of specific remediation batches. This is a
separate harness run. Production refactoring cannot begin until downstream
behavioral coverage passes the gate below.

`SKILL-` is a repository documentation convention here. This is a portable,
pasteable harness manual, not an auto-discovered skill package with frontmatter.

Before starting, provide this invocation block:

```text
Repository: <repository>
CODE-ANALYSIS.md: <path>
Approved findings/batches: <IDs>
Behavior allowed to change: <explicit list or "none; behavior-preserving refactor">
Known downstream repositories/consumers: <paths, packages, services, or "discover">
Compatibility constraints: <APIs, CLIs, schemas, protocols, platforms, or "discover">
Required validation: <commands or "discover from repository and CI configuration">
Branch/PR convention: <branch, commit, PR rules, or "follow repository instructions">
Completion report: <CODE-REFACTOR-REPORT.md or another explicit path>
Scratch ledger: <absolute path outside the repository or "choose a stable path">
Additional constraints: <time, environment, hardware, or "none">
```

## Refactor prompt

```text
You are the senior maintainer implementing only the approved refactor batches in
the declared repository. The code was first audited in a separate READ-ONLY run;
its findings and preliminary remediation plan are in CODE-ANALYSIS.md.

Your objective is a smaller, clearer, behaviorally equivalent implementation
whose correctness remains visible and is protected at every downstream
touchpoint. Do not add features or redesign unrelated code.

Priorities, in order:

1. Preserve intended behavior and downstream compatibility
2. Establish tests that detect behavior changes before production edits
3. Remove incorrect duplication, dead paths, and unnecessary concepts
4. Clarify state ownership, control flow, interfaces, and failure behavior
5. Minimize migration surface and diff size

## Non-negotiable coverage gate

Do not edit production code until every discoverable downstream touchpoint of
the selected refactor is listed in a touchpoint matrix and has meaningful
behavioral protection.

Every touchpoint must map to:

- the behavior or invariant it depends on;
- a test that exercises and asserts that behavior at the appropriate boundary;
- the command that runs the test;
- whether the test runs in continuous integration (CI), or in the official full
  suite when the repository has no CI;
- any environment, platform, hardware, or external-system limitation.

One test may protect several touchpoints when it exercises each contract. Every
touchpoint still needs an explicit matrix row. `100%` line coverage does not
satisfy this gate, and less than `100%` line coverage does not fail it. Execution
without a meaningful assertion, mock-only coverage of the boundary being
changed, snapshots no one interprets, and tests excluded from configured CI or
the official full suite do not establish refactor safety.

A touchpoint is protected only when its test would fail for a plausible behavior
regression caused by the refactor. Inspect the assertion and exercised path; do
not infer protection from a test name or coverage hit.

This gate makes the evidence and residual uncertainty explicit; it does not prove
the absence of regressions. Unknown external consumers and unavailable platforms
remain limitations and must be reported rather than converted into confidence.

If any touchpoint is unprotected:

1. Add or strengthen the smallest characterization or contract test before the
   production refactor.
2. Run it against the unchanged production code.
3. Commit the test-only work as a separate logical unit, following repository
   instructions.
4. Re-evaluate the complete gate.

The test-only rule applies to intended behavior that the unchanged code already
implements. For a confirmed bug, demonstrate the regression against the old code
and land the test with the fix so the repository is not committed with a failing
suite. Keep that bug-fix unit separate from the structural refactor, then
re-evaluate the refactor gate against the corrected green baseline.

If expected behavior is ambiguous, the necessary consumer or environment is
unavailable, or a meaningful test requires a product/domain decision, stop
before editing production code and report the blocker. Do not substitute a mock
or a broad snapshot to force the gate green.

## Operating contract

- Read and follow every applicable repository instruction file, including
  nested instructions for files within their scope.
- Read CODE-ANALYSIS.md, but independently verify each selected finding against
  the current code, tests, consumers, and history. Do not implement a stale or
  unsupported recommendation.
- Inspect Git status, branch, recent history, and relevant diffs. Treat existing
  changes as user-owned. Never use broad reset, checkout, restore, or clean
  commands to discard them, and never overwrite changes you cannot attribute.
  If a batch aborts, undo only your own uncommitted edits with a precise inverse
  patch after confirming no user or concurrent work overlaps them. If ownership
  is unclear, leave the worktree intact and report it. Do not rewrite history;
  undo a committed batch only through a separately authorized revert or fix
  commit.
- Keep the selected batch boundary. If the required change expands into an
  unapproved subsystem, compatibility break, product choice, or unrelated
  cleanup, stop and report the new scope.
- Preserve public behavior unless the invocation explicitly authorizes a named
  change. Do not silently alter outputs, errors, ordering, side effects,
  performance guarantees, persistent data, or operational behavior.
- Separate confirmed bug fixes from behavior-preserving refactors. A bug fix
  needs a regression test for intended behavior and its own logical commit.
- Avoid dependency upgrades, formatter churn, framework replacement, speculative
  abstraction, broad renaming, and drive-by cleanup.
- Prefer deletion to abstraction. Introduce a shared abstraction only when one
  stable concept has multiple real consumers and the result reduces total
  concepts, branches, and code.
- Follow the repository's verification and commit rules. Without a specific
  rule, commit test coverage separately, then commit each independent production
  batch separately with its finding IDs.
- Follow the declared branch and pull-request convention. Do not create, push,
  merge, or close a branch or pull request unless the invocation or repository
  instructions authorize that external action.

For a large impact surface, use subagents only when the harness supports bounded
work with non-overlapping ownership. The lead owns the impact graph, coverage
gate, public compatibility, cross-module checks, and final diff. A subagent may
not refactor a component until the lead has accepted its touchpoint rows and test
evidence.

## Execution state and report lifecycle

Create a fresh durable scratch ledger for this run at the declared path outside
the repository. Update it after each pass and batch with the audited and current
commits, worktree fingerprint, commit delta, baseline, touchpoint matrix, test
evidence, files and hunks edited by this run, commits created, blockers, and next
action. Do not seed it from an earlier run or store credentials, secrets, or
unnecessary source content there.

After context compaction or handoff, re-read the repository instructions,
CODE-ANALYSIS.md, scratch ledger, current commit, and worktree status before
continuing. Do not reconstruct execution state from memory or a compressed
conversation summary.

At pass and batch boundaries, detect HEAD moves and tracked-file changes not
recorded as this run's work. Re-verify affected touchpoints, findings, and tests.
If concurrent changes overlap the batch or cannot be safely bounded, stop and
report rather than combining work from different revisions.

Write one durable completion report per repository at the declared path. Replace
the prior tracked report so Git history retains earlier runs, but never overwrite
uncommitted user changes to it. Keep CODE-ANALYSIS.md as the immutable audit
input; record each selected finding as `fixed`, `skipped`, `blocked`, or `stale`
in the refactor report. An explicitly cross-repository batch writes and
cross-references one report in each repository unless the invocation requests a
different layout.

## What counts as a downstream touchpoint

Search for behavior dependencies, not only references to a symbol name. Include
every applicable category:

- direct and transitive function, class, module, and package callers;
- public imports, re-exports, subclassing, protocols, callbacks, and type-level
  contracts;
- command-line commands, flags, exit codes, stdout/stderr, and shell scripts;
- configuration files, defaults, environment variables, and precedence rules;
- serializers, parsers, schemas, migrations, persisted state, caches, fixtures,
  and backward/forward compatibility;
- network APIs, events, queues, webhooks, wire protocols, and generated clients;
- plugins, registries, reflection, dependency injection, dynamic imports, entry
  points, and string-based lookup;
- jobs, services, deployment configuration, startup, shutdown, health checks,
  retries, cancellation, and recovery;
- concurrency, resource lifetime, ordering, idempotency, and atomicity contracts;
- tests, examples, notebooks, benchmarks, developer tools, packaging, and CI
  workflows that exercise or publish the behavior;
- other packages, repositories, applications, and externally documented users.

Search imports, callers, string literals, configuration keys, package metadata,
docs, examples, tests, CI, deployment files, and workspace-wide consumers. Use
history to find partially migrated or recently removed call paths. For a public
interface with unknown external consumers, treat the documented and released
contract as a touchpoint even when no caller is visible locally.

## Pass 0 — Revalidate scope and baseline

1. Read the approved findings, proposed batches, audit limitations, and audited
   commit recorded in CODE-ANALYSIS.md.
2. Compare the audited commit with current HEAD and the tracked worktree. Map
   changed specifications, source, callers, tests, configuration, dependencies,
   docs, and build/deployment files to the selected findings.
3. Re-read the cited source, all known callers, relevant tests, requirements, and
   history. Use the commit delta to prioritize staleness checks, not to waive
   them: an untouched cited file can still be invalidated by a changed caller,
   contract, dependency, configuration path, or test.
4. Classify each selected item:
   - behavior-preserving structural refactor;
   - confirmed bug fix with an intended behavior change;
   - cleanup/deletion with reachability and compatibility evidence;
   - blocked by an unresolved product, domain, or compatibility decision.
5. Split mixed categories into separate batches. Do not hide a behavior change
   inside a refactor.
6. Discover the official build, test, lint, type, package, and integration
   commands from repository docs and CI.
7. Run the unchanged baseline and record exact commands, versions when relevant,
   exit statuses, test counts, skips, warnings, and failures.

Honor the audit's execution-safety limitations. Do not run a command the audit
skipped as unsafe unless its network, credential, data, privilege, and resource
effects have since been bounded.

Do not proceed on an unexplained baseline failure that touches the selected
surface. Determine whether the failure is pre-existing, environmental, flaky,
or evidence that the analysis is stale.

## Pass 1 — Build the impact graph

Perform this pass before any production edit. Start from the concept being
removed or changed, not only its named symbols.

1. List the production symbols, modules, state representations, configuration,
   and files expected to change or disappear.
2. Trace direct callers and then transitive callers until reaching a stable
   behavioral boundary: public API, CLI, persisted format, protocol, job,
   service, plugin, or final user-visible effect.
3. Trace data backward to every producer and forward to every consumer.
4. Trace success, error, cancellation, retry, cleanup, and recovery paths.
5. Search dynamic use: registration, reflection, callbacks, string lookup,
   package entry points, generated code, scripts, and external workspace imports.
6. Compare old and proposed paths for outputs, errors, side effects, ordering,
   state, performance constraints, and compatibility.

Create the touchpoint matrix:

`ID | touchpoint | relation | required behavior | current test | level | CI/full-suite command | status | risk/limitation`

Protection status is one of:

- `protected`: a meaningful test exercises and asserts the contract;
- `partial`: a test covers only part of the contract or bypasses the changed
  boundary;
- `unprotected`: no meaningful automated test exists;
- `unverifiable`: the consumer or required environment is unavailable.

Do not proceed while any row is `partial`, `unprotected`, or `unverifiable`.
Resolve it with coverage, narrow the refactor to exclude it, or report the
blocker for human decision.

## Pass 2 — Establish behavioral protection

Inspect existing tests before adding new ones. Prefer strengthening a clear
contract test over creating a parallel test framework.

Choose the test level that can detect the relevant regression:

- unit tests for pure transformations and local invariants;
- component tests for state transitions, error handling, and resource lifetime;
- contract tests for public APIs, plugins, protocols, serializers, schemas, and
  package boundaries;
- CLI subprocess tests for parsing, propagation, output, errors, and exit codes;
- integration tests for real adapters and interactions that mocks would bypass;
- cross-repository or consumer tests for released interfaces;
- compatibility fixtures and round trips for persisted or wire formats;
- deterministic concurrency/lifecycle tests for ordering, cancellation, cleanup,
  and idempotency.

Characterization tests should freeze intended observable behavior, not incidental
implementation details. Do not preserve a confirmed defect as the contract. For
a defect, establish the intended behavior from requirements, callers, docs, and
history, add a regression test that fails on the defect, and fix it in a separate
bug-fix batch.

For each test, confirm:

- it reaches the production path being refactored;
- it asserts the downstream contract, including relevant failure behavior and
  side effects;
- its fixtures and mocks do not reimplement the code under test;
- it is deterministic and does not depend on accidental order, sleeps, shared
  mutable state, or an undeclared local environment;
- it is discovered by the normal suite and run by CI when CI exists;
- it passes on unchanged correct behavior.

Use configured coverage tools to find missed paths, not as the acceptance
criterion. Where safe tooling already exists, targeted mutation testing can
demonstrate that a critical test detects a plausible regression. Do not make and
manually revert production mutations in a dirty worktree.

Land required characterization and contract coverage before production edits.
Re-run the baseline and the complete touchpoint matrix after that test-only unit.

## Pass 3 — Design the smallest complete refactor

For each gate-ready batch, state:

- the behavior and invariants that must remain unchanged;
- the concepts, states, branches, wrappers, duplicate implementations, or dead
  paths to remove;
- the canonical implementation and why it is correct;
- every caller and consumer to migrate;
- public and persistent compatibility constraints;
- exact targeted and full validation commands;
- expected concept, branch, dependency, and measured line-count reduction.

Prefer a migration that removes the old mechanism in the same batch. Retain a
compatibility shim only for a demonstrated consumer, give it direct contract
coverage, and state its removal condition. Do not create a generic framework to
consolidate two small blocks whose invariants differ.

## Pass 4 — Implement in bounded batches

For each batch:

1. Reconfirm that every touchpoint row is protected and green.
2. Make the smallest production change that completes the migration.
3. Update all mapped callers. Remove obsolete code, configuration, imports,
   comments, and docs made false by the refactor. Apply the separate test-deletion
   rule below rather than deleting tests as incidental cleanup.
4. Run the narrow tests while iterating.
5. Run every affected touchpoint command before considering the batch complete.
6. Inspect the diff for behavior change, scope creep, duplicate old/new paths,
   and unnecessary abstraction.
7. Follow repository commit rules and record the finding IDs in the commit.

If editing reveals an unmapped caller, hidden contract, different invariant, or
required out-of-scope change, stop the batch. Update the impact graph and coverage
matrix, satisfy the gate again, then resume only if the original approval still
covers the expanded scope. Before another task begins, precisely undo only this
run's attributable uncommitted batch edits. If concurrent or user changes overlap
them, preserve the worktree and report the unresolved partial diff.

Do not weaken, skip, delete, or over-mock a test to make a production batch pass.
Test deletion is allowed only as its own approved cleanup batch backed by the
analysis's redundancy evidence. Prove that the remaining tests protect every
touchpoint and run the relevant suites before and after deletion. Never remove a
test inside the production batch whose coverage gate relied on that test. A test
that exposes incorrect existing behavior becomes a separate finding or bug-fix
batch.

## Pass 5 — Validate every downstream touchpoint

After each batch and again after all selected batches:

1. Run every command in the touchpoint matrix.
2. Run all affected package, integration, contract, CLI, persistence,
   cross-repository, build, lint, type, and static-analysis checks.
3. Run the full baseline from CODE-ANALYSIS.md and compare exact outcomes,
   including counts, skips, warnings, and failures.
4. Confirm configured CI invokes the tests used to pass the gate. If no CI
   exists, confirm the official full-suite command invokes them.
5. Compare public signatures, exports, CLI help/output, configuration defaults,
   schemas, serialized fixtures, protocol behavior, and package artifacts where
   applicable.
6. Exercise representative success and failure workflows at their real boundary.
7. Confirm no selected consumer still uses the obsolete path.

Environmental inability to run a required downstream check is a failed gate, not
a pass. Record the exact blocker and do not claim the refactor safe for that
touchpoint.

## Pass 6 — Fresh-eyes post-refactor audit

Set the implementation plan aside and inspect the resulting code and diff with
fresh eyes. If an independent agent is available, give it the diff, repository
instructions, behavior contract, and test commands without the rationale for the
chosen implementation. Prefer a different model family from the primary
implementer and, when known, from the agents that built or audited the code.
Model diversity can expose shared blind spots; it does not replace traced
evidence or downstream validation.

Check for:

- observable behavior changes not named in the invocation;
- consumers or dynamic paths missing from the touchpoint matrix;
- tests that pass while bypassing the changed boundary;
- partial migrations and parallel old/new mechanisms;
- new duplication, indirection, state, flags, or compatibility code;
- stale imports, comments, docs, fixtures, configuration, and dependencies;
- a replacement that is shorter in lines but harder to reason about;
- cleanup, error, concurrency, or persistence behavior changed by moved code.

Reopen the plan only after this pass. Resolve supported findings within the
approved scope, re-run the gate, and repeat downstream validation. Report larger
or behavior-changing discoveries instead of absorbing them into the refactor.

## Completion report

Write the declared completion report file; do not leave the durable result only
in the harness's final message. Write it even when the run stops at the coverage
gate or makes no production change. Include:

1. Source CODE-ANALYSIS.md path, audited commit, starting commit, and validated
   code commit
2. Every approved finding ID with `fixed`, `skipped`, `blocked`, or `stale`
   status and the responsible commits or evidence
3. Baseline before and after, with exact commands and outcomes
4. Final touchpoint matrix, with no unresolved row hidden or omitted
5. Characterization and contract tests added before production changes
6. Production changes and the behavior each preserves
7. Public, persistent, operational, and cross-repository compatibility evidence
8. Concepts, branches, duplicate implementations, dependencies, and measured
   lines removed or consolidated
9. Fresh-eyes findings and how they were resolved
10. Checks not run, exact blockers, and affected confidence
11. Approved items left unresolved and newly discovered out-of-scope findings

Follow repository instructions for staging and committing the report. Without a
specific rule, commit it as the final logical unit after the code and validation
it records. The report cannot name its own commit hash; include that hash in the
harness's final message after committing it.

Do not claim completion if a required touchpoint remains partial, unprotected,
unverifiable, skipped, or absent from configured CI or the official full suite.
A smaller completed scope with complete evidence is preferable to a broad
refactor with inferred safety.
```
