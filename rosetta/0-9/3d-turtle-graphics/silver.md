# 3d turtle graphics

**Candidate: proofs likely to discharge automatically.** The task only asks for a 3D house and bar chart, which text art meets, and integer projection over bounded grids has types or guards bounding every check.

Position 675 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the cube corners, pyramid apex and five bar heights as constant integer arrays, then rotate and orthographically project each vertex using scaled integer arithmetic with a fixed view angle. Draw each edge as a for-loop line over a fixed-size Character grid with a guard before each plot, then print the grid rows with Put_Line. All loops are for loops inside procedures, with no recursion, and the house and chart are drawn side by side in one grid. About 110 lines.

## Proof obligations to watch

- **overflow**: Integer-scaled rotation and projection arithmetic is discharged by declaring coordinates as small ranged subtypes and using a fixed table of precomputed sine and cosine values.
- **index**: Projected points are clipped by an explicit guard to the character grid bounds before each plot, and out-of-grid points are skipped as a documented behavior.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string building, for loops, procedures, functions, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints a text-art projection of the house and bar chart to standard output.

Assessed on 2026-10-15 against page revision 414037 of the [task](https://rosettacode.org/wiki/3d_turtle_graphics) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
