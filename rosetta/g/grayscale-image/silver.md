# Grayscale image

**Candidate: proofs likely to discharge automatically.** All checks follow from the declared 0..255 ranges, the fixed array bounds and for-loop indexes over those bounds, and the integer luminance formula avoids floating point and stays far below the Integer limit. No loop-carried value needs an invariant.

Position 665 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Define a Luminance subtype 0..255, a Pixel record of three Luminance channels, and fixed-size 2D arrays of Pixel and of Luminance with an embedded small test image. A procedure converts to gray with a nested for loop over the arrays' own ranges using the integer-weight formula (2126, 7152, 722 over 10000), and a second procedure replicates each gray value into all three channels. Both images are then printed row by row as text using 'Image and bounded string building. About 70 lines.

## Proof obligations to watch

- **overflow**: The weighted sum 2126*R+7152*G+722*B with channels in 0..255 is at most 2,550,000, so it fits Integer and the integer-weight formula needs no floating point.
- **range**: The quotient by 10000 is at most 255, which the provers can show by linear reasoning over the bounded channel ranges, so the conversion to the 0..255 Luminance subtype discharges.
- **length**: Row text is built in a fixed-capacity buffer sized for the embedded image width times the maximum digits per value, so the concatenation length checks follow from static bounds.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, records, arrays, multidimensional arrays, for loops, 'Image of scalars, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): The program prints the grayscale and the converted-back color images as plain-text PGM/PPM style rows.

Assessed on 2026-10-15 against page revision 414953 of the [task](https://rosettacode.org/wiki/Grayscale_image) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
