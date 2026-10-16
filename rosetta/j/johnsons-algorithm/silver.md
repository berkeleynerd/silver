# Johnson's algorithm

**Candidate: proofs plausibly discharge automatically.** Everything is bounded for loops over fixed-size arrays in procedures, so termination and indexing are routine, but loop-carried distance arithmetic needs explicit magnitude guards with a visible rejection outcome to discharge overflow without invariants.

Position 739 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the 4-vertex example as a fixed-capacity edge list (parallel arrays or a 2D weight matrix with a has-edge Boolean) with integer weights in a declared range, and use a Boolean-plus-value pair or a sentinel for infinity. A Bellman-Ford procedure from a virtual source runs fixed V passes with magnitude guards and reports a negative cycle visibly, then reweights edges, and an O(V^2) array-based Dijkstra procedure runs from each vertex, un-reweighting results. The matrix is printed with Image and Put, writing INF for unreachable entries. About 150 lines.

## Proof obligations to watch

- **overflow**: Bellman-Ford and Dijkstra distances and the reweighted edge cost h(u)+w-h(v) are loop-carried, so the program keeps weights in a small declared range, uses 64-bit distances, and guards each addition against a documented magnitude limit, printing a visible rejection when exceeded.
- **range**: Stored distances and potentials must fit their subtype, which the same magnitude guard before each assignment establishes without an invariant.
- **initialization**: The Dijkstra selected vertex is set to a default and paired with an explicit Found Boolean so it is never read uninitialized.
- **index**: Vertex indices are a declared subtype and edge arrays are walked with for loops over their own range, so indexing is routine except for the augmented source vertex, which gets its own index slot V+1.
- **termination**: All loops are bounded for loops inside procedures (V-1 relaxation passes, V Dijkstra rounds), so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, procedures, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): The all-pairs distance matrix, with INF for unreachable pairs, and any negative-cycle or range-rejection message are printed as text.

Assessed on 2026-10-15 against page revision 414278 of the [task](https://rosettacode.org/wiki/Johnson's_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
