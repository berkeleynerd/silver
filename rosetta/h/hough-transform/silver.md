# Hough transform

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over array ranges, and every arithmetic result is bounded by ranged types and scaled integer tables, so overflow and index checks follow from types plus one guard before the accumulator update. Floating point and image-file I/O are avoided, leaving bounded integer work whose discharge depends on careful program shape.

Position 696 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed a small bitmap (for example 32 by 32 rows of '#' and '.') as a constant array of equal-length Strings, and a constant table of 180 integer cosine and sine values scaled by 1000 in place of floating point. Nested for loops over the image's own index ranges and the angle range increment a two-dimensional ranged-count accumulator for each dark pixel, guarding the computed rho row index before indexing. A final nest of for loops maps each accumulator cell to a density character in a fixed-length row buffer and prints each row with Put_Line. About 90 lines.

## Proof obligations to watch

- **overflow**: Rho is computed as x*cos + y*sin with ranged coordinates and a scaled integer table, so the products and sum are bounded by types and fit in Integer.
- **index**: The computed rho row index is guarded by an explicit range comparison just before the accumulator update, and the guard is never taken for in-image pixels because the table scale bounds rho.
- **range**: Accumulator counts are ranged and incremented only when below the type maximum, which is at least the pixel count of the embedded image, so the saturation guard never changes a real result.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, for loops and procedures.

## External effects

- **console output** (allowed): The accumulator is printed as text art, one line per rho row, so no image file or display is needed.

Assessed on 2026-10-15 against page revision 414257 of the [task](https://rosettacode.org/wiki/Hough_transform) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
