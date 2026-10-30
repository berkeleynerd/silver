# Christofides algorithm

**Candidate: proofs plausibly discharge automatically.** Every step can be written iteratively over fixed-capacity arrays with typed ranges and explicit guards before each index, so no annotations are needed, but many loop-carried counters (stack pointer, adjacency counts, edge totals) make discharge depend on careful program shape.

Position 748 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the 100 points as a constant array of coordinate records, compute an integer-scaled Euclidean distance matrix (integer square root by a bounded for-loop search), and run Prim's MST with for loops over fixed-capacity arrays. Odd-degree vertices are collected into a bounded array and greedily matched, edges are stored in fixed-capacity adjacency arrays, and an iterative Hierholzer procedure with an explicit stack and guarded counters yields the Eulerian tour, which is shortcut with a visited array and printed via integer 'Image and Put_Line. About 380 lines.

## Proof obligations to watch

- **index**: The Hierholzer stack pointer, per-vertex adjacency counts and tour length are loop-carried, so each is typed with a range and guarded before every array access, with overflow of the fixed capacity leading to a visible rejection.
- **overflow**: Squared coordinate distances and the summed path length are bounded by declaring coordinate and weight subtypes whose products and sums fit in Integer or a 64-bit range.
- **termination**: The Hierholzer and integer square root loops are while loops inside procedures (no termination check), and the Prim and shortcut passes are for loops.
- **other**: True minimum-weight perfect matching (blossom) is far too heavy for annotation-free proof, so the program uses a greedy matching, which costs the 3/2 guarantee but keeps the pipeline faithful in shape.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The program prints the MST, odd vertices, matching, Eulerian tour, final path and its length as text lines.

Assessed on 2026-10-15 against page revision 414113 of the [task](https://rosettacode.org/wiki/Christofides_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
