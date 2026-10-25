# Sunflower fractal

**Candidate: proofs plausibly discharge automatically.** Every loop is a bounded for loop over static ranges and pixel stores are guarded, so the main difficulty is floating-point range bounding for trig and power, which makes automatic discharge plausible but dependent on careful program shape.

Position 1425 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

The task is underspecified (draw a sunflower fractal), so the program fills a fixed 400x400 pixel array by looping over seed index 0..2000, computing radius and golden-angle position with Float trig, and stamping a small disc at each position after bounds guards. A final procedure writes the buffer as a PPM file with fixed-size line buffers, reporting a write failure through the admitted file library. All loops are for loops over static ranges, so no termination or invariant issues arise. About 90 lines.

## Proof obligations to watch

- **floating point**: Sin/Cos of the angle and the power i**1.618 need bounded operands and results to avoid overflow and range checks, which Silver can get by using fixed-size loops with range-limited Float types and clamped conversions.
- **range**: Converting computed floating coordinates to pixel indices must be guarded by explicit bounds tests so out-of-bounds points are skipped visibly before indexing the image buffer.
- **index**: Plotting disc pixels into a fixed 400x400 buffer needs a guard before each store, since the coordinates are computed rather than for-loop indexes over the array range.
- **overflow**: The golden-angle accumulation can be reduced each iteration to stay within a fixed range, avoiding unbounded growth.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, functions, string building, 'Image of scalars, file output, Put without a newline, floating point and characters.

## External effects

- **files** (allowed): The picture is written as an image file (for example a PPM or BMP) instead of drawn on a display.
- **console output** (allowed): Optionally report completion or rejection on the console.

Assessed on 2026-10-15 against page revision 414535 of the [task](https://rosettacode.org/wiki/Sunflower_fractal) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
