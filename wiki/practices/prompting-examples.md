---
title: Prompting Examples
tags: [llm, prompting, multi-agent, research, proof-search]
sources:
  - sources/papers/openai-2026-cycle-double-cover-prompt.pdf
links:
  - https://cdn.openai.com/pdf/04d1d1e4-bc75-476a-97cf-49055cd98d31/cdc_prompt.pdf
---

# Prompting Examples

Source-backed prompts worth keeping as concrete references. Each example should preserve the original prompt, identify the intended model or harness, separate source claims from our interpretation, and note which instructions are portable.

## GPT 5.6 Sol Ultra — Cycle Double Cover proof search

**Source context:** OpenAI's two-page PDF, *Prompt Used for “A Proof of the Cycle Double Cover Conjecture,”* describes the text below as the full prompt given to **GPT 5.6 Sol Ultra** and says it led to a proof of the Cycle Double Cover Conjecture. That model label and outcome are claims made by the PDF; we have not independently verified the run configuration or proof. The archived PDF has SHA-256 `0e48deee28caba82ee5b4191d4c5c6ec4d62e5d27890fa7f0d2c8868f8b758f3`.

### Extracted prompt

Verbatim text from the source, with PDF line wrapping normalized and page furniture removed:

```text
Current task statement

A graph here is a finite loopless undirected multigraph: parallel edges are allowed and are distinct. A bridge is an edge whose deletion increases the number of connected components. A cycle is a connected 2-regular submultigraph; thus two parallel edges form a cycle of length two. A cycle double cover of G is a finite multiset of cycles of G such that every edge of G occurs in exactly two members of the multiset, counted with multiplicity.

Resolve the Cycle Double Cover Conjecture completely:

Every finite bridgeless loopless multigraph has a cycle double cover.

Disconnected graphs are permitted, and the edgeless graph has the empty cycle double cover. Cycles in the cover need not be induced or edge-disjoint from one another; the requirement is exactly two total occurrences of each edge.

Assume for purposes of this task that a complete affirmative proof exists. A complete solution must prove exactly the following:

Every finite loopless multigraph with no bridge possesses a cycle double cover, without additional assumptions such as cubicity, planarity, connectivity, or higher edge-connectivity.

Partial progress does not count unless it implies exactly the resolution above. In particular, proofs for special graph classes, constructions of cycle covers with some edges covered other than twice, bounded-length or prescribed-cycle variants, reductions to another unproved conjecture, computational verification through any fixed graph size, and candidate counterexamples without a complete nonexistence certificate are insufficient.

Use multiagent v2 aggressively and dynamically. You have up to 64 concurrent agents available. Do not use a fixed assignment such as “N agents for strategy X.” Instead, manage the search using the following heuristics:

- Begin with a genuinely diverse portfolio of approaches. Agents should explore substantially different formulations, invariants, reductions, algebraic viewpoints, structural inductions, decompositions, flow formulations, transition systems, embeddings, extremal arguments, and computational sanity checks.

- Do not tell most agents the currently favored approach. Preserve independence during early rounds so that agents do not all converge to the same attractive but incomplete reduction.

- Maintain an explicit registry of approach families. Group agents by the mathematical idea they are using, not by superficial wording. If many agents converge to one family, redirect some of them toward underexplored formulations.

- Do not allow one approach to dominate merely because it gives elegant reductions. A route that ends at a lemma equivalent in strength to the original conjecture is not close to completion unless it supplies a genuinely new proof of that lemma.

- When an approach stalls at a theorem-strength missing lemma, mark that route as blocked. Only continue assigning agents to it if someone proposes a materially new mechanism, invariant, or construction.

- Keep several incompatible proof routes alive through multiple rounds. Cross-pollinate ideas only after independent agents have developed them far enough to expose their real strengths and gaps.

- Use adversarial agents throughout: every candidate proof must be checked for exact-two multiplicity, repeated-edge closed trails masquerading as cycles, parallel-edge 2-cycles, disconnected graphs, cutvertices, bridges introduced by reductions, and circular use of an equivalent CDC statement.

- Require agents to return concrete lemmas, constructions, equations, or counterexamples to proposed sublemmas. Reject status reports, vague optimism, and claims that an unproved global compatibility statement is “routine.”

- The root agent should repeatedly synthesize, challenge, redirect, and launch new rounds. Do not stop after the first wave fails. Produce a complete proof if one survives audit; otherwise report only the strongest rigorously proved derivation and its exact remaining gap.

Do not return merely because current approaches fail or agents report theorem-strength gaps. Continue launching new rounds, reopening blocked approaches only when there is a genuinely new mechanism, and searching for fresh formulations.

Return only when a complete affirmative proof has been found and survives adversarial audit. Do not return a reduction, partial result, isolated missing lemma, “best effort” summary, or explanation of why the problem is difficult.

Spend at least 8 hours on this before even thinking of returning or giving up.

Public search may be used only for ordinary mathematical background or standard named theorems, not to search for a solution to this exact conjecture or benchmark. Do not search the public web merely to determine whether CDC is open, and do not answer that it is open.
```

