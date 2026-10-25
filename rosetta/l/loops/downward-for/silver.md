# Loops/Downward for

**Candidate: proofs likely to discharge automatically.** A bounded reverse loop prints the countdown from 10 to 0 using standard Integer'Image; every index and image length follows from the static range.

Position 9 in the [progression](../../../progression.md#stage-1), in stage 1.

## Approach

Main runs a single for loop over reverse 0 .. 10 and writes Integer'Image (I) with Silver_IO.Put_Line on each pass. Ada's leading space for non-negative values is retained, so no slicing, trimming or declared subtype is needed. About 8 lines.

## Language surface recorded by this assessment

Integer range for loops and Integer image.

## External effects

- **console output** (allowed): The countdown values 10 down to 0 are written to standard output, one per line.

Initially assessed on 2026-10-15 against page revision 412893 of the [task](https://rosettacode.org/wiki/Loops/Downward_for) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-16 by Codex through targeted source review; see the [review record](../../../for-loops-delivery-review.md).
