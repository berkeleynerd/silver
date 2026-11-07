# Floyd-Steinberg dithering

**Candidate: proofs plausibly discharge automatically.** The task is under-specified, so a small embedded grayscale image with text-art output is faithful, and everything is for loops over fixed bounds with integer arithmetic clamped by guards. Discharge depends on careful clamping of loop-carried error values since there are no invariants, hence plausible rather than likely.

Position 808 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The program embeds a small fixed-size grayscale gradient as a constrained 2D array of a ranged Integer subtype, with a working copy of wider range, and quantises each pixel to black or white in nested for loops (rows then columns) inside a procedure. Integer-only error diffusion (shares of 7, 3, 5 and 1 over 16 using integer division) updates neighbours behind explicit bounds guards and clamps every updated cell to 0..255. Each output row is built as a fixed-width String of two characters and printed with Silver_IO.Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: Error diffusion carries pixel values between iterations with no invariant, so each working cell is stored as a wide declared Integer range and clamped to 0..255 by an explicit guard before every use and after every addition.
- **index**: Neighbour updates at x+1, x-1 and y+1 are each guarded by explicit comparisons against the fixed image bounds just before the write, so index checks discharge.
- **range**: Error shares are computed with integer division by 16 on an error bounded by 255 times 16, so the sums stay within the declared cell range once clamped.
- **length**: Each text row is built in a fixed-length String buffer of image width, filled by a for loop over the buffer's own index range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, for loops, procedures, functions, string building, Put without a newline and case statements.

## External effects

- **console output** (allowed): The dithered image is written as text art, one line per image row, using Silver_IO output.

Assessed on 2026-10-15 against page revision 414946 of the [task](https://rosettacode.org/wiki/Floyd-Steinberg_dithering) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