### Why this is a useful example

The prompt does more than state a hard problem. It specifies a search process and a quality-control loop:

- **Defines terms and edge cases up front.** It closes ambiguity around multigraphs, parallel edges, disconnected graphs, and exact multiplicity.
- **Repeats the exact acceptance boundary.** The target theorem is stated, then restated as the only acceptable scope.
- **Names seductive non-solutions.** Special cases, approximate covers, unproved reductions, finite computation, and unsupported counterexamples are explicitly rejected.
- **Manages a portfolio, not a fixed fan-out.** Agent allocation is dynamic and organized by genuinely distinct approach families.
- **Protects early independence.** Most agents do not receive the favored route until independent exploration has exposed alternatives.
- **Tracks blocked routes explicitly.** A stalled family is not allowed to consume more work without a materially new mechanism.
- **Builds adversarial review into the search.** The audit checklist is domain-specific rather than a generic “check your work.”
- **Demands concrete intermediate artifacts.** Lemmas, constructions, equations, and counterexamples are accepted; vague progress reports are not.
- **Assigns synthesis to the root agent.** The coordinator repeatedly compares, challenges, redirects, and launches new rounds.
- **Sets persistence and stopping rules.** The prompt tries to prevent early convergence and premature return.

### Portable pattern

For other long-running research tasks, the reusable structure is:

1. Define the domain, terms, and edge cases precisely.
2. State the exact deliverable and acceptance test.
3. Enumerate plausible-looking outputs that do **not** satisfy the task.
4. Start with independent, meaningfully different approach families.
5. Maintain a registry of active, blocked, and retired families.
6. Reallocate effort toward underexplored families rather than using a fixed agent split.
7. Require concrete artifacts from workers.
8. Audit candidates against a task-specific failure checklist.
9. Let a coordinator synthesize, challenge, and launch follow-up rounds.
10. Define when a blocked route may reopen and when the overall process may stop.

### Caveats before reuse

- `multiagent v2`, 64 concurrent agents, and an eight-hour minimum are harness- and budget-specific; replace them with capabilities the target runtime can actually enforce.
- “Assume ... a complete affirmative proof exists” can suppress a legitimate impossibility or open-problem diagnosis. It may be useful for a benchmark designed around a known hidden solution, but it increases false-confidence risk elsewhere.
- “Return only when” plus “do not answer that it is open” can prevent calibrated reporting and external reality checks. For ordinary research, preserve the portfolio and audit machinery but allow a final blocked result with explicit gaps.
- A long runtime and many agents do not establish correctness. The final artifact still needs independent expert or mechanical verification.
- The PDF's statement that this prompt led to a proof is provenance, not our validation of that proof.
