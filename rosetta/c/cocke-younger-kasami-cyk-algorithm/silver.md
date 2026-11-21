# Cocke–Younger–Kasami (CYK) Algorithm

**Candidate: proofs likely to discharge automatically.** The whole algorithm is nested for loops over fixed-size Boolean arrays with indexes derived from loop variables, so every check follows from types and bounds, with no loop-carried values needing invariants.

Position 1168 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Words and non-terminals are enumerations, the grammar is a constant array of binary and terminal rule records, and the table is a constrained 3-D Boolean array (start, end, non-terminal) of fixed capacity such as 8 words by 8 by 6 non-terminals. A procedure runs the textbook CYK for loops (length, start, split, rule) over each embedded token-array sentence (with an explicit length not above the capacity) and prints True or False with Put_Line. Sentences longer than the capacity would be rejected with a specified False/overflow message, and no while loops, recursion or tokenizing are needed. About 130 lines.

## Proof obligations to watch

- **index**: The end position j = i + l - 1 and split index k + 1 are computed from for-loop variables over bounded ranges, so the prover can show they lie in 1..Max_Words using linear arithmetic alone, with no loop-carried state.
- **range**: The sentence length n is a ranged subtype validated against the capacity before the table is filled, and shorter sentences are padded or sliced via an explicit length so the loop bounds stay within the declared ranges.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, enumerations, arrays, multidimensional arrays, records, for loops, procedures, functions and case statements.

## External effects

- **console output** (allowed): Prints True or False for each embedded test sentence.

Assessed on 2026-10-15 against page revision 414115 of the [task](https://rosettacode.org/wiki/Cocke%E2%80%93Younger%E2%80%93Kasami_%28CYK%29_Algorithm) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
