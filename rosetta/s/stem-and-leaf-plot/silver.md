# Stem-and-leaf plot

**Candidate: proofs likely to discharge automatically.** Every index comes from a subtype-bounded element or a for-loop range, and the only loop-carried value (the count) gets a guard before its increment, so no annotation is needed. Output is plain text through procedures with only for loops, so there are no termination or recursion issues.

Position 456 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Embed the 120 data values in a constant array whose element subtype is 0..149, tally them into a counts array indexed 0..149 (a counting sort that avoids a sorting loop), then loop over stems 0..14 and leaves 0..9 printing each leaf digit as many times as its count. Each stem row is a two-character right-aligned stem, " |", then the leaves, built with Put of Characters and ended with a line terminator. Increments are guarded against exceeding the count subtype. About 70 lines.

## Proof obligations to watch

- **overflow**: The per-value count increment inside a loop has no invariant, so a guard just before the increment (reject if the count is at its subtype maximum) discharges it.
- **range**: Converting stem and leaf digits to Character via 'Val is safe because the stem is declared 0..14 and the leaf 0..9, so the digit arithmetic stays within range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, Put without a newline and procedures.

## External effects

- **console output** (allowed): The plot lines are written to standard output, with several items per line.

Assessed on 2026-10-15 against page revision 415428 of the [task](https://rosettacode.org/wiki/Stem-and-leaf_plot) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
