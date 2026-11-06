# Sorting algorithms/Tree sort on a linked list

**Candidate: proofs plausibly discharge automatically.** All indexing is typed by a ranged index subtype and null-guarded, and loops live in procedures so no variants are needed, but the traversal stack bound and loop-carried cursor indices depend on careful guard placement rather than invariants.

Position 263 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

Nodes live in fixed-size parallel arrays (Value, Prev, Next) indexed by a ranged Node_Index with 0 as null; a doubly linked list is built by a for loop over embedded integer data. Prev and Next are then reused in situ as left and right links by an iterative insertion procedure (while loop descending from the root), and an iterative in-order traversal with a bounded explicit stack relinks Prev and Next into a sorted doubly linked list that is printed forward with 'Image. About 90 lines.

## Proof obligations to watch

- **index**: Links are a subtype Node_Index (0 means null) so array accesses are in range by type, with an explicit test for 0 before each dereference.
- **index**: The explicit in-order traversal stack has capacity equal to the node count plus one and each push is guarded by a visible Reject when full, since without an invariant the prover cannot show depth stays within the node count.
- **termination**: The descent and traversal loops are while loops inside procedures, which get no termination check, and no function contains a loop.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the list before and after sorting, one value per line.

Assessed on 2026-10-15 against page revision 414509 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Tree_sort_on_a_linked_list) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
