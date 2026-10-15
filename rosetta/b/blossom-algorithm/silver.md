# Blossom algorithm

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed vertex bounds, ranged subtypes and sentinel guards, and the loops are while loops in procedures, so no annotation is needed; the plausible rating reflects the many loop-carried indices that each need a guard just before use.

Position 852 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The program embeds the 5-cycle example (and possibly one more graph) as a constant edge array, builds a fixed-capacity N-by-N adjacency matrix, and runs Edmonds' BFS blossom search with array-based match, parent, base, used and blossom-flag tables plus a circular queue. All loops that cannot be for loops are while loops inside procedures, vertex indices use a ranged subtype with an explicit none value, and every parent or match dereference is guarded by a test for the none value. It then prints the matching size and the matched pairs with Put_Line. About 170 lines.

## Proof obligations to watch

- **termination**: The BFS queue loop, the LCA parent-walk loops and the path-flip loop are while loops, so they live in procedures (the LCA walks return their result through an out parameter) and procedures get no termination check.
- **index**: Vertex ids and -1 sentinels are carried through match, parent and base arrays in loops, so every array read of a loop-carried value needs an explicit guard against the no-vertex sentinel (a Vertex_Or_None subtype with a branch on None), with the not-found case rejected visibly.
- **range**: The circular queue head, tail and count are loop-carried, so they are kept in subtypes with a capacity of N*N and updated with explicit wrap guards instead of mod on unbounded values.
- **overflow**: Flattened adjacency indexing v*N+i and the matching-size counter stay within small declared ranges, so the arithmetic is bounded by types with fixed N.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars, Put without a newline, string building and case statements.

## External effects

- **console output** (allowed): Prints the matching size and matched pairs for the embedded example graph.

Assessed on 2026-10-15 against page revision 413973 of the [task](https://rosettacode.org/wiki/Blossom_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
