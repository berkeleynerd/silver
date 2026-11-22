# Xiaolin Wu's line algorithm

**Candidate: proofs plausibly discharge automatically.** The task has no required I/O beyond drawing, so text art from an integer fixed-point version needs only bounded arithmetic, for loops and guarded array indexing, which should discharge without annotations. The main care is bounding the loop-carried intersection value and keeping the plotted rows in range, so the outlook is plausible rather than likely.

Position 933 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Use a constant-size 2D array of intensity values 0..255 as a canvas, with line endpoints embedded as constants in a bounded coordinate range. Implement Wu's algorithm in integer fixed-point (scaled by 256) instead of floating point, with a procedure that swaps for steep and reversed lines and a for loop over x updating intersection y. Print the canvas as rows of shade characters chosen from the intensity, using Put_Line with a fixed-size line buffer. About 110 lines.

## Proof obligations to watch

- **overflow**: The gradient and intersection y are held as fixed-point integers (scaled by 256) within a small canvas, so every product and sum is bounded by the declared ranges.
- **index**: Each plotted y and y+1 is guarded against the canvas bounds before the array write, and out-of-canvas pixels are skipped as a visible specified outcome.
- **division**: The gradient division by dx is guarded by a dx = 0 branch that plots the single point.
- **range**: Loop-carried intersection y has no invariant, so it is typed with a wide fixed-point subtype and clamped by guards before conversion to a row index.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, procedures, functions, conditional expressions, string building and Put without a newline.

## External effects

- **console output** (allowed): The anti-aliased pixel grid is written as text art (grayscale characters) with Put_Line.

Assessed on 2026-10-15 against page revision 414594 of the [task](https://rosettacode.org/wiki/Xiaolin_Wu's_line_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
