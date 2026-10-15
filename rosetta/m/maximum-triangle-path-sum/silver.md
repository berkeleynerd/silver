# Maximum triangle path sum

**Candidate: proofs likely to discharge automatically.** All indexing follows from for-loop ranges over a fixed 18 by 18 array, and the only loop-carried value is the sum, whose overflow and range checks discharge through a single guard just before each assignment.

Position 664 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the 18-row triangle in a constrained 18 by 18 Integer-based array of a ranged subtype (zero padded), then fold bottom-up with nested for loops: for R in reverse 1 .. 17, for C in 1 .. R, add the larger of the two cells below (chosen by an if) to the cell, rejecting if the sum would exceed the subtype limit. Print T(1,1) with 'Image; all indices R+1 and C+1 stay within 1..18 by loop bounds. About 60 lines.

## Proof obligations to watch

- **overflow**: The in-place bottom-up sums are loop-carried, so each addition is guarded by comparing the sum to the element subtype's upper limit before assigning, and over-limit is rejected visibly, which also covers the range check on assignment.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, multidimensional arrays, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the maximum total (1320) with Put_Line.

Assessed on 2026-10-15 against page revision 414334 of the [task](https://rosettacode.org/wiki/Maximum_triangle_path_sum) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
