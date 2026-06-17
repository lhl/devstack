---
title: AI Slop
tags: [llm, writing, slop, evaluation, theory, detection]
sources:
  - sources/conversations/2026-06-17-ai-slop-template-why-and-prose-techniques.md
links:
  - https://arxiv.org/abs/2509.19163
  - https://arxiv.org/abs/2503.01659
  - https://github.com/sam-paech/slop-forensics
  - https://github.com/sam-paech/auto-antislop
  - https://github.com/shisa-ai/shisa-v3
---

# AI Slop

"Slop" is low-quality LLM-generated text that performs the *shape* of insight —
cadence, emphasis, confidence — without load-bearing content underneath. The
enforceable deslop checklist for our own technical docs lives in
[`docs/ANTI-SLOP-INSTRUCTIONS.md`](../../docs/ANTI-SLOP-INSTRUCTIONS.md); this
page records the taxonomy, the causal theories, and the detection-research
landscape. The generation-side companion is [[practices/llm-prose-techniques]].

Author's stance (repo owner): slop is annoying and worth stamping out. A larger
body of his slop research — English and Japanese, including forensics tooling
and training experiments — lives in the
[shisa-v3 `antislop/`](https://github.com/shisa-ai/shisa-v3) tree.

## The template

The recurring formula, roughly in the order it appears in a slop paragraph
(descriptive; the enforceable bans are in the instruction doc):

1. **Em-dash hook** — a long opener with an em-dash setting off a "but actually"
   clause that escalates stakes.
2. **Staccato beat** — one punchy sentence, or three short ones, for rhythm.
3. **Negation pivot** — "It's not X, it's Y," often stacked ("Not just X. Not
   even Y. It's Z."), with Y vaguer and grander than X.
4. **The triad** — rule-of-three list with forced parallelism.
5. **Vocabulary tells** — delve, navigate, tapestry, landscape, realm, journey,
   unlock, harness, leverage, testament, paradigm, ever-evolving, intricate.
6. **Hedge-and-elevate** — "While X has its place, the real Y lies in Z";
   concedes a cartoon objection to make the pivot land.
7. **Bolded pseudo-insight** — phrases bolded for rhythm, not because they mark
   a defined term or key.
8. **Rhetorical close** — a "rethink/reimagine" call, or a question that answers
   itself.

The unifying tell is not any single move: every move does the shape of insight
with zero specifics. The em-dash isn't the crime; the clause after it adding
only emphasis and no information is.

## Why models converge on it (theory)

The following is the source author's reasoning, not established fact. It is
coherent and consistent with the cited empirical work below, but we have not
verified the causal chain.

The proposed mechanism: post-training optimizes a proxy, not quality. The
reward signal is "which response does a rater click 'better' in a side-by-side,"
and the slop features (structural completeness, hedging, em-dash insight-shape,
triadic rhythm, negation pivots) are exactly the features detectable in seconds
without reading. Reward models learn those shallow features; DPO/PPO then
concentrates policy mass on maximizing them. Several pressures compound in the
same direction:

- Pretraining post-2023 is contaminated with prior-gen LLM output, drifting the
  base distribution toward the basin.
- Synthetic SFT inherits the register of the model that generated it.
- RLAIF / constitutional loops reward what models would themselves produce (the
  self-rating fixed point is the slop fixed point).
- Safety / sycophancy training favors hedge-laden, balance-gesturing prose.
- The "helpful assistant" persona sits at the corporate-explainer attractor.

A separate (also unverified) social claim explains why slop persists despite
being an anti-signal: most readers pattern-match at "looks thoughtful ✓" and
move on; posters either can't hear the tells or don't care because posting cost
is zero and reach is rewarded regardless.

## Empirical support (cited, not reproduced by us)

Independent papers consistent with the "alignment narrows the output
distribution" theory:

- **Alignment shrinks the generative horizon** — branching-factor analysis of
  probability concentration in aligned models. https://arxiv.org/abs/2506.17871
- **Base models beat aligned models at randomness and creativity** — SFT/DPO
  erode diversity on creative tasks. https://arxiv.org/abs/2505.00047
- **Lower uncertainty in creative writing than professional writers** — LLM
  continuations show substantially lower intrinsic uncertainty than human text.
  https://arxiv.org/abs/2602.16162
- **Modifying post-training for diverse creative writing** — diversified
  DPO/ORPO recover diversity with minimal quality loss.
  https://arxiv.org/abs/2503.17126

## Detection and forensics landscape

Drawn from the shisa-v3 `antislop/` research notes (attribution corrected
against the papers during ingest):

- **Measuring AI "Slop" in Text** — Shaib, Chakrabarty, Garcia-Olano, Wallace
  (Northeastern / Stony Brook / Meta AI). Taxonomy of slop via expert
  interviews; finds 3 of 5 significant slop features lack reliable automatic
  metrics. https://arxiv.org/abs/2509.19163
- **Syntactic templates** — LLMs reuse favored POS-tag sequences; detectable as
  repeated syntactic structures (Shaib et al., EMNLP Findings).
- **Detecting stylistic fingerprints** — Y. Bitton, E. Bitton, Nisan
  (Copyleaks). LLM family attribution; fingerprints persist even when the model
  is told to write differently. https://arxiv.org/abs/2503.01659
- **DNA-GPT** — divergent n-gram analysis for training-free detection.
  https://arxiv.org/abs/2305.17359
- **Statistical signals** — perplexity (AI lower), burstiness / sentence-length
  variation (AI lower), type-token ratio, Zipf-law fit, second-order Markov
  transition uniformity.
- **Overused-word corpus analysis** — e.g. "reimagined" ~1000x more likely in
  GPT-4 output than human text; "delve" ~92% rise in academic papers 2022→2023.

Tooling:

- **slop-forensics** (Sam Paech) — runnable n-gram / linguistic forensic
  analysis. https://github.com/sam-paech/slop-forensics
- **auto-antislop** (Sam Paech) — pipeline referenced by shisa-v3.
  https://github.com/sam-paech/auto-antislop
- **diversity** (Chantal Shaib) — Python text-diversity toolkit.
- DetectGPT, Binoculars — zero-shot detection methods.

Cross-lingual note: the shisa-v3 work investigates inheritance of English slop
patterns into Japanese output (syntactic-template transfer, keigo/register
inconsistency, katakana frequency) — a gap area with few non-English tools.

## Unslop / enslop training (upstream claim)

A reverse-transformation fine-tune (N8Programs): take human passages (Project
Gutenberg), "enslop" them by running GPT-4o-mini ~10x with "make it read far
better" prompts, then train on `[slopped] -> [original]` pairs so the model
learns to *remove* AI patterns. Reported to generalize (trained on GPT-4o-mini
output, de-slops GPT-5.2 output) and to fool an AI detector ~25% of the time
despite not being trained against it. Recommended inference: temperature 0.8,
repetition penalty 1.1, **no** top_k/top_p/min_p (truncating tails reproduces
low-entropy slop). Tech-demo scale; not reproduced by us. See
`sources/conversations/...` and the shisa-v3 `RESEARCH-enslop-unslop.md`.

## See also

- [[practices/llm-prose-techniques]] — how to get less-sloppy prose out of an LLM
- [`docs/ANTI-SLOP-INSTRUCTIONS.md`](../../docs/ANTI-SLOP-INSTRUCTIONS.md) — the
  enforceable deslop checklist for our technical docs
