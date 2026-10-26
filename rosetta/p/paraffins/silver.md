# Paraffins

**Candidate: proofs plausibly discharge automatically.** Only the count is required and it follows from a bounded iterative DP, but the arithmetic is nonlinear big-number work carried through nested loops with no invariants, so it needs careful guarding yet no annotation. The optional ASCII-art enumeration is left out.

Position 1379 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

Compute rooted-tree counts (carbon with up to three child subtrees) by size using an iterative DP over size and branch count, then unrooted counts by the centroid rule (subtrees under half the size, plus bicentered pairs for even n), all with fixed-capacity big-number digit arrays in two-dimensional tables. The program parses the first argument as n within 1..N_Max, rejects invalid input with a visible message, and otherwise prints the count for n (or all counts up to n) via Put_Line using decimal conversion of the digit array. Loops are for loops over table ranges, with explicit guards before every index computed from a loop-carried sum. About 170 lines.

## Proof obligations to watch

- **overflow**: Counts exceed 64 bits for larger n, so the program uses fixed-capacity digit arrays whose per-digit sums and carries are bounded by digit-type ranges and a documented maximum n, with overflow of the whole number rejected visibly rather than clamped.
- **index**: Rooted-tree DP tables are indexed by sums of sizes, so each index is guarded (or loop ranges are subtypes of the table range) just before use because no invariant can carry the bound.
- **overflow**: Combination counts (multisets of k subtrees of equal size) are computed by an additive DP instead of exact division, avoiding nonlinear division while keeping each step a bounded big-number add or small multiply.
- **termination**: All iteration is for loops or while loops inside procedures, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, big numbers, 'Image of scalars, text parsing, string building, Put without a newline and exit status.

## External effects

- **console output** (allowed): Prints the isomer count for each carbon count n up to the fixed bound, one line per n.
- **arguments** (allowed): The first command-line argument gives the requested n, validated against the supported range and rejected otherwise.

Assessed on 2026-10-15 against page revision 413831 of the [task](https://rosettacode.org/wiki/Paraffins) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
