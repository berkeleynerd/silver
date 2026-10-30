# Determine if two triangles overlap

**Candidate: proofs likely to discharge automatically.** The task only needs bounded integer geometry in loops over fixed ranges, so every check follows from declared coordinate ranges and for-loop bounds with no loop-carried value needing an invariant. Floating point is avoided by scaling the example coordinates to integers, so the proofs should discharge automatically.

Position 886 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Each triangle is a flat array of six Coord values (a ranged integer subtype) with all coordinates doubled so the 2.5 vertex becomes integer 5, and the seven example pairs are embedded as literals. A side function computes the integer cross product of an edge and a point, a same-side function compares the signs of two such values (non-strict, matching the product >= 0 test), and nested for loops over vertices and points compute the all-vertices/some-point test in both directions. A procedure prints true or false for each pair via if/else and Put_Line. About 75 lines.

## Proof obligations to watch

- **overflow**: The cross-product arithmetic is bounded because coordinates are a small ranged subtype (for example -100 to 100, doubled so 2.5 becomes 5), and the same-side test compares signs instead of multiplying two cross products, so no 32-bit overflow is possible.
- **index**: Vertex indexes are computed as 2 * ((V + 1) mod 3) inside for loops over 0 .. 2, so the bounds follow directly from the loop range and mod.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, functions, procedures and conditional expressions.

## External effects

- **console output** (allowed): Prints true or false for each of the seven triangle pairs with Put_Line.

Assessed on 2026-10-15 against page revision 414155 of the [task](https://rosettacode.org/wiki/Determine_if_two_triangles_overlap) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
