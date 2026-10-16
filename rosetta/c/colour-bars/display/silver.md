# Colour bars/Display

**Candidate: proofs likely to discharge automatically.** The program produces actual coloured bars in an image file, rather than replacing colour with labels, and needs file output that Silver has not admitted.

Position 1419 in the [progression](../../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Write a fixed P3 PPM header for an 80 by 8 image, then repeat eight rows of ten black, red, green, blue, magenta, cyan, yellow and white pixels in that order using fixed RGB text and bounded loops. Close the file and report any creation, partial-write or close failure through the specified file-output outcome; a viewer displays the resulting coloured image. About 35 lines.

## Language surface beyond today's Silver

For loops and file output.

## External effects

- **files** (allowed): Writes a PPM image containing the required coloured bars, through a future admitted file-output operation with specified failure outcomes.

Initially assessed on 2026-10-15 against page revision 415034 of the [task](https://rosettacode.org/wiki/Colour_bars/Display) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-15 by Codex through targeted source review; see the [review record](../../../review-343c2f8.md).
