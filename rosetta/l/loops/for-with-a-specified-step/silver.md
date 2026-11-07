# Loops/For with a specified step

**Candidate: proofs likely to discharge automatically.** The index interval 1 through 5 and constant step 2 bound every product between 2 and 10, so no loop-carried arithmetic fact is needed.

Position 24 in the [progression](../../../progression.md#stage-1), in stage 1.

## Approach

Main declares Step : constant Integer := 2, then loops I over 1 .. 5 and prints Integer'Image ((I * Step)) with Silver_IO.Put_Line. As in the retained Ada solution's Looper_2, this computes a progression with step two while the loop index advances by one, retaining Ada's standard leading spaces. About 14 lines.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic and Integer image.

## External effects

- **console output** (allowed): Prints the stepped values 2, 4, 6, 8 and 10 to standard output, one per line.

Initially assessed on 2026-10-15 against page revision 412896 of the [task](https://rosettacode.org/wiki/Loops/For_with_a_specified_step) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-16 by Codex through targeted source review; see the [review record](../../../for-loops-delivery-review.md).
