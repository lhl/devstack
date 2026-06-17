# Anti-slop instructions for technical docs

A checklist for stripping filler from technical documentation. Use it two ways:

- **While writing:** keep these patterns out.
- **As a deslop pass:** run over an existing doc and delete/rewrite every match.
  Agents and smaller models are the worst offenders; on a recent doc this pass
  cut ~50% of the byte count with no loss of information.

The test for every sentence: **does it state a fact, a number, a path, a
command, a decision, or an action?** If not, cut it. Tone, reassurance, and
editorializing are not information.

## Banned patterns

### 1. Editorializing adjectives on facts

Words that grade a fact instead of stating it: `load-bearing`, `crucial`,
`critical` (as prose, not a priority label), `key`, `important to note`,
`notably`, `it's worth noting`, `interestingly`, `powerful`, `robust`,
`seamless`, `elegant`, `clean`, `proper`, `genuine`, `real` (as in "a real
gap").

- ❌ "This is the load-bearing design decision."
- ✅ "The verifier decodes through sherpa-onnx."
- ❌ "Notably, the manifest records per-file checksums."
- ✅ "The manifest records per-file checksums."

A priority column in a table (`Value: Critical`) is fine — that's a label, not
prose.

### 2. The "it's not X, it's Y" / "not debt, but a feature" frame

Contrastive reassurance that argues with an imagined objection.

- ❌ "This is documenting a real conflict, not technical debt."
- ✅ "`optimum-onnx==0.1.0` needs `transformers<4.58`; the project pins
  `transformers==5.x`. The export runs in a separate env."
- ❌ "This isn't a workaround so much as the intended path."
- ✅ State what it does and why. Let the reader judge.

### 3. "Honestly" / "to be fair" / "the truth is"

Confessional hedges. The doc has no feelings to disclose.

- ❌ "Honestly, the biggest gap here is CI."
- ✅ "No CI exists." (Rank it in the gap table if priority matters.)

### 4. Superlatives and stakes inflation

- ❌ "the single most important gap", "the biggest real gap", "this is the one
  that actually matters"
- ✅ Put items in a ranked table. Rank is the priority signal; prose
  restatement is noise.

### 5. Restating the obvious / self-summary / conclusion sections

- ❌ "In summary, as we can see from the above…"
- ❌ "This section covers the verification step." (as the first line of the
  verification section)
- ❌ A `## Conclusion` / "To wrap up…" / "In conclusion…" section that restates
  the doc.
- ✅ Just write the content. Headings already say what the section is. End on
  the last substantive point; no wrap-up section.

### 6. Hedging stacks

`arguably`, `essentially`, `basically`, `effectively`, `in some sense`, `more
or less`, `sort of`, `kind of`, `it could be argued`.

- ❌ "This is arguably essentially a complete fix."
- ✅ "This fixes batch-1 all-ones masks. It does not handle batched input."
  (State the scope precisely instead of hedging.)

### 7. Filler intensifiers

`very`, `really`, `quite`, `extremely`, `incredibly`, `simply`, `just` (when
minimizing), `actually`, `definitely`, `clearly`, `obviously`.

- ❌ "This is actually quite simple to fix."
- ✅ "Fix: add `--checkpoint` to the arg parser."

### 8. Marketing verbs and abstraction nouns

Verbs: `leverage`, `utilize`, `enable`, `empower`, `facilitate`, `streamline`,
`unlock`, `ensure` (when vague). Nouns: `solution`, `capability`, `journey`,
`experience`, `ecosystem`, `synergy`, `best-in-class`.

- ❌ "This leverages sherpa to enable robust verification capabilities."
- ✅ "verify_export.py decodes a duration sweep through sherpa."

### 9. The rule-of-three / parallel triplets

LLMs pad with three-item lists where one item carries the meaning.

- ❌ "fast, reliable, and production-ready"
- ✅ Name the actual property: "runs in <2s on CPU." Drop the rest unless each
  item is a distinct, verifiable claim.

### 10. Vague quantifiers

`several`, `various`, `a number of`, `many`, `some`, `a variety of`, `numerous`.

- ❌ "There are several gaps in verification."
- ✅ "Three gaps: G2, G6, G9." Use the count and the IDs.

### 11. Transition scaffolding

`That said,`, `With that in mind,`, `It's important to understand that,`,
`At the end of the day,`, `When it comes to`, `In terms of`, `Moving forward,`.

- ❌ "That said, when it comes to packaging, it's important to understand that…"
- ✅ "Packaging: …"

### 12. Em-dash dramatic reveals and rhetorical setups

- ❌ "There's one thing the doc gets wrong — and it's a big one."
- ✅ State it: "The doc assumes ORTModel parity certifies production. It does
  not."

### 13. Rhetorical questions as setups

A question that opens a section only to be answered in the next line.

- ❌ "So what does this mean? Why does it matter?"
- ✅ Delete the question; state the answer.

### 14. Time-relative words (doc-rot)

`currently`, `recently`, `now`, `today`, `nowadays`, `modern`,
`state-of-the-art`, `cutting-edge`, `as of this writing`. They go stale and
force maintenance.

- ❌ "The library currently supports modern GPUs."
- ✅ Pin a version or date, or drop the word: "As of v2.3 (2026-01), supports
  CUDA 12+."

### 15. Decorative emoji

✅ 🚀 ✨ 🎉 🔥 on headings and bullets.

- ❌ "## 🚀 Getting started"
- ✅ "## Getting started"

A functional legend or status column (✅/❌ as pass/fail, as in this doc's
examples) is data, not decoration — that's fine.

### 16. "Note that" / directive padding

`note that`, `keep in mind`, `remember that`, `be aware that`, `bear in mind`,
`it's important to remember`. The sentence almost always stands without the
preamble.

- ❌ "Note that the cache must be cleared first."
- ✅ "Clear the cache first."

### 17. AI-tell vocabulary

`delve`, `tapestry`, `realm`, `landscape` ("the X landscape"), `navigate`
("navigating the"), `testament to`, `plays a crucial/vital role`, `a wide range
of`, `rich set of`, `wealth of`, `treasure trove`.

- ❌ "This plays a crucial role in navigating the deployment landscape."
- ✅ "This sets the deploy target."

### 18. Wordy connectives and doublets

`in order to`→`to`, `due to the fact that`→`because`, `in the event that`→`if`,
`for the purpose of`→`to`, `each and every`→`each`, `various different`→
`different`, `end result`→`result`, `completely eliminate`→`eliminate`.

- ❌ "In order to completely eliminate each and every error…"
- ✅ "To eliminate every error…"

### 19. Engagement / CTA bait

`let's dive in`, `let's get started`, `buckle up`, `whether you're a beginner
or an expert`, `happy coding`, `feel free to`, `give it a try`.

- ❌ "Whether you're new or experienced, let's dive in!"
- ✅ Delete it. Start with the first instruction.

### 20. Weasel attribution

`studies show`, `experts agree`, `it's widely known`, `best practices say`,
`many believe`, `it's generally accepted` — with no citation.

- ❌ "Studies show this is the fastest approach."
- ✅ Cite it or cut it: "Benchmark (bench/run.py, 2026-01): 1.8s vs 4.2s."
  Unsourced claims should be traceable or removed.

## Deslop pass checklist

Run top to bottom over a doc:

1. Delete any sentence that contains no fact, number, path, command, decision,
   or action.
2. Delete intro/meta paragraphs that describe what the doc is or how it was
   produced, unless the reader needs that to act.
3. Search-and-kill the word lists in patterns 1, 3, 6, 7, 8, 11, 14, 16, 17,
   18. Most can be deleted outright with no rewrite.
4. Replace every "not X but Y" (pattern 2) with a plain statement of Y.
5. Replace vague quantifiers (pattern 10) with counts/IDs.
6. Collapse rule-of-three triplets (pattern 9) to the one claim that matters.
7. Convert prose that ranks/grades importance into a table or a label.
8. Delete rhetorical-question setups (pattern 13) and CTA/engagement bait
   (pattern 19).
9. Replace time-relative words (pattern 14) with a version or date, or delete.
10. Cite or cut weasel attributions (pattern 20).
11. Strip decorative emoji (pattern 15); keep functional legends/status
    columns.
12. Delete any conclusion/wrap-up section (pattern 5).
13. Re-read each section's first line; delete it if it just restates the
    heading.
14. Check headings are noun phrases or imperatives, not sentences.

## What to keep

Deslop removes filler, not substance. Keep:

- Numbers, file paths, symbol names, commands, config keys, version pins.
- Status markers, priority labels, dependency notes.
- Short rationale that changes what the reader does ("X depends on Y, so do Y
  first"). Cut rationale that only justifies a choice to an imagined critic.
- One-line context where a fact is genuinely ambiguous without it.

Plain and terse beats polished. A doc that reads slightly blunt is correct; a
doc that reads like a product page is slop.
