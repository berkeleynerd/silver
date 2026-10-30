# Penrose tiling

**Candidate: proofs plausibly discharge automatically.** Every check is bounded by declared coordinate ranges, fixed array capacity and for-loops in procedures, so no annotation is needed, but the fixed-point nonlinear arithmetic and string-buffer length reasoning require careful program shape.

Position 629 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Use the Robinson-triangle deflation (P3) with integer fixed-point coordinates scaled by a million and the golden ratio approximated by 618034/1000000, storing triangles as records of a color flag and three integer points in a fixed-capacity array. A procedure with a for loop over a fixed number of generations replaces each triangle with two or three smaller ones, guarded by a capacity check, then another procedure prints each triangle as an SVG polygon line using Integer'Image inside bounded string buffers. The ten initial triangles around the origin fill a bounded region and the SVG viewBox is cropped to a rectangle. About 150 lines.

## Proof obligations to watch

- **overflow**: Deflation computes new vertices as A + (B-A)*618034/1000000 in fixed-point integers; widening to a 64-bit type and bounded coordinate subtypes make the multiplication safe, but the final range check on the result depends on a nonlinear convex-combination argument the provers may need help with, so the program would compute in a wide intermediate type and keep coordinates in a generous declared range.
- **index**: The triangle arrays grow each deflation round, so a capacity check before appending is needed and a full buffer must give a visible rejection outcome, with the depth fixed so capacity is sufficient.
- **length**: Each SVG line is built in a bounded buffer from scalar images and literals, so the buffer length must be shown to exceed the worst-case text, which requires bounded coordinate digits.
- **termination**: All iteration sits in procedures with for loops over fixed depths and array ranges, so no function needs a variant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, records, string building, 'Image of scalars, for loops, while loops, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): The program prints the tiling as an SVG document on standard output, which meets the task without a display.

Assessed on 2026-10-15 against page revision 415421 of the [task](https://rosettacode.org/wiki/Penrose_tiling) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
