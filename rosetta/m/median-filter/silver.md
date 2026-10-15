# Median filter

**Candidate: proofs plausibly discharge automatically.** All indices are clamped by explicit guards or come from for loops over the arrays' own ranges, and values are bounded by declared subtypes, so only careful shape of the nested loops is needed with no annotation.

Position 695 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed a small fixed-size image (for example 6x6 of 0..255 gray or RGB records) as a constant 2D array, and use a fixed radius 1 giving a 9-element window array. For each pixel, a for-loop gathers the 3x3 neighbours with coordinates clamped by if guards, insertion-sorts the window by luminance in a procedure, takes the middle element, and writes it to a result array printed as text. About 70 lines.

## Proof obligations to watch

- **index**: Window coordinates I+dx are clamped with explicit if guards to the image bounds before indexing, so the array index checks follow from the guards.
- **overflow**: Luminance is a weighted sum of channel values in 0..255 held in a declared range type so the sum fits Integer.
- **index**: The insertion-sort shift loop uses a for loop over a fixed-capacity window array with while-loop position search in a procedure, where the position is bounded by its subtype and guarded before each use.
- **termination**: Binary search is replaced by a for-loop linear insertion inside procedures, so no loop variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, Put without a newline, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the filtered image as PPM-style text (or a summary) to standard output.

Assessed on 2026-10-15 against page revision 414337 of the [task](https://rosettacode.org/wiki/Median_filter) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
