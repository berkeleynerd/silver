# Loops/N plus one half

**Candidate: proofs likely to discharge automatically.** Current Integer range loops, scalar comparisons, Put and standard Integer Image express the requested partial final iteration. Number and comma use distinct output statements inside the loop, and no trailing comma is emitted.

Position 17 in the [progression](../../../progression.md#stage-1), in stage 1.

## Approach

Main loops I over 1 .. 10, calls Silver_IO.Put (Integer'Image (I)), then calls Silver_IO.Put (",") only under I < 10. Silver_IO.Put_Line ("") follows the loop. Because each positive Image already starts with a space, comma output must be ",", not ", ". Exact output is one leading space followed by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 and LF. The last iteration performs the number output while skipping the comma output. About 12 lines.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic, Integer image and Put without a newline.

## External effects

- **console output** (allowed): Prints the comma-separated list 1 through 10 to standard output.

Initially assessed on 2026-10-15 against page revision 411531 of the [task](https://rosettacode.org/wiki/Loops/N_plus_one_half) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../../assessment-reconciliation-20261025.md).
