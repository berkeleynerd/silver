# AVL tree

**Candidate: proofs plausibly discharge automatically.** The pointer-based, recursive, generic Ada solution can be recast as an array-indexed tree with iterative procedures, so index and range checks follow from types and guards, but the many loop-carried heights, balances and parent links make discharge depend on careful program shape rather than being routine.

Position 861 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Represent the tree as a fixed-capacity array of node records (key, left, right, parent, balance, height) addressed by a ranged index type with 0 as the null sentinel, avoiding access types and recursion. Insert iteratively in a procedure by descending with a while loop, reject duplicates and a full table with a visible outcome, then walk up the parent links to recompute heights and balances and apply single or double rotations chosen by explicit guards. Insert keys 1..10 in a for loop and print the balance factors in order using an iterative in-order walk with a bounded explicit stack, guarded against overflow. About 230 lines.

## Proof obligations to watch

- **index**: Nodes live in a fixed array indexed by a ranged subtype (0 is the null sentinel), so every loop-carried node index is in range by its type, and a full table is rejected by an explicit capacity guard before allocation.
- **range**: Heights and balance factors are ranged subtypes, so each height increment and balance computation needs a guard just before it (reject when the height limit would be exceeded), and the rotation code must be written so that each stored balance is clamped by guarded branches rather than by an invariant.
- **termination**: Insertion descent, upward rebalancing and in-order printing are written as while loops inside procedures, which get no termination check, and no recursion or function loops are used.
- **overflow**: Keys are a bounded integer range and comparisons and height sums stay within small ranged types, so arithmetic overflow follows from types and guards.
- **other**: Rotation correctness (that a child needed for a rotation is non-null) is not a proof obligation with a sentinel node at index 0, but the code should test the child before use so no later check depends on a tree-shape invariant.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, case statements, 'Image of scalars, Put without a newline and integer division.

## External effects

- **console output** (allowed): Prints the in-order balance factors of the tree after inserting the keys 1 to 10.

Assessed on 2026-10-15 against page revision 413146 of the [task](https://rosettacode.org/wiki/AVL_tree) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
