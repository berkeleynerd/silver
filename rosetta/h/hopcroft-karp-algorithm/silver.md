# Hopcroft-Karp Algorithm

**Candidate: proofs plausibly discharge automatically.** Every array index and counter is bounded by ranged subtypes and capacity guards, so checks are routine, but the recursive DFS must be restructured into an explicit-stack procedure whose loop-carried state needs careful guards, with no annotation required.

Position 732 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Represent the graph as a fixed-capacity adjacency matrix or edge array of Boolean/ranged indexes with vertex 0 as NIL, an integer distance array with a sentinel INF, and a fixed-size array queue. The BFS is a procedure with a while loop returning an out Boolean, and the DFS is an iterative procedure with an explicit stack of vertices and per-vertex neighbor cursors, all guarded against capacity. The main procedure runs phases until BFS finds no augmenting path and prints the matching size for the embedded 4x4 example. About 130 lines.

## Proof obligations to watch

- **termination**: The BFS queue loop and the outer phase loop are while loops, which is fine in procedures, and the DFS must be written as an explicit-stack procedure, since a function would need a variant and recursion depth is unbounded.
- **index**: Queue head and tail are loop-carried values, so each enqueue is guarded by tail < capacity, and since each vertex is enqueued at most once the capacity guard never changes the result; adjacency indexes are ranged subtypes.
- **overflow**: Distances and the matching size are subtypes bounded by the vertex count, and increments are guarded by comparisons so the checks discharge from the types alone.
- **other**: The explicit-stack DFS with per-vertex edge cursors must carry stack depth and cursors as loop-carried values bounded by their subtype ranges, which needs careful program shape but no annotation.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the maximum matching size for the embedded example graph.

Assessed on 2026-10-15 against page revision 414254 of the [task](https://rosettacode.org/wiki/Hopcroft-Karp_Algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
