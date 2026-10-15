# Goodstein Sequence

**Candidate: proofs plausibly discharge automatically.** Required outputs (n up to 10, largest value about 4.5e13) fit in 64-bit integers, so every check follows from types and local overflow guards once the hereditary recursion is flattened to bounded-depth procedures, but the guard-heavy loop-carried arithmetic makes discharge depend on careful program shape.

Position 426 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Hold each term as a 64-bit-bounded integer and compute the next term by a bump procedure that splits the value into base-b digits in a bounded array, then rebuilds it in base b+1 with exponents handled by a fixed-depth chain of non-recursive helper procedures. The main procedure loops over n and term index with for loops, stops early on zero, guards every multiplication and addition against the 64-bit limit with a specified reject outcome, and prints terms using image conversion into a bounded line buffer. The optional stretch range n = 11..16 is not attempted beyond what fits 64 bits. About 170 lines.

## Proof obligations to watch

- **overflow**: Powers and digit-weighted sums in the new base grow fast, so each multiply and add is guarded against a 64-bit limit and a violation leads to a visible reject outcome rather than a wrong value.
- **overflow**: Loop-carried accumulators (running sum, power) are only bounded by their type after the first iteration, so every update needs an explicit guard just before it.
- **termination**: Hereditary conversion normally recurses on exponents, so it is flattened into a fixed-depth chain of non-recursive procedures with digit extraction in bounded loops, and the term loop is a bounded for loop.
- **index**: Digit and sequence-term arrays are indexed only by for-loop indexes over their own ranges or by guarded counters.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 10 terms of Goodstein(0..7) and the nth term of Goodstein(n) for n 0..10 as text lines.

Assessed on 2026-10-15 against page revision 402751 of the [task](https://rosettacode.org/wiki/Goodstein_Sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
