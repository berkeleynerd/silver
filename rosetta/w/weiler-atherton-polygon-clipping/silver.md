# Weiler-Atherton polygon clipping

**Candidate: proofs plausibly discharge automatically.** Everything uses bounded integer arithmetic, fixed arrays and while loops inside procedures, so checks follow from ranged types and guards, but the many loop-carried list indexes and link updates make discharge depend on careful program shape.

Position 640 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Polygons are fixed-capacity arrays of integer-coordinate point records with ranged coordinate subtypes, and the subject and clip vertex lists are arrays with intersection flag, entering flag, and cross-link index components in place of pointers. A procedure finds all edge-pair crossings with guarded integer arithmetic, inserts them into both lists in distance order, then a while-loop traversal in a procedure switches lists at intersections and marks visited entries until each closed path returns to its start. The embedded example polygons are clipped and the result polygons are printed, with capacity overflows and degenerate geometry reported as rejected input. About 230 lines.

## Proof obligations to watch

- **overflow**: Cross products and intersection numerators are discharged by declaring coordinates as a small ranged subtype (for example -1000 .. 1000) so every product and sum fits in Integer.
- **division**: The intersection division is preceded by an explicit guard that the denominator is nonzero, with parallel edges treated as having no crossing.
- **index**: Vertex lists live in fixed-capacity arrays with ranged index subtypes, each insertion is guarded by a capacity check that rejects overflow with a visible message, and cyclic next-index steps use explicit wrap-around guards.
- **termination**: The traversal and visited-flag loops are while loops in procedures, which get no termination check, and bounded step counters stop cycles through broken links.
- **other**: Degenerate cases (shared vertices, collinear or touching edges) must have a specified outcome such as rejecting the input, and integer rounding of intersection points changes geometry slightly and must be documented as the integer-grid contract.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the vertices of each resulting clipped polygon with Put_Line.

Assessed on 2026-10-15 against page revision 414583 of the [task](https://rosettacode.org/wiki/Weiler-Atherton_polygon_clipping) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
