# Practical numbers

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges with array indices bounded by declared subtypes, so no annotations are needed, and the only loop-carried value is a small counter that a guard or subtype bound keeps safe.

Position 357 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Is_Practical(X) is a function that fills a Boolean array Reach (0..666) with Reach(0) true, then for each D in 1..X/2 with X mod D = 0 runs a reverse for loop over S in 0..666-D setting Reach(S+D) when Reach(S) holds, which is the in-place subset-sum DP over proper divisors without storing them. X is a subtype 1..666, practical means Reach(1..X-1) all true (X=1 trivially), and the main procedure loops 1..333 counting and printing practical numbers and then reports 666 using Integer'Image into a bounded buffer. About 70 lines.

## Proof obligations to watch

- **index**: The subset-sum update indexes S+D, which is discharged because the reverse for loop runs S over 0 .. Limit-D with D a declared subtype bounded by the array range.
- **overflow**: The count of practical numbers is a loop-carried accumulator, so it uses a subtype wide enough for 1..666 with a guard before the increment, or is derived from the for index range.
- **termination**: Every loop is a for loop, so the function termination check is trivial.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, functions, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the practical-number count, the list of practical numbers, and the verdict for 666.

Assessed on 2026-10-15 against page revision 402608 of the [task](https://rosettacode.org/wiki/Practical_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
