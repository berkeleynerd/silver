# Loops/For

**Candidate: proofs likely to discharge automatically.** The outer Integer index stays within 1 through 5 and bounds the nested loop; the sample uses immutable indexes and no loop-carried values.

Position 15 in the [progression](../../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main procedure holds an outer for loop over 1 .. 5 and an inner for loop over 1 .. I that calls Put ("*"), followed by Put_Line ("") to end each row. All bounds are static literals or the outer loop index, so no variables are carried between iterations and no guards are needed. About 10 lines.

## Language surface recorded by this assessment

Integer range for loops and Put without a newline.

## External effects

- **console output** (allowed): Prints five lines of asterisks to standard output.

Initially assessed on 2026-10-15 against page revision 415373 of the [task](https://rosettacode.org/wiki/Loops/For) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-16 by Codex through targeted source review; see the [review record](../../../for-loops-delivery-review.md).
