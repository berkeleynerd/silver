# Doubly-linked list/Definition

**Candidate: proofs likely to discharge automatically.** All checks follow from index subtype ranges and a capacity guard before allocation, with for loops and procedures only, so no annotation is needed. The no-circular-loops requirement is met structurally by only linking fresh nodes.

Position 609 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

The list is a fixed-capacity pool of nodes in arrays (or an array of records) holding Value, Prev and Next as a ranged index subtype 0..Capacity with 0 meaning null, plus Head, Tail and Count. Insert_Head, Insert_Tail and Insert_After are procedures that each allocate the next unused slot only when Count < Capacity (otherwise printing a rejection) and splice links; because every insertion uses a brand-new node, a cycle cannot form, and the demo traversal is a for loop bounded by Capacity. About 90 lines.

## Proof obligations to watch

- **index**: Node links are a ranged index subtype whose range includes the 0 null sentinel as an array bound, so every Prev/Next access is within the array by type alone.
- **range**: The node count increment is guarded by a Count < Capacity test that rejects insertion with a visible 'list full' message, and links are assigned only values of the index subtype.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, records, procedures, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the list contents forward and backward after head, tail and middle insertions to show the structure works.

Assessed on 2026-10-15 against page revision 414165 of the [task](https://rosettacode.org/wiki/Doubly-linked_list/Definition) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
