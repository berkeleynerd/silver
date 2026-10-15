# Loops/For with a specified step

**Candidate: proofs likely to discharge automatically.** The loop bounds are static and I * 2 is at most 10, so no overflow or range check needs a loop invariant, and the output needs only an integer-image Put.

Position 67 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

A parameterless Main loops I over the static range 1 .. 5 and prints I * 2 as the step-2 value, using Silver_IO.Put with an integer image. An if statement before each value prints the ", " separator except for the first, and Put_Line ends the line. About 14 lines.

## Language surface beyond today's Silver

Integers, for loops, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the stepped values 2, 4, 6, 8, 10 on one line.

Assessed on 2026-10-15 against page revision 412896 of the [task](https://rosettacode.org/wiki/Loops/For_with_a_specified_step) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
