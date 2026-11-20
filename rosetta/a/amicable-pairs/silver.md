# Amicable pairs

**Candidate: proofs plausibly discharge automatically.** Every check follows from array bounds, subtype ranges and guards placed just before use, but the loop-carried divisor-sum accumulator needs a cap guard to avoid overflow, so success depends on careful program shape.

Position 175 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A constrained array Sums (2 .. 19_999) of a ranged integer subtype holds the proper-divisor sum of each number, filled by nested for loops (N outer, D in 1 .. N/2 inner, adding D when N mod D = 0 under a cap guard). A second for loop over N checks that M = Sums(N) satisfies N < M, M <= 19_999 and Sums(M) = N, then prints the pair with Integer'Image and concatenation in Put_Line. The roughly 100 million inner iterations are only a run-time cost, and no while loops, functions or recursion are needed. About 35 lines.

## Proof obligations to watch

- **overflow**: The divisor-sum accumulator is loop-carried, so it is held in a wide ranged subtype and its addition is guarded by a visible cap test, with sums above the cap meaning the number cannot be in a pair below 20,000.
- **index**: The partner M read from the sums array is used as an index only after an explicit guard that M is within 1 .. 19_999, so the access follows from a condition just before use.
- **range**: Assigning the capped accumulator into the array element type and converting the loop index to the sum type are discharged by the declared subtype ranges and the cap guard.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each amicable pair as a line on standard output.

Assessed on 2026-10-15 against page revision 413334 of the [task](https://rosettacode.org/wiki/Amicable_pairs) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
