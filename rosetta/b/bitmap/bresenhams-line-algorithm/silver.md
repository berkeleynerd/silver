# Bitmap/Bresenham's line algorithm

**Candidate: proofs plausibly discharge automatically.** Integer Bresenham on a small fixed grid has all indexes and arithmetic bounded by 1..16 subtypes and for loops, so checks should discharge without annotations, though the nonlinear rounding division and subtype conversions need careful shaping. Silver today lacks arrays, loops, procedures, characters and integers, which are needed.

Position 907 in the [progression](../../../progression.md#stage-15), in stage 15.

## Approach

The program declares a Coord subtype 1..16 and a 16x16 Character array filled with a blank, and a Line procedure that picks the major axis, then loops with a for loop over the major-axis offset, computing the minor-axis coordinate with integer rounding arithmetic instead of a carried error term. It draws the four-line diamond from the task's sample into the grid and then builds and prints each row as a 16-character String with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: Loop-carried error terms would only be known by type, so the program computes each step's minor-axis coordinate directly from the loop index with operands bounded by a 1..16 coordinate subtype, keeping products far below the Integer limits.
- **range**: Converting the computed minor-axis coordinate back to the 1..16 subtype needs the prover to show it lies between the endpoints; an explicit clamp guard that cannot trigger for valid inputs, or interpolation bounded by DY, covers it.
- **division**: The division by twice the major-axis delta is guarded by a test that the delta is nonzero, with a single-point case handled separately.
- **index**: Pixel stores use Coord-typed indexes over the array's own ranges so they discharge by type.
- **termination**: All loops are for loops inside procedures, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, for loops, procedures, string building, conditional expressions and Boolean objects.

## External effects

- **console output** (allowed): The 16x16 text picture is printed row by row to standard output.

Assessed on 2026-10-15 against page revision 414082 of the [task](https://rosettacode.org/wiki/Bitmap/Bresenham's_line_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
