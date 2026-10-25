# Red black tree sort

**Candidate: proofs plausibly discharge automatically.** Index-based arrays with a sentinel node turn all link accesses into type-range-safe indexing and the loops sit in procedures, so no annotations are needed, though the amount of tricky fixup code and bounded output building makes discharge depend on careful program shape.

Position 1200 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The tree is stored in fixed arrays of capacity 30 (key, left, right, parent, color) indexed by a 0..30 subtype with node 0 as the black sentinel, plus a free-slot stack for deletions, so no pointers or recursion are needed. Keys come from a bounded deterministic generator, insertion, deletion and both fixups are while-loop procedures with rotations as procedures, and a checker procedure validates the invariants after every insert and delete, printing a rejection message on failure. An iterative successor walk over parent links prints each key with its color, and the delete phase removes 15 of the inserted keys chosen by stepping through the stored key list. About 300 lines.

## Proof obligations to watch

- **index**: Every link is a node-index subtype 0..30 with index 0 as the black sentinel, so child, parent and uncle lookups on loop-carried indices stay in range by type, and the fixup loops walking toward the root need no invariant because the sentinel absorbs null links.
- **overflow**: The deterministic pseudo-random generator keeps its seed in a small range type and reduces it with mod before multiplying, so the product fits in a 64-bit type without needing an invariant.
- **termination**: Insert, delete, fixup and parent-chain loops all live in procedures, which get no termination check, and traversal is iterative via parent links rather than recursion.
- **length**: Output lines of keys and color names are assembled in bounded buffers sized for the largest key image plus color text, with explicit capacity guards before each append.
- **other**: The red-black integrity check (root black, no red-red, equal black height) is computed by walking parent chains and reports a visible failure message rather than being assumed, which keeps the guarantee honest but adds many nested loop-carried guards.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, enumerations, arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and case statements.

## External effects

- **console output** (allowed): The in-order listing of keys and colors and the integrity-check results are printed to standard output.

Assessed on 2026-10-15 against page revision 386584 of the [task](https://rosettacode.org/wiki/Red_black_tree_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
