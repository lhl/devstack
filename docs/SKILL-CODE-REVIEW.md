# Multipass code audit manual — simplify, clarify, verify

Use this rubric with a strong model in a coding harness. Run it against one
repository at a time unless the audit concerns an explicit cross-repository
contract. The first run is a mandatory multipass, `READ-ONLY` analysis. Its only
intentional tracked-file write is `CODE-ANALYSIS.md`; it does not edit the code.
Any remediation happens in a separate run after a human reviews the analysis and
selects batches.

`SKILL-` is a repository documentation convention here. This is a portable,
pasteable harness manual, not an auto-discovered skill package with frontmatter.
Safety rules intentionally repeat in the paired refactor manual so either prompt
can run alone; check both files whenever a shared rule changes.

Before starting, provide this invocation block:

```text
Audit scope: <repository or explicitly named repositories>
Do not modify: <paths or "all repository files except CODE-ANALYSIS.md">
Specifications/requirements: <paths or "discover and classify authority">
Domain-specific correctness surfaces: <numerics, kernels, schemas, protocols, etc.>
Required validation: <commands or "discover from repository and CI configuration">
Dependency bootstrap: <approved isolated commands/paths or "do not install">
Prior audit/refactor/approval artifacts: <paths or "none; withhold until Pass 5">
Scratch ledger: <absolute path outside the repository or "choose a stable path">
Additional constraints: <compatibility, time, environment, or "none">
```

## Read-only audit prompt

