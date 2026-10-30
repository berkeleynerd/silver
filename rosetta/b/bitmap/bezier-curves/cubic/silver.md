# Bitmap/Bézier curves/Cubic

**Candidate: proofs likely to discharge automatically.** Every value is a function of a for-loop index over subtypes with small declared ranges, so all overflow, division and index checks follow from types and static bounds with no loop-carried state, though nonlinear integer arithmetic needs the ranges to be tight.

Position 883 in the [progression](../../../../progression.md#stage-15), in stage 15.

## Approach

The program holds a 16x16 array of Character initialised to blanks, computes 21 curve points with integer-only Bernstein arithmetic (sample index 0..20, numerator divided by 8000) from embedded control points, and joins consecutive points with a Draw_Line procedure. Draw_Line steps a for loop over the longer axis and computes the other coordinate directly with rounded integer division from the loop index, so nothing is carried between iterations; the bitmap is then printed row by row through a String buffer. About 70 lines.

## Proof obligations to watch

- **overflow**: The Bezier numerator sums four products of at most 20^3 times a coordinate of at most 16, which fits easily in Integer, and the discharge relies on coordinates and the sample index being declared range subtypes.
- **range**: Each interpolated pixel is computed with a fresh value per for-loop iteration (no loop-carried error term), and a guard that rejects out-of-bitmap points keeps the 2D array index in range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, for loops, procedures and conditional expressions.

## External effects

- **console output** (allowed): The rendered 16x16 text-art bitmap is printed row by row to standard output.

Assessed on 2026-10-15 against page revision 414083 of the [task](https://rosettacode.org/wiki/Bitmap/B%C3%A9zier_curves/Cubic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
