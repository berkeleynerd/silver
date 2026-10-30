# Wavelet Matrix

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over static ranges in procedures and every carried value is held in a declared range with a guard just before use, so no annotation is needed, but the loop-carried l, r and k updates need careful guarding. The task text gives no concrete queries, so the existing solution's five sample queries are used as the embedded data.

Position 726 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The program stores the six embedded values (each below 4096) in a fixed array, builds twelve levels with a stable partition into zero and one arrays and a prefix-count rank table per level (a 2D array of subtype 0..N), then answers the sample k-th smallest range queries with a for loop over levels carrying l, r, k and the result. Bits are extracted by integer division and mod with a constant power-of-two table, and guards before each carried-value update reject out-of-range query bounds or k visibly. Results are printed with Image concatenated into a String through Put_Line. About 130 lines.

## Proof obligations to watch

- **range**: Moving l and r into the 1-child range (zero count plus rank) cannot be bounded by types alone, so an explicit guard that rejects out-of-range positions precedes the assignment.
- **overflow**: The running rank counts and the result accumulator are loop-carried and are kept inside declared ranges (counts at most N, value below 2**12) with a guard before each increment.
- **index**: Rank-table lookups use positions typed 0..N and levels typed as the level range, so the for-loop indexes and the typed l and r keep indexing safe.
- **division**: Extracting a bit by dividing by a power of two uses a constant divisor taken from a static table, so division by zero is excluded by construction.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the answer to each embedded quantile query with Put_Line.

Assessed on 2026-10-15 against page revision 414582 of the [task](https://rosettacode.org/wiki/Wavelet_Matrix) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
