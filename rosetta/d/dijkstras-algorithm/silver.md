# Dijkstra's algorithm

**Candidate: proofs plausibly discharge automatically.** Dijkstra on a fixed 6-vertex graph needs only bounded for loops, small arrays and range-typed distances, so every check follows from types and local guards, though the nested loop-carried distance arithmetic needs careful shaping.

Position 705 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The graph is a 6x6 constant matrix of Natural weights with 0 meaning no edge, and Dist, Prev and Done arrays indexed by a Vertex subtype 1..6. A for loop of 6 rounds picks the unsettled vertex of least distance with an inner for loop, marks it done, and relaxes its outgoing edges under explicit guards against the Infinity sentinel. Paths to e and f are rebuilt by a bounded for loop that follows Prev back from the target into a small array and printed with Put_Line, with unreachable targets reported as no path. About 90 lines.

## Proof obligations to watch

- **overflow**: Distances are held in a bounded Natural subtype with an Infinity sentinel, and a candidate distance is added only after guarding that the settled distance is below Infinity and the sum stays within the subtype.
- **index**: Vertices are a subtype 1..6, so adjacency-matrix and distance indexes are in range by type, and path reconstruction walks predecessors only through typed vertex values.
- **termination**: The path walk is a for loop of at most 6 steps and the main selection loop is a for loop over 6 rounds, so no while loop or variant is needed.
- **range**: Loop-carried distances and predecessors are written only with values of their own subtype, with guards before each relaxation, so range checks follow from types.
- **length**: The path text is built in a fixed-capacity buffer sized for 6 vertices with separators, and the written length is bounded by the loop count.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the shortest paths and distances from a to e and f, one line each.

Assessed on 2026-10-15 against page revision 414935 of the [task](https://rosettacode.org/wiki/Dijkstra's_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
