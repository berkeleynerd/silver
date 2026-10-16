# Loops/For

**Candidate: proofs likely to discharge automatically.** For loops terminate by construction, the inner bound is the outer loop index within a static range, and no arithmetic or indexing is involved, so no check depends on a loop-carried value. The only new surface is the for loop and output without a line terminator.

Position 32 in the [progression](../../../progression.md#stage-2), in stage 2, which adds for loops.

## Approach

A parameterless Main procedure holds an outer for loop over 1 .. 5 and an inner for loop over 1 .. I that calls Put ("*"), followed by Put_Line ("") to end each row. All bounds are static literals or the outer loop index, so no variables are carried between iterations and no guards are needed. About 10 lines.

## Language surface beyond today's Silver

For loops and Put without a newline.

## External effects

- **console output** (allowed): Prints five lines of asterisks to standard output.

Assessed on 2026-10-15 against page revision 415373 of the [task](https://rosettacode.org/wiki/Loops/For) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
