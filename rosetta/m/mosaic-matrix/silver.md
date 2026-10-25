# Mosaic matrix

**Candidate: proofs likely to discharge automatically.** Every check follows from for-loop indexes over static constant ranges, the sum of two indexes at most 16 cannot overflow, and mod 2 has a literal nonzero divisor, so no loop-carried value needs a guard.

Position 104 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A constant side length (for example 8) bounds two nested for loops over Positive range 1 .. Side, and each cell prints "1 " when (Row + Col) mod 2 = 0 and ". " otherwise using Put. After each inner loop a Put_Line of an empty string ends the row, and no input is read, so nothing needs validating. About 22 lines.

## Language surface recorded by this assessment

Integers, integer division, for loops, Put without a newline and ranged subtypes.

## External effects

- **console output** (allowed): The matrix is drawn as text art on standard output, which the task's GUI request does not require.

Assessed on 2026-10-15 against page revision 399918 of the [task](https://rosettacode.org/wiki/Mosaic_matrix) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
