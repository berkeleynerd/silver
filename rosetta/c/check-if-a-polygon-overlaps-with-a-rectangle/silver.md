# Check if a polygon overlaps with a rectangle

**Candidate: proofs likely to discharge automatically.** Replacing the Double coordinates with bounded integers makes every arithmetic result fit its declared subtype, and all loops are for loops over array ranges, so no annotation is needed.

Position 613 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Vertices are records of two ranged-subtype integer coordinates held in a constrained array, with the rectangle expanded into a 4-vertex array; a separating-axis test uses for loops over edge normals and a function that projects every vertex onto an axis keeping min and max in a bounded integer subtype. Next-vertex wrap uses an if guard, overlap returns False on the first separating axis, and main embeds the example polygon and two rectangles and prints true or false with if and Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: Coordinates are a documented subtype such as -1000..1000, so edge components, dot products and the min/max accumulators stay far below the Integer limit and the checks follow from types alone.
- **index**: The wrap-around next-vertex index is computed by an explicit if guard and every loop ranges over the array's own bounds, so index checks are routine.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, records, for loops, functions and procedures.

## External effects

- **console output** (allowed): Put_Line reports whether the polygon overlaps each of the two example rectangles.

Assessed on 2026-10-15 against page revision 415238 of the [task](https://rosettacode.org/wiki/Check_if_a_polygon_overlaps_with_a_rectangle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
