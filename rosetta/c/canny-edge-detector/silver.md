# Canny edge detector

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, bounded pixel subtypes and for-loop ranges, with no recursion or floating point needed, but the nested stencil sums and many bounded integer subtypes require careful program shape to discharge. The task does not require file or window I/O, so text art on a small embedded image is faithful.

Position 942 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The program embeds a small grayscale image as a constant 2D array of a 0..255 subtype, then runs Gaussian blur, Sobel gradients, non-maximum suppression and hysteresis as separate procedures over fixed-size 2D arrays of bounded integer subtypes. All loops are for loops over interior coordinates, direction is picked by integer comparisons, and hysteresis repeats a fixed number of propagation passes. The final edge map is printed row by row as characters using Put_Line and Put. About 170 lines.

## Proof obligations to watch

- **overflow**: Gaussian blur and Sobel sums are accumulated over fixed 3x3 or 5x5 windows of pixels typed 0..255, so the sum ranges are static and bounded, but the prover must bound each loop-carried sum by its declared subtype.
- **index**: Neighbour accesses are kept in range by running the loops only over interior coordinates (2..W-1, 2..H-1), so the offsets stay inside the fixed image bounds.
- **floating point**: The program avoids sqrt and atan2 by using integer gradient magnitude (|Gx|+|Gy|) and comparing Gx and Gy with integer ratio tests to choose one of four directions, which keeps the arithmetic integer-only.
- **termination**: Hysteresis tracing is done as a bounded number of full-image for-loop passes that promote weak pixels next to strong ones, instead of a stack-based while loop or recursion, so termination is automatic.
- **other**: The embedded input is a small synthetic image of fixed size, such as 16x16, and the result is printed as text art; this is a documented resource limit rather than a silent narrowing of the task.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, Put without a newline, 'Image of scalars and conditional expressions.

## External effects

- **console output** (allowed): Prints a text-art rendering of the detected edges (or a summary) to the console.

Assessed on 2026-10-15 against page revision 414102 of the [task](https://rosettacode.org/wiki/Canny_edge_detector) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
