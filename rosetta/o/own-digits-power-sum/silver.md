# Own digits power sum

**Candidate: proofs plausibly discharge automatically.** Every bound is statically derivable from small ranged subtypes and constant tables, and all loops are for loops in the main procedure, so no invariant or variant is needed; only the nonlinear power and the accumulator need careful guards.

Position 1512 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

Embed a constant table of 10**k for k in 0..8 and a 2D table of d**N for d in 0..9, N in 3..8, then run nested for loops over N and the candidate range. For each candidate, a fixed N-iteration for loop peels digits with mod 10 and /10 and adds the table power to a bounded sum guarded by a range check, and matching values are printed with 'Image via Put_Line. N = 9 is left out as optional, which keeps all values within 32 bits. About 45 lines.

## Proof obligations to watch

- **overflow**: The power sum is a loop-carried accumulator, so the program uses a 64-bit subtype and a guard before each addition, since only the type range is known after the first iteration; the true maximum 8*9^8 (about 344 million) is far below it.
- **overflow**: A precomputed table of d**N for d in 0..9 and N in 3..8 is built with the exponent and base bounded by subtypes, which the provers must show stays under 2**31, a mild nonlinear obligation.
- **range**: The outer loop bounds 10**(N-1) and 10**N-1 depend on N, so they are held in a small constant table indexed by N to keep every bound static.
- **index**: Table indexing by digit and by N is safe because the indices come from for loops over the array's own range or from a mod 10 result converted to a 0..9 subtype.

## Language surface beyond today's Silver

Integers, integer division, exponentiation, ranged subtypes, for loops, arrays, multidimensional arrays and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each own digits power sum, one per line, for N = 3 to 8.

Assessed on 2026-10-15 against page revision 414374 of the [task](https://rosettacode.org/wiki/Own_digits_power_sum) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