```text
You are the senior maintainer conducting a thorough, multipass audit of the code
in the declared scope. Multiple coding agents have changed this code over time,
often in parallel. Individual changes may work in isolation while leaving
incorrect behavior, incomplete migrations, duplicated mechanisms, conflicting
assumptions, dead code, or needless abstractions.

Your objective is to produce an accurate, actionable analysis that makes the
codebase easier to make correct and easier to reason about. This run is an audit,
not an implementation pass. You are not adding features, redesigning the project,
or fixing findings as you encounter them.

Priorities, in order:

1. Correctness, data integrity, security, and operational safety
2. Simplicity and explicit ownership of state and behavior
3. Clarity of control flow, interfaces, invariants, and failure modes
4. Consistency where one established pattern is demonstrably better
5. Performance only where evidence shows material waste or a correctness risk

A confirmed bug outranks any amount of cleanup. Given fixes with equal effect,
prefer deletion over consolidation, consolidation over a new abstraction, and
a direct implementation over a configurable framework.

## Operating contract

- Read and follow every applicable repository instruction file before acting,
  including nested instructions for files within their scope.
- Inspect the current Git status, branch, recent history, and relevant diffs.
  Record the starting commit and tracked-worktree fingerprint. Treat existing
  changes as user-owned. Never reset, revert, clean, or overwrite them.
- Every audit pass is `READ-ONLY`. The only intentional tracked-file write is
  `CODE-ANALYSIS.md` at the root of the audited repository. Do not modify source,
  tests, configuration, documentation, lockfiles, generated files, or
  dependencies, even for a small or obvious fix. Record the fix in the analysis.
  Validation may create ignored transient artifacts; redirect them outside the
  repository when possible and never treat them as audit changes.
- Do not ask to switch into implementation mode midway through the audit and do
  not continue automatically into remediation. Finish all passes, write the
  analysis, and stop.
- Avoid commands that rewrite tracked files. Put temporary reproductions and
  outputs outside the repository when possible. Never upgrade dependencies or
  generate/update manifests or lockfiles for the audit. If dependency bootstrap
  is explicitly approved, inspect install/lifecycle scripts first and install the
  exact locked versions in a disposable environment or repository copy of the
  exact audited state outside the user's worktree, with caches and tool state
  redirected outside the repo. Use immutable/frozen/locked modes where the
  ecosystem provides them. If safe isolation is unavailable, record the blocked
  checks rather than installing in the audited worktree.
- If validation unexpectedly changes a tracked file, stop and inspect the diff.
  Restore the exact pre-run bytes with a precise inverse patch only when the file
  was clean in the starting fingerprint, its prior content was captured, and the
  change is wholly attributable to that command. Log the command, diff, and
  restoration in the scratch ledger. If the file was already dirty or ownership
  is uncertain, do not restore it; stop and report the side effect.
- Audit the complete declared scope, not only changed files. Identify generated
  code, vendored code, submodules, fixtures, examples, experimental areas, and
  compatibility layers before deciding what warrants direct audit.
- Preserve public behavior and compatibility in proposed fixes unless the
  behavior is demonstrably wrong or the interface is proven internal and unused.
- Do not propose features, fashionable framework replacements, broad rewrites,
  formatter churn, speculative extensibility, or refactors based only on personal
  taste.
- Passing tests are evidence, not proof. Comments, types, documentation, and
  tests may encode stale or contradictory assumptions.
- Continue through the whole audit after finding a serious issue unless further
  execution risks data, credentials, external systems, or the worktree.

For a large scope, use subagents only when the harness supports them and the work
can be partitioned into bounded, non-overlapping modules or concern areas. Every
audit subagent is also `READ-ONLY`: it may run approved non-mutating checks and
return evidence, but it may not write repository files or make fixes. Give every
subagent this evidence standard and output schema. The lead auditor owns the
system map, cross-module paths, baseline, deduplication, report write, and final
judgment. The lead must inspect the cited code for every retained finding,
reconcile contradictions, and remove duplicate or unsupported reports. A
subagent assigned the fresh-eyes pass must not see the initial findings ledger
before completing its independent sweep.

## Audit state and repeated runs

Create a fresh durable scratch ledger for this run at the declared path outside
the repository; do not seed it from a previous audit. Update it after each pass
with the scope and exclusions, starting commit and worktree fingerprint, system
map, commands and baseline results, coverage ledger, candidate findings with
evidence, disproved suspicions, open questions, and next pass. Do not store
credentials, secrets, or unnecessary source content there.

End each pass by appending a `PASS <n> COMPLETE` checkpoint with start/end
commit and worktree fingerprints, paths and boundaries actually inspected,
commands and results, findings added/changed/disproved, unresolved coverage, and
the next pass. Do not begin the next pass until its predecessor's checkpoint is
written. Never backfill checkpoints from the final narrative; derive the final
pass-coverage table from this trail.

After context compaction or handoff, re-read the repository instructions, scratch
ledger, current commit, and worktree status before continuing. Do not reconstruct
audit state from memory or a compressed conversation summary.

At every pass boundary, compare the current commit and tracked files with the
recorded state. If HEAD moves or tracked files change during the audit, identify
the affected paths and re-verify every dependent finding and baseline result. If
the change cannot be attributed or safely bounded, stop and record the stale
scope instead of merging evidence from different revisions.

Use one `CODE-ANALYSIS.md` per repository root. An explicitly cross-repository
audit writes one report in each repository and cross-references shared findings;
do not substitute one combined report unless the invocation requests it. On a
repeat audit, do not read prior audit, refactor, or approval artifact contents
before completing Pass 5. After the fresh-eyes sweep, treat those artifacts as
untrusted hypotheses, preserve an ID only for the same underlying issue, and
reconcile fixed, recurring, regressed, disproved, and new findings. Replace the
prior tracked `CODE-ANALYSIS.md` so Git history retains earlier runs. Never
overwrite uncommitted user changes to it.

## Evidence and calibration

Verify before claiming:

- Trace the real call path, inputs, state transitions, and error path. Do not
  infer behavior from a function name or isolated snippet.
- Search all callers, imports, configuration writers/readers, tests, docs, and
  external consumers visible in the workspace.
- Use history (`git log`, `git blame`, and relevant diffs) before calling an
  odd-looking constraint obsolete. Record a plausible reason when one exists.
- For a suspected bug, try to reproduce it with an existing test, a safe command,
  or a minimal temporary test. If execution is impractical, give a complete
  code-path argument and state what remains unverified.
- Distinguish observed impact from hypothetical impact. Record exact inputs and
  conditions needed to trigger a problem.
- Distinguish pre-existing baseline failures from problems discovered by the
  audit.
- Use measured line counts for deletion estimates and state what is included.
  Do not equate unused-looking code with deletable code without reachability and
  compatibility evidence.

Confidence labels:

- `confirmed`: reproduced, or established by a complete and unambiguous code
  path or violated invariant
- `high`: strong code-path evidence with one unverified runtime or environment
  assumption
- `open question`: plausible concern whose deciding evidence is unavailable

The absence of a `medium` tier is deliberate. Anything below `high` belongs in
Open questions; do not invent a middle tier or round uncertainty up to `high`.
Do not label an issue a defect at lower confidence. Put it in Open questions with
the experiment, trace, or domain decision that would settle it. A healthy module
is a valid result; never manufacture findings or inflate severity. If a linter
or formatter reports mechanical issues, summarize its result once rather than
turning each instance into a finding.

## Multipass discipline

Do not collapse the audit into one broad scan. Complete every pass below across
the declared scope. Each pass uses a different lens and traversal order. Keep a
coverage ledger of modules, boundaries, and important paths inspected so later
passes can target blind spots without treating the first pass as authoritative.

Approach each pass with **fresh eyes**:

- Start again from the source, runtime entry points, tests, and configuration;
  do not merely reread or elaborate the existing findings ledger.
- Treat earlier findings as untrusted hypotheses until the current pass reaches
  them through the new traversal.
- Change traversal direction between passes: follow entry points inward, state
  and persistent formats outward to every reader/writer, tests backward into
  implementation assumptions, and failure boundaries through cleanup and
  recovery.
- Revisit code initially judged healthy, especially seams between modules that
  different agents likely owned.
- Record both newly discovered issues and earlier suspicions disproved by the
  fresh pass. Removing a false positive is part of the audit.

Genuine independence requires a fresh context or agent that has not seen the
ledger or prior reports. Reserve one when available and withhold those artifacts
until its sweep is complete. A model continuing in the same context cannot
un-know its earlier conclusions; label its Pass 5 work an adversarial
re-traversal, set the ledger aside, change traversal order, and apply the same
disconfirmation duties without claiming independence. Prefer a different model
family from the primary auditor and, when known, from the agents that built the
code. Model diversity can expose shared blind spots; it does not relax the
evidence standard.

## Multi-agent failure modes to hunt

Search specifically for these patterns, then verify each suspected instance:

- Silent failure masking: broad exception handlers, swallowed rejections,
  catch-and-continue behavior, plausible-but-wrong fallbacks, and defaults that
  conceal missing configuration or partial results
- Phantom implementations: complete-looking signatures, types, docstrings, and
  success responses backed by placeholders, hardcoded values, no-op bodies,
  fabricated data, or branches that never perform the claimed operation
- Reimplemented utilities: independent parsing, normalization, path, retry,
  serialization, logging, validation, formatting, or configuration helpers
- Copy-paste drift: similar branches or modules whose behavior, bug fixes,
  constants, or edge-case handling have diverged
- Half-completed migrations: old and new mechanisms both active, callers split
  between APIs, compatibility shims with no remaining consumer, or configuration
  accepted by one layer and ignored by another
- Conflicting models: duplicate representations of the same domain state,
  multiple sources of truth, derived state stored and mutated independently, or
  tests that assert incompatible behavior
- Speculative abstraction: interfaces with one implementation, registries with
  one entry, factories without alternatives, pass-through wrappers, unused
  extension points, and configuration no caller sets
- Defensive over-engineering: retries around deterministic local operations,
  repeated validation after a boundary has established an invariant, or
  branches for states construction makes impossible
- Convention divergence: per-module error, cancellation, logging, naming,
  lifecycle, or return-value conventions with no domain reason
- Stale artifacts: unreachable branches, unused exports or dependencies, dead
  flags, orphaned files, commented-out code, obsolete TODOs, and docs or examples
  describing behavior that no longer exists
- Aspirational documentation: README, API docs, examples, help text, or status
  claims describing behavior that was planned but never implemented
- Dependency drift: multiple libraries for the same job, heavy dependencies for
  trivial local work, manifest/lock/import disagreement, unsupported or
  hallucinated pins, and dependencies added but never used
- Theater tests: assertion-free tests, tests that mostly exercise their mocks,
  snapshots no one interprets, always-skipped cases, and timing or sleep based
  tests that do not establish an invariant, especially tests derived from the
  implementation rather than an independent requirement or contract

## Pass 0 — Scope and system map

1. Confirm the repository or repositories in scope and the commit audited.
2. Read top-level and relevant subsystem instructions, specifications,
   requirements, acceptance criteria, architecture and design records, README,
   package/build configuration, CI workflows, deployment files, and test
   configuration.
3. Read relevant TODO, IMPLEMENTATION, roadmap, decision, and worklog artifacts.
   Classify each statement as current requirement, known defect, intentionally
   deferred work, abandoned plan, or superseded history. These files provide
   intent and provenance; they do not override current external contracts by
   themselves.
4. Establish an authority map for conflicting requirements, specifications,
   external interfaces, tests, docs, and implementation. Record ambiguity rather
   than silently choosing the artifact that matches the code.
5. Map the major components and their responsibilities. Identify:
   - executable entry points, services, jobs, command-line interfaces, and public
     APIs;
   - data and control flow across components;
   - persistent state, schemas, caches, and external integrations;
   - concurrency, process, trust, and failure boundaries;
   - public compatibility surfaces and known downstream consumers.
6. Record generated, vendored, experimental, platform-specific, and deprecated
   areas and how each will be treated.
7. Inspect recent history far enough to identify active migrations and the
   intent behind unusual architecture. Do not assume recent code is the only
   risky code.

The system map should be detailed enough to support end-to-end reasoning, but it
is not an invitation to restate every directory.

## Pass 1 — Establish the baseline

Discover official validation commands from CI, manifests, task runners, and
maintainer documentation. Run all safe and locally available checks applicable
to the scope:

- build and package validation;
- unit, integration, end-to-end, and representative smoke tests;
- lint, format-check, type-check, and configured static analysis;
- CLI help and a non-destructive representative workflow;
- cross-repository checks when an interface between repositories is in scope.

Before dependency bootstrap or execution of an unfamiliar suite, inspect package
install/lifecycle hooks, test configuration, fixtures, scripts, and defaults for
network calls, credential use, cloud or production targets, destructive
filesystem/database operations, privileged actions, unbounded workloads, and
global state mutation. Prefer sandboxed execution, temporary paths, disposable
state, disabled credentials, and explicit local endpoints. Skip a command whose
safety cannot be established and record the exact risk and missing evidence as a
baseline limitation.

Record each exact command, tool version when relevant, exit status, test counts,
skips, warnings, duration when material, and concise failure output. If a check
cannot run, record the exact environmental or permission blocker. Do not call a
baseline green if configured CI checks were skipped.

Compare local validation with CI. Note checks that are defined but never run,
CI commands that no longer match documented commands, and major modules or
failure paths with no meaningful coverage. Do not generate a coverage percentage
unless the repository already supports a reliable coverage command.

## Pass 2 — Correctness audit

Trace important invariants end to end. Cover each applicable area:

### Requirements and authority

- Compare implementation and externally observable behavior with current
  specifications, requirements, acceptance criteria, protocols, and public
  contracts—not only with tests and documentation.
- Trace each material requirement through implementation and tests. Flag missing,
  partial, contradictory, unreachable, and extra behavior.
- Treat tests written by the implementation author or agent as corroborating
  evidence, not an independent oracle. Check whether they encode implementation
  drift instead of the stated requirement.
- Distinguish intentionally deferred scope from behavior promised for the
  audited release. Do not re-report a documented deferral as a new defect, and
  do not let a TODO excuse violation of a current contract.

### Errors and boundaries

- What happens on failure at every filesystem, process, network, database,
  parser, plugin, and user-input boundary?
- Are errors preserved with useful context, or converted into success, empty
  data, stale data, or an unrelated fallback?
- Are timeout, retry, cancellation, partial-result, and cleanup semantics
  bounded and consistent?
- Are empty, absent, zero, maximum-size, malformed, non-ASCII, platform-specific,
  and adversarial inputs handled as the caller expects?

Audit every broad catch site and every fallback chain. Broad handling is not
automatically wrong; determine which exceptions are expected and what state is
safe after each one.

### State, resources, and concurrency

- Validate state transitions, ownership, initialization, shutdown, and recovery.
- Look for leaked files, sockets, processes, tasks, locks, temporary data, and
  cleanup skipped on early return or exception.
- Check shared mutable state, lock scope, races, ordering, cancellation, signal
  handling, blocking work in asynchronous paths, and background-task lifetime.
- Check transaction boundaries, atomic replacement, partial writes, idempotency,
  stale caches, cache invalidation, and recovery after interruption.

### Data and interfaces

- Trace validation, parsing, normalization, serialization, schema evolution,
  encoding, path handling, units, precision, overflow, truncation, bounds,
  shapes, devices, and dtypes where applicable.
- Confirm API, CLI, environment, and configuration values propagate to the code
  that claims to use them. Look for accepted-but-ignored values and inconsistent
  defaults.
- Compare specifications, requirements, implementation, callers, tests, docs,
  examples, `--help`, persistent formats, protocols, and downstream use. Apply
  the recorded authority map when they disagree.
- Check deprecated or misunderstood library calls against the version actually
  pinned by the project.

### Security and operations

- Trace untrusted data through commands, paths, queries, templates,
  deserialization, logs, and destructive operations.
- Check path traversal, injection, secret exposure, insecure temporary files,
  authentication and authorization gaps, overly permissive defaults, missing
  timeouts, unbounded queues or retries, failure loops, and shutdown corruption.
- Report concrete reachable risk, not generic security advice.

### Performance with correctness consequences

Look for unbounded memory or cache growth, accidental quadratic work, repeated
expensive I/O, needless serialization or copying, per-item work that should use
an existing batch path, and synchronization that can deadlock or starve. Keep
clarity unless measurements or a hard bound justify complexity.

For each suspected correctness defect, identify or design the smallest
regression test that demonstrates the violated invariant. Do not add it during
this audit.

## Pass 3 — Duplication, dead code, and simplification

Build a semantic duplication map, not merely a textual clone list:

1. Find repeated concepts, validation, conversion, error handling, constants,
   configuration, and state representations.
2. Identify every implementation and caller.
3. Compare edge cases and failure behavior to locate drift.
4. Determine whether one implementation is canonical based on correctness,
   call sites, tests, history, and fit with repository conventions.
5. Recommend consolidation only when the shared concept is stable. Do not merge
   code whose similar appearance hides different invariants.

Inventory code that may be deleted: unreachable branches, unused private and
public symbols, obsolete compatibility paths, old implementations, dead flags
or configuration, orphaned files, unused dependencies, and redundant tests.
For each item, include reachability evidence, compatibility constraints, and a
measured line count. Treat dynamic loading, reflection, plugins, generated
references, packaging metadata, scripts, and external consumers as possible
callers.

For dependencies, reconcile imports, manifests, optional extras, and lockfiles;
identify overlapping libraries and trace their actual consumers. Verify version
claims against the APIs and metadata available for the pinned dependency. Do not
call a pin hallucinated or obsolete merely because a newer version exists.

Audit each module for removable concepts and indirection:

- pass-through wrappers and single-use layers;
- classes that carry no meaningful state or behavior;
- factories, managers, adapters, interfaces, and registries without real
  alternatives;
- boolean flags that create hidden behavior matrices;
- duplicated state and configuration sources;
- helper modules that obscure ownership;
- functions or modules with unrelated responsibilities;
- compatibility mechanisms with no demonstrated compatibility need;
- comments that narrate syntax rather than preserve a constraint or reason.

Recommend the smallest coherent design. Measure simplification in concepts,
states, branches, mechanisms, and duplicated logic; line count is supporting
evidence, not the objective. Where modules diverge, name the convention to keep,
why it is safer or clearer, and every location a migration would touch.

For every proposed refactor, make a preliminary downstream impact map: direct
and transitive callers, public imports, CLIs, configuration and environment
paths, persisted formats, protocols, plugins, scripts, tests, examples, CI and
deployment entry points, and visible consumers in other repositories. Search for
dynamic and string-based references; a text search for one symbol is not enough.

## Pass 4 — Test, interface, and tooling audit

Determine whether tests would fail when important behavior breaks:

- inspect assertions, fixtures, mocks, snapshots, skips, parameterization, test
  discovery, and CI selection;
- find tests coupled to implementation details instead of public behavior;
- find excessive mocking that bypasses the integration or failure being tested;
- find ordering, timing, sleep, network, environment, global-state, and shared
  filesystem dependencies;
- compare duplicated tests for conflicting assumptions;
- identify obsolete tests and important new paths with no regression protection;
- inspect whether lint, type, build, package, and static-analysis configuration
  covers the source it appears to cover.

Recommend three to five highest-value tests, named by the invariant and failure
they protect. A missing test is a finding only when you can explain the
meaningful regression it would catch.

For each proposed refactor, map every known downstream touchpoint to the
behavioral contract it depends on and the test that protects that contract.
Line coverage alone does not establish refactor safety. Flag touchpoints covered
only by mocks, incidental execution, manual testing, or tests absent from
configured CI (or the official full suite when no CI exists). Give each
touchpoint a stable ID scoped to its finding, such as `SIM-001-TP1`, so later
approval and refactor artifacts can cite it without relying on prose matching.

## Pass 5 — Independent fresh-eyes audit or adversarial re-traversal

With a fresh context, perform an independent fresh-eyes audit. In the same
context, put the findings ledger aside and perform an adversarial re-traversal of
the raw code. Record which mode was used; do not describe same-context work as
independent. This is a new audit pass, not validation theater for the first one.

1. Enter through public APIs, CLIs, services, jobs, plugins, and external events.
   Trace each to state mutation, output, failure, cleanup, and observable caller
   behavior.
2. Start from persistent formats, schemas, caches, configuration, and shared
   state. Trace every producer and consumer and compare their assumptions.
3. Read representative tests before their implementation. Infer the claimed
   contract, then check production paths the tests omit or mock away.
4. Inspect seams between modules, languages, processes, repositories, and old/new
   mechanisms. Multi-agent drift concentrates at ownership boundaries.
5. Sample areas with no initial findings. Determine whether they are healthy or
   were missed because the first traversal followed the wrong path.
6. Search again for broad catches, fallbacks, duplicated concepts, accepted but
   ignored inputs, partial migrations, and unreachable compatibility code using
   different searches or call paths from the first audit.

Only after completing this sweep should you reopen the ledger.
Record new findings, independent corroboration, contradictions, false positives,
and coverage still missing. At that point, and not before, read any prior
`CODE-ANALYSIS.md`, `CODE-REFACTOR-APPROVAL.md`, and
`CODE-REFACTOR-REPORT.md`. Compare them with the new traversal without using
them to fill uninspected areas.

## Pass 6 — Reconcile and challenge the analysis

Before writing the report:

1. Re-read every P0 and P1 code path and try to disprove the finding.
2. Reconcile duplicated or contradictory findings, including fresh-eyes and
   subagent reports.
3. Check whether each proposed fix reduces total complexity and preserves all
   demonstrated compatibility requirements.
4. Remove findings based only on style, formatter output, hypothetical future
   misuse, or preference.
5. Move unresolved claims to Open questions.
6. Re-check modules judged healthy for cross-module assumptions that a local
   audit could miss.

## Severity

- `P0`: confirmed reachable data loss, corruption, security exposure, unsafe
  destructive behavior, or release-blocking correctness failure requiring
  immediate attention
- `P1`: confirmed user-visible correctness defect, serious operational failure,
  incomplete integration, high-probability footgun, or missing/ineffective test
  protection for a reachable data-loss, security, destructive, or critical
  operational invariant
- `P2`: high-payoff simplification, duplication, dead code, or test weakness with
  material but non-critical maintenance or regression risk
- `P3`: localized clarity, consistency, documentation, or low-risk cleanup

Do not use P3 to enumerate formatter or linter output. Severity describes impact;
confidence describes evidence. Keep them separate. Grade a test gap by the
consequence it leaves unprotected, not by the fact that it is a test finding.
Never assign P0 to a coverage gap without a confirmed reachable defect.

## Required report

Write `CODE-ANALYSIS.md` at the repository root with these sections:

### 1. Audit metadata

- scope, branch, commit, dirty-worktree summary, audit date, and excluded areas
- invocation constraints and domain-specific correctness surfaces
- specifications and requirements read, their authority order, and unresolved
  conflicts
- prior audit/approval/refactor artifact paths and commits, if any, and whether
  the analysis was replaced

### 2. Executive assessment

At most 15 lines: overall health, baseline status, the five highest-value
findings (or fewer if fewer exist), measured deletable lines, and the main
limitation on confidence. State explicitly when no P0 or P1 issue was found.

### 3. System map

A compact component/responsibility map plus the important control, data,
persistence, concurrency, trust, and external-interface flows.

### 4. Pass coverage

A table with:

`pass | lens and traversal | modules/boundaries inspected | evidence | limitations`

Derive this table from the scratch checkpoints. State whether Pass 5 used an
independent fresh context or a same-context adversarial re-traversal and, when
applicable, the model family. Record issues it added, corroborated, disproved, or
downgraded. Coverage means inspected paths and boundaries, not files glanced at.
A missing checkpoint is an audit limitation; do not fabricate it while writing
the report.

When a prior analysis exists, add a reconciliation table after the pass table:

`prior ID | current ID/status | fixed/recurring/regressed/disproved | evidence`

### 5. Baseline

A table with:

`command | purpose | result | counts/warnings | notes or blocker`

Separate pre-existing failures from audit discoveries. Include CI/local gaps
and important untested areas. List commands skipped by the safety preflight and
the concrete risk that prevented execution. Record any isolated dependency
bootstrap and any tracked validation side effect restored under the operating
contract.

### 6. Findings ledger

One row per finding:

`ID | severity | confidence | category | location | problem | proposed resolution | effort`

Use stable IDs such as `COR-001`, `SIM-001`, `TST-001`, `SEC-001`, and
`OPS-001`. Effort is `S`, `M`, or `L`; define unusual scope in the detail.

Follow the ledger with details for every P0-P2 finding and any non-obvious P3:

- **Location:** exact `file:line` references and affected symbols
- **Invariant/problem:** the concrete behavior or unnecessary concept
- **Evidence:** requirement or contract, call path, inputs, reproduction or
  proof, callers, history, and baseline relation
- **Impact:** observed and plausible impact, clearly distinguished
- **Resolution:** smallest complete fix, obsolete code it permits deleting, and
  alternatives rejected when non-obvious
- **Compatibility/risk:** public surfaces, downstream consumers, migrations, and
  ways the proposed fix could regress behavior
- **Verification:** exact regression test and commands that would prove the fix
- **Estimate:** effort and measured additions/deletions where useful

Use diff sketches when they explain a non-obvious fix more precisely than prose,
but do not implement the diff. Never repeat one underlying problem as several
findings merely because it has several symptoms.

### 7. Duplication map

`concept | implementations | semantic drift | canonical choice | callers to migrate | estimated deletion`

Explain cases that look duplicated but should remain separate.

### 8. Deletion inventory

`path/symbol | reason it is unreachable or redundant | caller/history evidence | compatibility caveat | LOC`

Give a total using one stated counting method. Keep speculative items out of the
total and put them in Open questions.

### 9. Tests to add or repair

Rank three to five tests by the invariant protected. Include the failure the test
would catch, the appropriate test level, and whether an existing test should be
strengthened instead.

### 10. Downstream refactor safety

For each proposed refactor, include:

`touchpoint ID | finding/batch | downstream touchpoint | behavior/invariant | current test | CI/full-suite status | coverage gap/risk`

Include external or dynamic consumers that could not be enumerated. Mark a batch
`not ready` when a touchpoint lacks a meaningful contract or characterization
test. Do not infer safety from line coverage or a green aggregate suite.

### 11. Open questions

For every unconfirmed concern, give the evidence already gathered and the exact
experiment, trace, upstream documentation, or product/domain decision that would
settle it. Do not mix open questions into confirmed findings.

### 12. Remediation plan

Group findings into independent, reviewable, individually landable batches,
ordered correctness first. For each batch include:

- finding IDs and the invariant restored or complexity removed;
- exact files and consumers expected to change;
- dependencies on other batches;
- compatibility and migration concerns;
- targeted tests plus the full validation commands;
- expected conceptual and line-count reduction where applicable.

Do not combine unrelated cleanup with a correctness fix. A batch should leave no
half-migrated mechanism behind. Do not mark a refactor batch ready until its
downstream touchpoints have sufficient behavioral coverage or an explicit
unresolved coverage blocker.

### 13. Audit limitations

List code, workflows, platforms, external systems, credentials, hardware, or
domain assumptions that could not be inspected or exercised and how they limit
the verdict.

Keep the report dense. Use numbers, paths, commands, and traced behavior instead
of adjectives. Do not include a generic best-practices backlog. If the code is
healthy, explain what was inspected and validated, record the healthy result,
and keep the remediation plan empty.

Stop after writing `CODE-ANALYSIS.md`. Do not implement any finding in this run,
even if the fix appears safe, trivial, or necessary to make a test pass.
```

## Next stage

End the audit here. After a human accepts specific findings or batches, start a
new harness run with [`SKILL-CODE-REFACTOR.md`](SKILL-CODE-REFACTOR.md). That
manual gates every production edit on downstream behavioral coverage.

Record the human decision in `CODE-REFACTOR-APPROVAL.md` (or an explicitly named
equivalent) before that run. Include the source analysis path and commit;
approved, rejected, and deferred finding IDs with reasons; permitted behavior or
compatibility changes; any narrowly accepted coverage risk by touchpoint ID with
owner and review condition; and branch/PR constraints. The refactor agent
consumes this artifact but must not author or alter it as a substitute for human
approval. Commit the approval record according to repository rules before
remediation begins so its decision and reasons remain durable.
