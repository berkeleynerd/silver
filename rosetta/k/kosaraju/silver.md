# Kosaraju

**Candidate: proofs plausibly discharge automatically.** All checks are on small fixed-range arrays and ranged counters with guards before each push and increment, and the iterative DFS avoids recursion and function variants, but the loop-carried stack and finish-order indices need careful guards, so discharge is plausible rather than routine.

Position 721 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the graph as an 8x8 Boolean adjacency matrix aggregate, and run the first pass with an iterative DFS in a procedure using an explicit stack and per-node next-neighbour counters, recording finish order in an array. The second pass processes nodes in reverse finish order, running the same iterative DFS over the transpose (matrix indexed with swapped indices) to label components, then a for loop prints each node's component number with Put_Line. About 110 lines.

## Proof obligations to watch

- **index**: The explicit DFS stack index is guarded by a capacity check before each push (a rejection branch that is unreachable but visible), since no invariant can state that each node is pushed at most once.
- **index**: Order-array and per-node next-neighbour counters are of a node-range subtype so every index is within 0..7, with the counter guarded before increment.
- **termination**: The while loops live only in procedures, which get no termination check, and the DFS is iterative so no recursion or variant is needed.
- **initialization**: All arrays (visited, order, component, stack) are filled by aggregates or for loops before use so flow analysis sees them initialized.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, records, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the component number of each of the 8 nodes, one line per node.

Assessed on 2026-10-15 against page revision 414295 of the [task](https://rosettacode.org/wiki/Kosaraju) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
