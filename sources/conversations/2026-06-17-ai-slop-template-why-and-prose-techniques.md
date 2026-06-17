# AI Slop: Template, Causes, and Prose-Generation Techniques

> **Provenance:** Exported chat discussion (user with a separate assistant
> model), pasted into a devstack session on 2026-06-17. Internal date markers
> read "May 3" (year unstated). Filed verbatim as a source.
>
> **Claim status:** The "template analysis" is descriptive. The sections on
> *why models converge on slop* and *why the social equilibrium persists* are
> explicitly the author's reasoning — armchair theorizing, not verified. The
> prose-generation techniques are the assistant's recommendations; they have
> not been independently reproduced by us.

---

## Q1 — The template of contemporary AI slop

> Give me the template analysis of the current meta for AI slop. It has like a
> long sentence with some sort of ted talk bs with an emdash. Maybe a punchy
> sentence. Or three short ones. An it's not this it's that.

The template, roughly in the order it tends to appear:

1. **The em-dash hook.** A long opener gesturing at insight, with an em-dash
   setting off a "but actually" clause that escalates stakes. "Building software
   isn't just writing code — it's an act of translation between human intent and
   machine precision."
2. **The staccato beat.** One punchy sentence. Or three short ones. Sometimes
   fragments. For rhythm.
3. **The negation pivot.** "It's not X. It's Y." Often stacked: "Not just X. Not
   even Y. It's Z." The Y is almost always vaguer and more grandiose than the X.
4. **The triad.** Rule-of-three list with forced parallelism. "Faster, smarter,
   more human." / "Elegant, efficient, effective."
5. **The vocabulary tells.** delve, navigate, tapestry, landscape, realm,
   journey, unlock, harness, leverage, testament, paradigm, ever-evolving,
   fast-paced, intricate.
6. **The hedge-and-elevate.** "While X has its place, the real Y lies in Z."
   Concedes a cartoon objection to make the pivot land harder.
7. **The bolded almost-insight.** Random phrases bolded for emphasis that aren't
   actually keys to anything — visual rhythm cosplaying as structure.
8. **The rhetorical close.** A "rethink/reimagine" call, or a question that
   answers itself. "Isn't that what real innovation looks like?"

The deeper tell isn't any one move — it's that all of them are doing the shape
of insight without the load-bearing content underneath. Punchy cadence,
profound posture, zero specifics. The em-dash isn't the crime; the crime is that
the clause after the em-dash never adds information, only emphasis.

## Q2 — Why does slop persist if it's an anti-signal?

> It seems endemic on LinkedIn, Twitter, Reddit. Do people not realize or not
> care? Do audiences not realize / aren't sick of it? It wasn't compelling even
> when new. It seems like an anti-signal.

Both, split fairly cleanly:

- A lot of posters genuinely don't hear it — they prompted, got output more
  polished than they'd write themselves, and the polish reads as competence. The
  tells are only audible if you've spent enough hours with the models to develop
  the ear.
- The other camp knows and doesn't care, because the marginal cost of posting is
  zero and the algorithm rewards volume regardless of whether ~30% of viewers
  clock it as slop. The discerning audience isn't who they're posting for
  (recruiters, prospects, weak ties).

On the audience side: the median scroll is less engaged than you'd think.
LinkedIn was optimized for the *shape* of insight long before LLMs;
corporate-speak posturing was already the native register. AI slop automated it.
Most people pattern-match at "looks like a thoughtful post ✓" and move on. The
anti-signal point is real for a narrow audience and inert for everyone else,
which is why the equilibrium holds.

## Q3 — Why does frontier post-training converge on this basin?

> Billions of dollars, ~1e25 FLOPs, trillions of tokens, RL across a thousand
> environments. Why this basin? I can't imagine it's being heavily rewarded.

It *is* being heavily rewarded — just not for the reason hope would suggest. The
target isn't quality; it's "which response does a contractor click 'better' in a
side-by-side at scale." That objective rewards exactly the slop features —
structural completeness, hedging, em-dash insight-shape, triadic rhythm, "it's
not X it's Y" pivots — because those are detectable in eight seconds without
reading. Actually-thoughtful prose requires reading; raters don't. The reward
model learns eight-second features, then DPO/PPO concentrates policy mass on
maximizing them. Bradley-Terry on shallow comparisons can't distinguish
slop-with-the-shape-of-insight from insight.

