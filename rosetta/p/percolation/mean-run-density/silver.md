# Percolation/Mean run density

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged types and for-loop bounds except the large loop-carried run counter, which needs a cap guard with a visible outcome; no annotation is needed and no recursion, heap or floating point is required, so the proofs will likely discharge with careful shape.

Position 393 in the [progression](../../../progression.md#stage-8), in stage 8.

## Approach

Use a deterministic 31-bit linear congruential generator held in a ranged integer subtype, with p expressed as tenths and a cell being 1 when the random value scaled to 0..9 is below that. A procedure simulates t=100 trials for each (p, n) pair with n in 100, 1000 and 10000 (n=100000 optional), counting a run start when the previous cell is 0 and the current is 1, then prints integer fixed-point K in ten-thousandths, p(1-p) and the delta through bounded string building and Put_Line. About 90 lines.

## Proof obligations to watch

- **overflow**: The run counter accumulated across 100 trials of up to 100000 cells is loop-carried with no invariant, so each increment needs a guard against a stated cap (rejecting on exceed) or a type range wide enough that the sum is provably bounded by the 64-bit type.
- **overflow**: The LCG state update is discharged by a subtype bounded to 2**31 so state times the multiplier plus the increment fits in 64 bits, and the per-cell threshold comparison uses scaled integers so no floating point is needed.
- **range**: Scaled K, delta and p(1-p) in ten-thousandths are computed by integer division by a nonzero constant trials times n, with guards before each conversion to the narrower output subtype.
- **termination**: All loops are for loops over fixed ranges or live in procedures, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the table of p, n, simulated K, p(1-p) and delta lines.

Assessed on 2026-10-15 against page revision 414391 of the [task](https://rosettacode.org/wiki/Percolation/Mean_run_density) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
