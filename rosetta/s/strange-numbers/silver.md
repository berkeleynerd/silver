# Strange numbers

**Candidate: proofs plausibly discharge automatically.** Every check comes from digit ranges, static loop bounds and guards, and the DP avoids while loops and recursion; the only non-routine parts are loop-carried count sums needing cap guards.

Position 695 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Part one loops A over 101..499 and splits it into three digits by static division and mod, tests each adjacent absolute difference against 2, 3, 5 and 7 with plain comparisons, and prints matches ten per row using scalar images. The stretch goal uses a dynamic-programming table Ways(length, last digit) over a 2D array of digits 0..9 and lengths 1..10, seeded with one way per digit, extended by for loops over neighbour digits via guarded index offsets, then sums the length-10 row for leading digit 1 by tracking the table starting from digit 1 only, avoiding the brute-force 10^9 scan. About 70 lines.

## Proof obligations to watch

- **overflow**: The per-digit count table is a loop-carried array whose element bounds are unknown after the first iteration, so each sum guards against a documented cap and rejects with a visible outcome if it is exceeded.
- **overflow**: The row-printing counter is loop-carried and is kept in a small ranged subtype reset to zero by a guard, so its increment is checked just before use.
- **range**: Neighbour digit indexes (digit plus or minus a prime step) are guarded by explicit bounds tests before indexing the table.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, 'Image of scalars, Put without a newline, procedures, functions and string building.

## External effects

- **console output** (allowed): Prints the strange numbers in 101..499 and the 10-digit count to standard output.

Assessed on 2026-10-15 against page revision 405843 of the [task](https://rosettacode.org/wiki/Strange_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
