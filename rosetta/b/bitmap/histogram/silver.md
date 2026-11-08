# Bitmap/Histogram

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size arrays and for loops whose indexes follow from declared ranges, with the only non-routine checks being the loop-carried counts, which explicit guards with a visible rejection outcome can bound without an annotation.

Position 686 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

An embedded small grayscale image is a constant two-dimensional array of a 0..255 Luminance subtype, and a procedure fills a Histogram array indexed by Luminance with counts guarded against exceeding a declared count limit. The median is found by a for loop over Luminance accumulating a cumulative count until it reaches half the pixel total, then each pixel is compared with the median and written as a '#' or ' ' character into a fixed-width row buffer that is printed with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: Histogram counts and the running cumulative total are loop-carried, so the program guards each increment and addition against a declared count limit and rejects with a visible outcome rather than relying on an invariant.
- **index**: Pixel values are of a ranged Luminance subtype so histogram indexing and for-loops over the array's own ranges discharge from types.
- **length**: Each output row is built in a fixed-length String buffer filled by a for loop over the image width, so slice and assignment lengths are static.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string building, string indexing, for loops and procedures.

## External effects

- **console output** (allowed): The thresholded black-and-white image is printed as text art, one row per line.

Assessed on 2026-10-15 against page revision 414086 of the [task](https://rosettacode.org/wiki/Bitmap/Histogram) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
