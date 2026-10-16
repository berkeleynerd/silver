# Gabow's algorithm

**Candidate: proofs plausibly discharge automatically.** Recursion is replaced by an explicit-stack loop inside a procedure over fixed-size arrays, so all indexing and counter checks follow from subtypes and local guards without annotations, though many loop-carried stack pointers require careful guarding.

Position 746 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the 13-vertex, 22-edge example as constant arrays of a Vertex subtype, and run Gabow's algorithm iteratively in a procedure using an explicit DFS call stack, per-vertex edge-cursor array (scanning the edge list), and fixed-capacity arrays for the two Gabow stacks, preorder, marked and id. Every push, pop and increment is preceded by a capacity or emptiness guard that rejects, and the results (count, per-component vertex lists, same-SCC queries and id lookup functions with range-checked parameters returning a sentinel on invalid vertices) are printed with Put and Integer'Image. About 170 lines.

## Proof obligations to watch

- **index**: The two Gabow stacks and the explicit DFS call stack have loop-carried top pointers that, without invariants, are known only by type, so each push is guarded by an explicit capacity check that rejects (never reachable for 13 vertices) and each pop by a non-empty check.
- **overflow**: The preorder counter, SCC count and per-vertex edge cursors are loop-carried and are kept in ranged subtypes with guards before each increment so the checks follow from type bounds.
- **range**: Edge endpoints come from embedded constant arrays of a vertex subtype, so using them as indices is safe by declaration, while the component id of an unassigned vertex (-1 sentinel) must be guarded before any use as an index.
- **termination**: The iterative DFS and stack-popping while loops live only in procedures, which get no termination check, and the result is simply bounded by the program's guards.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the SCC count, the vertices of each component, and the connectivity query results.

Assessed on 2026-10-15 against page revision 413185 of the [task](https://rosettacode.org/wiki/Gabow's_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
