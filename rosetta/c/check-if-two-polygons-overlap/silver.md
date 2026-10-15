# Check if two polygons overlap

**Candidate: proofs likely to discharge automatically.** Integer coordinates bounded by a declared range keep all dot-product and min/max checks inside Integer, and only for loops are used in functions, so no variants or invariants are needed.

Position 903 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Convex polygons are fixed-capacity arrays of 5 integer-coordinate points (records with ranged coordinates), embedded as aggregates, and the separating axis test runs with integer arithmetic instead of floating point. Functions use only for loops to compute edge normals, project both polygons onto each normal and compare min/max intervals, returning False at the first separating axis. Main prints each pair's result with literal strings chosen by an if. About 95 lines.

## Proof obligations to watch

- **overflow**: Coordinates are a subtype of -1000..1000, so edge components, dot products and running min/max stay far inside Integer and the loop-carried min/max are typed to a bounded Projection subtype that discharges without invariants.
- **index**: The next-vertex index wraps with an explicit if on the array's last index, so every access is within the constant 1..5 bounds.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, records, for loops, functions, procedures and conditional expressions.

## External effects

- **console output** (allowed): Prints the three pairwise overlap results with Put_Line.

Assessed on 2026-10-15 against page revision 414109 of the [task](https://rosettacode.org/wiki/Check_if_two_polygons_overlap) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
