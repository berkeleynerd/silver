# OCR of text in image

**Candidate: proofs plausibly discharge automatically.** There is no fixed Oracle conflict because the task allows geometric line-gap measurement, and the bounded-array row scan is mostly ranged integer arithmetic that types and guards discharge, though real text recognition is the hard, uncertain part.

Position 1333 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Read a bounded grayscale PGM image into a fixed two-dimensional pixel array after validating its header and dimensions, compute a per-row ink count, and group consecutive inked rows into line bands recorded in a bounded array. Compare the vertical gap between consecutive bands with a threshold proportional to the average band height, and print each line followed by an explicit blank-line placeholder wherever the gap exceeds it. Reading and loops are in procedures with while loops guarded by capacity checks, and unreadable or oversized input prints a specified rejection. About 220 lines.

## Proof obligations to watch

- **index**: Pixel and row-band indexing is into fixed-capacity bounded arrays, with the header width and height validated against the capacity before any read and oversized images rejected visibly.
- **overflow**: Row ink sums, band heights and the average-height gap threshold are accumulated in loops, so they are held in ranged integer types sized from the image capacity bound so that type ranges alone discharge them.
- **range**: Loop-carried band counters must stay below the band array capacity, which needs an explicit guard before each band is recorded that rejects images with too many bands.
- **other**: Real glyph recognition is far larger than gap detection, so the faithful program recognizes layout geometry only and a limited template match of the known glyph set would be needed to print the text itself.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, while loops, procedures, functions, text parsing, string building, 'Image of scalars, file input and Put without a newline.

## External effects

- **files** (allowed): Reads the source image from a named file in a simple uncompressed raster format such as binary PGM.
- **console output** (allowed): Prints each text line (or its recognized stand-in) and a placeholder or empty line at every detected gap.

Assessed on 2026-10-15 against page revision 415220 of the [task](https://rosettacode.org/wiki/OCR_of_text_in_image) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
