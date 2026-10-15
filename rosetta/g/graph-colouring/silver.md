# Graph colouring

**Candidate: proofs likely to discharge automatically.** All data is fixed-size with ranged subtypes and for-loop indexes over array ranges, so index, range and overflow checks follow from types, and no loop needs an invariant or variant. The only care is a guard for the colour search finding nothing, which keeps this likely rather than certain.

Position 678 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Each example graph is embedded as constant arrays of edge endpoints (node numbers 0..8, fixed capacity 16 edges) plus a node count, and a procedure builds a Boolean adjacency matrix with for loops. Greedy colouring visits nodes in index order and, with a for loop over colours 1..8 and a found flag, picks the smallest colour not used by an already coloured neighbour; the maximum colour is tracked as a subtype-bounded value. Output uses 'Image-based text and Put_Line to print each edge's two colours and the node, edge and colour totals per graph. About 120 lines.

## Proof obligations to watch

- **index**: Edge endpoints and colours are subtypes of the node and colour ranges, and the adjacency matrix is indexed only by those subtypes, so the checks follow from types.
- **range**: The first-free-colour search could in principle find no colour, so the program ends the search with an explicit not-found guard that reports a visible failure rather than altering the result, and the colour count is bounded by the colour subtype.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints per-edge colours and the node, edge and colour counts for each of the four graphs.

Assessed on 2026-10-15 against page revision 414237 of the [task](https://rosettacode.org/wiki/Graph_colouring) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
