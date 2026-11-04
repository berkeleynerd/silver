# Solve the no connection puzzle

**Candidate: proofs likely to discharge automatically.** Every check follows from Peg/Node types, for-loop indexes over their own ranges and a single-step abs on values bounded to 1..8, with no loop-carried value needing an invariant. The nested loops terminate by construction, so no variant is needed and the whole search lives in a procedure.

Position 533 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Define Peg as a subtype 1..8 and a Board as an array of eight Peg values indexed by an eight-value node range, plus a constant adjacency table of the 15 lines. Eight nested for loops over Peg assign each node in turn, skipping a value already used or one that differs by at most 1 from an already-placed neighbour, and a Found flag stops further work once a full solution is stored. The board is then printed as text art through Put_Line lines assembled from fixed-length strings with digits placed by Character'Val, and a fixed "no solution" line is printed if none is found. About 95 lines.

## Proof obligations to watch

- **index**: All array accesses use Node or Peg-typed indexes over the array's own range, so they discharge from types.
- **overflow**: Peg values are in 1..8 so abs of a difference is at most 7, which provers settle from type ranges.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, procedures, functions, string building and string indexing.

## External effects

- **console output** (allowed): The solved board is printed as text-art lines with Put_Line.

Assessed on 2026-10-15 against page revision 414018 of the [task](https://rosettacode.org/wiki/Solve_the_no_connection_puzzle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
