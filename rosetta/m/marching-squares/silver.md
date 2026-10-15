# Marching squares

**Candidate: proofs likely to discharge automatically.** The task is only "generate contours", so a fixed embedded grid with per-cell case lookup uses for loops over the array's own ranges and small ranged integers, so every check follows from types and bounds. No loop-carried state, recursion or annotation is needed.

Position 782 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed a small constrained 2D Integer scalar field and a constant threshold, then use nested for loops over every cell to compute a 4-bit case code from the corner comparisons against the threshold. A case statement over 0..15 emits the contour segments for that cell as text, with edge midpoints given in doubled integer coordinates (no interpolation), printed with Put_Line and 'Image. All indices come from the array's own ranges, so no loop-carried value exists and no while loop or recursion is used. About 70 lines.

## Proof obligations to watch

- **index**: Corner lookups at x+1 and y+1 are safe because the cell loops run over 1 .. Width-1 and 1 .. Height-1 of the array's own constrained bounds.
- **overflow**: Segment endpoint coordinates and the case code are small values in declared ranged subtypes, so sums such as 2*x+1 stay within the type range.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, case statements, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the contour segments (or a text-art rendering) of the embedded field to standard output.

Assessed on 2026-10-15 against page revision 415457 of the [task](https://rosettacode.org/wiki/Marching_squares) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
