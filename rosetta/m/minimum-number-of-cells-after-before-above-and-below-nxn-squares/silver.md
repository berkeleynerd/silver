# Minimum number of cells after, before, above and below NxN squares

**Candidate: proofs likely to discharge automatically.** Every value derives from constant loop ranges of 1..10, so the subtractions, the minimum and the image conversion all follow from types and static bounds, and there is no loop-carried accumulator.

Position 46 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Nested for loops over a subtype Idx range 1 .. 10 compute the minimum of I-1, 10-I, J-1 and 10-J with if statements into a Natural-range variable. Each value is written with Put of its 'Image followed by a space, and each row ends with Put_Line of an empty string. All values are bounded 0..4 by the loop ranges, so no guards are needed. About 25 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, for loops, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the 10x10 grid of minimum distances to the edge, one row per line.

Assessed on 2026-10-15 against page revision 406018 of the [task](https://rosettacode.org/wiki/Minimum_number_of_cells_after,_before,_above_and_below_NxN_squares) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
