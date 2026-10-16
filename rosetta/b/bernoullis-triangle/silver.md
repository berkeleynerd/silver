# Bernoulli's triangle

**Candidate: proofs plausibly discharge automatically.** The program is bounded integer array filling with for loops over static ranges, so almost every check follows from types and loop bounds, with only the loop-carried sums needing explicit guards. The 15-row limit keeps all values at most 16384, so the guards are unreachable but cheap.

Position 906 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Use a 15 by 15 array of a ranged subtype 0..16384 filled row by row with for loops: column 0 is 1, interior entries are the sum of the two entries above, and the last entry of each row is twice the previous row's last entry. Each sum and doubling is guarded against the subtype limit with Reject, then rows are printed with Put of each value's image followed by a space and a final Put_Line. All loops are for loops over constant ranges in the main procedure, so no termination obligations arise. About 40 lines.

## Proof obligations to watch

- **range**: Stored sums come from array elements known only by their type range after the first iteration, so each sum is guarded against the 16384 limit with a visible Reject outcome that never fires for 15 rows.
- **index**: Row and column indexes are for-loop variables over the array's own ranges, with the k-1 neighbour only used when k is at least 1, so index checks follow from the loop bounds and a guard.
- **other**: Image conversion and spacing for values up to five digits need a bounded output buffer or Put of 'Image, whose length checks must be provable from the element range.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the 15 rows of the triangle to standard output.

Assessed on 2026-10-15 against page revision 411997 of the [task](https://rosettacode.org/wiki/Bernoulli's_triangle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
