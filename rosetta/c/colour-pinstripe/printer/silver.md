# Colour pinstripe/Printer

**Candidate: proofs likely to discharge automatically.** Every index and counter is bounded by static constants and for-loop ranges, so the checks follow from types and no annotation is needed. The only new needs are a binary file-output operation plus basic arrays and integers.

Position 1426 in the [progression](../../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

The program fixes a page width of about 800 pixels and 11 bands of 40 pixel rows each, where band k uses stripes k pixels wide, and holds eight RGB colours in a constant array. For each band row it loops over the x positions, computes the colour index as (x / k) mod 8, and writes the three bytes of each pixel to a PPM file through an admitted file-output operation, with the failure outcome of that operation handled explicitly. Printing and ejecting are replaced by the image file, as the task allows smaller marks than native printer resolution. About 60 lines.

## Proof obligations to watch

- **index**: The colour index is computed as stripe number mod 8 into an 8-entry colour table, so the mod result keeps it inside the array range.
- **overflow**: Pixel x positions and stripe counts are bounded by a fixed page width and 11 bands, so every counter stays inside its declared range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, procedures and file output.

## External effects

- **files** (allowed): The program writes the stripe pattern to an image file (for example a binary PPM) instead of driving a printer.

Assessed on 2026-10-15 against page revision 377263 of the [task](https://rosettacode.org/wiki/Colour_pinstripe/Printer) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
