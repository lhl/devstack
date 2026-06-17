---
title: Getting Better Prose Out of LLMs
tags: [llm, writing, prompting, context-engineering, slop]
sources:
  - sources/conversations/2026-06-17-ai-slop-template-why-and-prose-techniques.md
links:
  - https://arxiv.org/abs/2507.20956
  - https://arxiv.org/abs/2505.00047
  - https://arxiv.org/abs/2506.17871
---

# Getting Better Prose Out of LLMs

Techniques for steering an LLM away from the [[concepts/ai-slop]] register. This
is the generation-side companion to the deslop checklist in
[`docs/ANTI-SLOP-INSTRUCTIONS.md`](../../docs/ANTI-SLOP-INSTRUCTIONS.md) (which
cleans a finished doc; this page is about producing better drafts).

**Status:** recommendations from the source discussion, ordered by claimed
leverage. The external papers are cited; the techniques themselves are not
independently benchmarked by us. Treat the ordering as a hypothesis.

## Why instruction-level constraints resist

The tics are discourse-level priors, not surface lexical choices. "Avoid
em-dashes" constrains a token, but the em-dash hook is a structural commitment
the model made sentences earlier when it set up a "but actually" pivot — by the
time the dash renders it is the lowest-loss continuation. The same holds for the
triad, the negation pivot, and the rhetorical close. A system-prompt rule is a
weak signal against a strong gradient. Few-shot voice samples work for a
paragraph, then drift back to the prior. Empirically, aligned models show lower
output entropy / narrower distributions than base models and than humans
(https://arxiv.org/abs/2506.17871, https://arxiv.org/abs/2505.00047).

## Techniques, by leverage

1. **Skip the chat model for the prose pass.** The slop basin lives in
   post-training; pretraining retains the full human distribution. Use a base /
   lightly-tuned model for prose, the chat model only for planning and
   structure. (Base models beat aligned models at creativity:
   https://arxiv.org/abs/2505.00047)
2. **Logit bias / banned tokens.** Acts at the sampling layer, where the rule
   binds — unlike an instruction the model can acknowledge and then ignore. Ban
   "—", delve, tapestry, navigate, landscape, realm, testament, ever-evolving.
   Exposed by OpenAI and local backends; not by the Anthropic API.
3. **Prefill the response.** Write the opener yourself and have the model
   continue, so it structurally cannot open with the em-dash hook. Supported
   directly via assistant-message prefill.
4. **Drop the assistant scaffold.** Frame the task as text completion, not chat
   ("Below is a draft by [voice]. It begins: …"). The helpful-assistant persona
   is itself the slop attractor; turning it off disables it.
5. **Anchor to named writers, not adjectives.** "In the register of Patrick
   McKenzie / Paul Graham / John McPhee" points at a coordinate in style space.
   "Casual but professional" points at the slop centroid — that adjective stack
   is the prior's self-description.
6. **Decompose: outline → draft → voice pass → tic hunt.** Models edit better
   than they generate. For the tic hunt: "list every sentence using these
   patterns — em-dash hook, triad, negation pivot, rhetorical close, abstract
   noun where concrete would land, generic bolding. Don't fix yet, just list."
   Then rewrite. Surfacing routes through the critic, which is sharper than the
   generator for this.
7. **Annotated negative exemplars beat rules.** Don't say "avoid the
   it's-not-X-it's-Y construction." Show three sentences that use it and write
   *why* each is hollow. The model learns a discriminator, not a rule.
8. **Frame as thinking, not writing.** "Explain your reasoning about X" produces
   better prose than "write a blog post about X" — the latter activates the
   post-shaped template and its inflated cadence. Light-edit the thinking into
   the piece.
9. **Voice-corpus density.** Not 1–2 paragraphs — 5–10K words, ideally with
   before/after pairs of generic text rewritten into the target voice. Below
   some threshold the prior wins; above it the model can fit the voice for a few
   hundred tokens at a time.
10. **Sampling.** Higher temperature, top-p ~0.95, presence/frequency penalties.
    Default chat temps are tuned for instruction-following → low entropy → the
    modes are the slop modes. "Conformative decoding" mixes base-model
    probabilities in at sampling time to recover diversity
    (https://arxiv.org/abs/2507.20956).

## Ceiling

Per the source: stacking these reaches ~70–80% of a target voice; the last 20%
(the specific concrete observation only the author would make) comes from the
human editing pass. Use the model to lay down structurally sound drafts at
volume, not to produce finished work you accept as-is.

## See also

- [[concepts/ai-slop]] — what slop is, why models produce it, detection research
- [`docs/ANTI-SLOP-INSTRUCTIONS.md`](../../docs/ANTI-SLOP-INSTRUCTIONS.md) — the
  deslop pass for finished technical docs
