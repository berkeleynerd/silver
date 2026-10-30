# Color wheel

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared coordinate and channel ranges plus guards before divisions, but integer angle approximation and fixed-point products need careful shape, so discharge is plausible rather than routine; floating point and the numerics library are avoided entirely.

Position 1424 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Use a fixed radius constant and integer-only HSV: for each pixel in nested for loops over -Radius..Radius compute the squared distance, derive saturation as a 0..255 scaled value via a bounded for-loop square root search, and derive the hue sector (0..5) and fraction from an integer octant-based angle approximation with guarded divisions. A case statement over the sector picks the P, Q, T, V channel assignment into ranged-subtype color values, pixels outside the circle are black, and the header and pixel lines are built as bounded strings and written to a PPM file with a specified outcome if the file cannot be created. About 110 lines.

## Proof obligations to watch

- **overflow**: Squared distance and the fixed-point HSV products are bounded by declared coordinate and channel ranges (radius at most a few hundred, channels 0..255), so they fit in Integer.
- **division**: The integer angle approximation divides by the absolute x or y only inside branches guarded by a nonzero test, and the radius divisor is a nonzero constant.
- **range**: Hue sector, fraction and the 0..255 channel values are clamped by explicit guards or ranged subtypes so conversions to the color subtype cannot fail.
- **termination**: The integer square root and pixel scanning use only for loops or live in procedures, so no function needs a loop variant.
- **index**: Pixel loops run over the image's own coordinate ranges, so any array indexing follows from for-loop bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, records, case statements, for loops, while loops, procedures, functions, 'Image of scalars, string building, file output and arrays.

## External effects

- **files** (allowed): Writes the color wheel as a plain-text PPM image file through an admitted file-writing operation with a specified failure outcome.

Assessed on 2026-10-15 against page revision 414118 of the [task](https://rosettacode.org/wiki/Color_wheel) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