Every other pressure compounds in the same direction:

- Pretraining post-2023 is contaminated with prior-gen LLM output, so the base
  distribution drifts toward the basin.
- Synthetic SFT inherits the register of whatever model generated it.
- RLAIF / constitutional loops reward what models would themselves produce — the
  self-rating fixed point is the slop fixed point.
- Safety / sycophancy training pushes toward hedge-laden, balance-gesturing
  prose that already has the cadence.
- The "helpful assistant" persona target sits squarely at the corporate-explainer
  attractor.

Five reinforcing gradients, one weak corrective signal. The basin is stable
because every arrow points in. The pipeline is exquisitely optimized — just for
a proxy that's load-bearing because no scalable alternative exists. You can't
hire a million raters with taste.

## Q4 — How to prompt for better writing?

> It's obviously within frontier LLMs to write well. What are the best
> techniques — prompting, context engineering, priming? Even given my own
> samples and rules to avoid, models can't help reflecting the tics.

Why the tics resist: they aren't surface lexical choices, they're
discourse-level priors. "Avoid em-dashes" constrains a token, but the em-dash
hook is a structural commitment made three sentences earlier when the model
decided to set up a "but actually" pivot. By the time the dash renders, it's the
lowest-loss continuation. Same for the triad, negation pivot, rhetorical close.
These are cadence-level priors entrenched by RLHF on shallow ratings. A
system-prompt rule is a tiny signal against that gradient. Recent work: instruct
and reasoning models have significantly lower output entropy than humans in
creative writing, and the gap widens with alignment intensity
(https://arxiv.org/abs/2602.16162, https://arxiv.org/abs/2506.17871).

What moves the needle, roughly in order of leverage:

1. **Skip the chat model for prose generation.** Biggest lever, rarely pulled.
   The slop basin lives in post-training; pretraining still has the full human
   distribution. Use a base/lightly-tuned model for the prose pass; use the chat
   model only for planning/structure. (Base models beat aligned models at
   creativity: https://arxiv.org/abs/2505.00047)
2. **Logit bias / banned tokens.** Operates at the sampling layer where the rule
   binds, not the instruction layer where the model can acknowledge-but-ignore.
   Ban "—", "delve", "tapestry", "navigate", "landscape", "realm", "testament",
   "ever-evolving". Brutal but effective.
3. **Prefill the response.** Write the opener yourself; have it continue. Now it
   structurally can't open with the em-dash hook.
4. **Drop the assistant scaffold.** Frame as text completion, not chat. The
   "helpful AI assistant" persona is itself the slop attractor; disabling the
   persona disables it.
5. **Anchor to specific writers, not adjectives.** "In the register of Patrick
   McKenzie / Paul Graham / Anne Carson / John McPhee" points at a coordinate in
   style space. "Casual but professional" points at the slop centroid.
6. **Decompose: outline → draft → voice pass → tic hunt.** Models edit better
   than they generate. Final pass: "list every sentence using these patterns
   (em-dash hook, triad, negation pivot, rhetorical close); don't fix, just
   list." Then rewrite.
7. **Negative exemplars with annotations beat rules.** Show three sentences using
   a construction and annotate *why* each is hollow. The model learns a
   discriminator, not a rule.
8. **Frame as thinking, not writing.** "Explain your reasoning about X" beats
   "write a blog post about X" — the latter activates the post-shaped template.
9. **Voice corpus density matters.** Not 1–2 paragraphs — 5–10K words, ideally
   with before/after pairs. Below some threshold the prior wins.
10. **Sampling.** Higher temperature, top-p ~0.95, presence/frequency penalties.
    Default chat temps are tuned for instruction-following → low entropy → the
    modes are exactly the slop modes. See also "conformative decoding," which
    mixes in base-model probabilities at sampling time
    (https://arxiv.org/abs/2507.20956).

Honest ceiling: stacking these gets ~70–80% of the way to your own voice. The
last 20% — the specific concrete observation only you would make — is what the
human editing pass adds. Treat the model as a producer of structurally sound
drafts you finish, not finished work you accept.
