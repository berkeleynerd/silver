# Image convolution

**Candidate: proofs plausibly discharge automatically.** Every check follows from small declared ranges, border guards placed just before indexing, and an unrolled nine-term sum with no loop-carried accumulator, so no annotation is needed; the main care is keeping integer kernel coefficients (real-valued kernels replaced by scaled integers) tightly bounded.

Position 702 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed a small constrained 2-D array of Pixel (0..255) as the test image and a 3x3 constant array of integer coefficients plus a positive divisor (for example sharpen and box blur), and write a Filter procedure that reads the input image and writes a separate output image. For each pixel, guarded neighbor reads (zero outside the image) feed one unrolled nine-term weighted sum, which is divided by the divisor, clamped to 0..255 by if statements, and stored; the result is printed row by row with Put and Put_Line. About 90 lines.

## Proof obligations to watch

- **overflow**: Each output pixel is a nine-term sum written as one unrolled expression over Pixel (0..255) and Coefficient (-16..16) subtypes so the bound follows from types, avoiding a loop-carried accumulator that would lose its range.
- **index**: Neighbor reads at the image border are guarded by explicit row and column comparisons before indexing (out-of-image neighbors count as zero), and row/column loops run over the array's own ranges.
- **range**: The scaled sum is clamped to 0..255 by explicit if tests before conversion back to Pixel, so the narrowing conversion discharges.
- **division**: The kernel divisor is a constant subtype of positive integers (1..64), so division by zero cannot occur.
- **overflow**: The conversion of pixels and coefficients to a wider working range for the product relies on solver handling of small nonlinear products, which is routine given the tight type bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The filtered grayscale image is printed as rows of numbers (text PGM-style) and optionally the original for comparison.

Assessed on 2026-10-15 against page revision 414656 of the [task](https://rosettacode.org/wiki/Image_convolution) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
