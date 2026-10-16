# Greyscale bars/Display

**Candidate: proofs likely to discharge automatically.** All arithmetic is small, bounded integer work driven by for-loop indexes with ranged types, so every check follows from types and static bounds. The only new needs are file output and integer-to-text formatting, which are library and surface growth rather than proof difficulty.

Position 1422 in the [progression](../../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

The program writes a P2 PGM file of 64 columns by 64 rows, split into four 16-row bands with 8, 16, 32 and 64 bars; the second and fourth bands are reversed. Nested for loops over the band, the bar index and the pixel columns compute each pixel as the bar index times 255 divided by (bars minus 1), where the bar index is the column divided by the bar width (64 divided by the bar count); the band's bar count is doubled each iteration, so no exponentiation is needed. Each row is assembled in a bounded string buffer from the numeric images and written with a Put_Line-style file operation. About 45 lines.

## Proof obligations to watch

- **overflow**: The grey level B*255/(N-1) is computed from for-loop indexes of ranged subtypes (B at most 63, N at most 64), so the product stays far below Integer'Last and the divisor is at least 7.
- **range**: The computed grey value is at most 255 and, for the reversed rows, 255 minus a value in 0..255, so it fits a 0..255 subtype.
- **length**: Each output line is built in a fixed-size bounded buffer sized for 64 values of up to 3 digits plus spaces, with the length checked before each append.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, 'Image of scalars, string building, Put without a newline, file output and procedures.

## External effects

- **files** (allowed): Writes the bars as a plain-text PGM image file, which meets the display requirement without a window.

Assessed on 2026-10-15 against page revision 412408 of the [task](https://rosettacode.org/wiki/Greyscale_bars/Display) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
