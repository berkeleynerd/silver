# Loops/For with a specified step

**Candidate: proofs likely to discharge automatically.** The index interval 1 through 5 and constant step 2 bound every product between 2 and 10, so no loop-carried arithmetic fact is needed.

Position 39 in the [progression](../../../progression.md#stage-3), in stage 3.

## Approach

Main declares Step : constant Integer := 2, then loops I over 1 .. 5 and prints Integer'Image ((I * Step)) with Silver_IO.Put_Line. This displays 2, 4, 6, 8 and 10 with Ada's standard leading spaces, exercising constant declarations, grouped arithmetic, loops and formatting together. About 14 lines.

## Language surface beyond today's Silver

Integers, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the stepped values 2, 4, 6, 8, 10 on one line.

Initially assessed on 2026-10-15 against page revision 412896 of the [task](https://rosettacode.org/wiki/Loops/For_with_a_specified_step) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-15 by Codex through targeted source review; see the [review record](../../../review-343c2f8.md).
