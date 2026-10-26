# B-spline

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over static ranges and arithmetic is integer with ranged operands, so most checks follow from types, with only the computed grid index needing a guard before the write.

Position 681 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the 12 control points in a constant array of coordinate records, and evaluate a uniform cubic B-spline in pure integer arithmetic: for each of the 9 segments and each of 16 integer sub-steps, the four basis weights are cubic polynomials in the step scaled by 6 times 16 cubed, then summed per axis and divided by the scale. Mark the curve and control points in a fixed 2D Character grid (about 60 by 40, coordinates scaled down), then print each row through a bounded String buffer with Put_Line, with a guard before each grid write. About 70 lines.

## Proof obligations to watch

- **overflow**: The cubic basis products (t cubed times 6-scaled weights times coordinates up to 400) are bounded by small ranged subtypes for the step index and coordinates, so they fit in Integer by type ranges alone.
- **index**: The computed grid cell is derived from a sum of nonlinear weighted terms that the prover cannot bound without an invariant, so an explicit guard just before the write skips points outside the grid, which is safe because coordinates are in range by construction and the guard is visible in the code.
- **range**: Control point indices i to i+3 inside the segment loop are covered by a for loop over 0 .. 8 on a 12-element array, so they are static bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, records, for loops, procedures, string building, string indexing and Put without a newline.

## External effects

- **console output** (allowed): The rendered text-art plot of the curve and control points is printed line by line.

Assessed on 2026-10-15 against page revision 414069 of the [task](https://rosettacode.org/wiki/B-spline) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
