# Weird numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic and Boolean-array DP with for-loop-derived indexes, so checks follow from subtypes and loop ranges, but the loop-carried sums and the capacity guards need careful shaping, with no annotation required.

Position 400 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Iterate even candidates up to a documented limit of 16310 (enough for the 25th weird number), collect proper divisors into a fixed 200-slot array with a count guard, sum them with a capped accumulator, and for abundant numbers run a subset-sum DP over a Boolean array 0..16310 using nested for loops (reverse s from Target down to d). Print each weird number with 'Image into a bounded buffer via Put_Line (or Put), rejecting if the limit is reached before 25 are found. About 90 lines.

## Proof obligations to watch

- **overflow**: The divisor sum is loop-carried, so it is held in a ranged subtype with a guard before each addition that stops accumulating once it exceeds the candidate (already proving abundance).
- **index**: The reachable-sums Boolean array is indexed by s and s-d inside a for loop over d .. Target, so both indexes are in range by loop bounds, and divisor-array appends are guarded by a count-below-capacity test that rejects overflow visibly.
- **range**: The candidate counter and divisor loop bound are subtypes capped at 16310 with a guard before each increment, and the found count is guarded before it reaches 25.
- **termination**: All while loops live in procedures (the candidate search is in Main), and the subset-sum and divisor scans use for loops, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 25 weird numbers on one line or one per line.

Assessed on 2026-10-15 against page revision 413430 of the [task](https://rosettacode.org/wiki/Weird_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
