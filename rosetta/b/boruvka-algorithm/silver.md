# Borůvka algorithm

**Candidate: proofs plausibly discharge automatically.** All indexes and values come from small declared subtypes and for-loops over fixed bounds, so checks mostly follow from types, but the loop-carried parent links, counters and weight accumulator need careful subtype and guard shaping. No annotations are required once recursion and while loops are replaced by bounded for loops.

Position 917 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the 4-vertex, 5-edge example graph as a constant array of edge records with subtype-ranged vertex and weight fields, and keep a parent array of Vertex values with an iterative, for-loop-bounded find in a procedure. Run at most V stages in a for loop, each stage scanning edges to record the cheapest edge per component in arrays with a sentinel flag, then merge components with guards, accumulating the weight in a wide ranged integer. Print each included edge and the final weight using Image-based string building and Put_Line. About 110 lines.

## Proof obligations to watch

- **index**: Vertex and edge indexes are subtypes of fixed ranges (for example Vertex range 0..3), so array accesses follow from types and for-loop ranges over the arrays' own bounds.
- **overflow**: Edge weights are a small range subtype and the total is accumulated in a loop, so the accumulator's type must be wide enough (for example a range of 0..10_000_000 with weights capped at 1000 and at most 16 edges), or a guard is needed.
- **termination**: The outer stage loop is a while loop kept in a procedure and is replaced by a for loop over at most the vertex count, with each stage merging at least one tree or exiting, so no variant is needed.
- **other**: Find with path compression is recursive, so the program uses an iterative find in a procedure with a for loop bounded by the vertex count and no path compression, which still discharges without a variant.
- **other**: Facts like 'num_trees stays at least 1' are not known to the prover after loop iteration, so the tree counter must be a range subtype (1..V) with a guard before each decrement.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, records, for loops, while loops, procedures, 'Image of scalars, Put without a newline, string building, Boolean objects and conditional expressions.

## External effects

- **console output** (allowed): Prints each MST edge with its weight and the total MST weight.

Assessed on 2026-10-15 against page revision 414091 of the [task](https://rosettacode.org/wiki/Bor%C5%AFvka_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
