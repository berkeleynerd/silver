# Bron–Kerbosch algorithm

**Candidate: proofs plausibly discharge automatically.** Every check follows from small ranged vertex indexes, for loops over fixed ranges and a guarded explicit stack that replaces recursion, but the loop-carried depth and counters need careful guard placement rather than being routine.

Position 1551 in the [progression](../../progression.md#stage-34), in stage 34.

## Approach

The graph is a constant edge list for vertices a to f embedded in the program and loaded into a symmetric Boolean adjacency matrix indexed by a small vertex subtype, with R, P and X as Boolean arrays held in a fixed-depth explicit stack frame array. A while loop in a procedure walks the stack: at each frame it picks the max-degree pivot from P union X by for loops, takes the next candidate in P not adjacent to the pivot, pushes the child frame with intersected sets, and on pop moves the vertex from P to X; maximal cliques of size over two are stored in a bounded list in index order, then printed in sorted order as comma-separated characters. About 150 lines.

## Proof obligations to watch

- **index**: The explicit stack depth is a loop-carried value, so every push is guarded by depth < capacity (capacity = vertex count + 1) with a visible Reject outcome, since without an invariant the prover cannot derive that depth stays below the bound.
- **overflow**: Pivot degree counts, clique sizes and output-buffer positions are carried through loops, so they use small ranged subtypes or are guarded before each increment.
- **termination**: The recursion is replaced by a while loop in a procedure, which gets no termination check, and the inner loops are for loops over the fixed vertex range.
- **stack**: Recursive Bron-Kerbosch is avoided entirely by an explicit fixed-size stack of R, P, X Boolean-array sets, so no input-dependent stack depth exists.
- **length**: Output lines and the stored clique list use fixed-capacity buffers sized for the required output, with a guard before each append and a visible rejection if capacity were exceeded.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, while loops, procedures, string building and membership tests.

## External effects

- **console output** (allowed): Each maximal clique is printed as a comma-separated line of vertex letters via Put_Line.

Assessed on 2026-10-15 against page revision 414095 of the [task](https://rosettacode.org/wiki/Bron%E2%80%93Kerbosch_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
