# Bitmap/Write a PPM file

**Candidate: proofs likely to discharge automatically.** All indexes and conversions follow from constant dimensions, for-loop ranges over the array's own bounds and 0..255 channel subtypes, so only the missing binary file-output library operation stands between Silver and this program.

Position 1417 in the [progression](../../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

The program declares a fixed-size pixel array (e.g. 16 by 16) of records with 0..255 Red, Green and Blue components, fills it with an embedded gradient via nested for loops, and builds the P6 header from the constant dimensions using 'Image. A procedure then writes the header followed by each row, packed into a fixed-size byte buffer indexed by the for-loop variables, through an admitted binary file-write operation, and reports or rejects on a write failure. About 55 lines.

## Proof obligations to watch

- **index**: The row buffer index 3*J+k is bounded because J is a for-loop index over the fixed image width and the buffer is sized three times the width.
- **range**: Character'Val of a color channel is safe because channels are a 0..255 subtype and the conversion target covers it.
- **length**: The header text is built in a bounded buffer whose capacity covers the fixed width, height and 255 digits, so concatenation lengths are statically bounded.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, records, for loops, 'Image of scalars, string building, procedures, file output and Put without a newline.

## External effects

- **files** (allowed): Writes a binary P6 PPM file through an admitted file-output operation with a specified failure outcome for unwritable paths.
- **console output** (allowed): Reports success or the rejection of a failed write with Put_Line.

Assessed on 2026-10-15 against page revision 414088 of the [task](https://rosettacode.org/wiki/Bitmap/Write_a_PPM_file) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
