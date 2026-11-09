# Suffix tree

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size arrays and index arithmetic whose bounds come from ranged subtypes and capacity guards, with no recursion or heap, so no annotation is needed. The loop-carried node and offset values in the insertion and splitting logic need careful guarding, which makes it plausible rather than likely.

Position 747 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the text banana$ as a constant, map its characters to a four-letter alphabet index, and store the tree in fixed-capacity arrays of node records (edge start, edge length) plus a two-dimensional child table indexed by node and alphabet index. Build it with the O(n^2) method of inserting each suffix in a procedure, walking down with a while loop and splitting an edge on mismatch, guarding node capacity before allocation. Print by an iterative depth-first walk with an explicit stack and a bounded prefix buffer, emitting each edge label with Put_Line in alphabetical child order. About 170 lines.

## Proof obligations to watch

- **index**: Node indices, edge offsets and child-table lookups carried through the insertion while loop stay in range only because they are declared with ranged subtypes and every new-node assignment is guarded by a capacity check.
- **overflow**: Edge start and length arithmetic during edge splitting is bounded by the text length subtype, so sums remain within the declared ranges given guards before each update.
- **termination**: Insertion and printing loops live in procedures, which get no termination check, and printing uses an explicit fixed-capacity stack instead of recursion.
- **length**: The printed prefix buffer must be built to a computed length within a fixed maximum, so the append is guarded by a depth check that stops output visibly if exceeded.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string indexing, string building, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The tree is displayed as indented text lines on standard output.

Assessed on 2026-10-15 against page revision 414528 of the [task](https://rosettacode.org/wiki/Suffix_tree) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
