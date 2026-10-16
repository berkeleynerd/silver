# Doubly-linked list/Traversal

**Candidate: proofs likely to discharge automatically.** All array indexes are covered by a 0..7 cursor subtype and a nonzero guard before each access, and the loops are in a procedure with fixed data, so no annotation is needed.

Position 441 in the [progression](../../../progression.md#stage-11), in stage 11.

## Approach

The list is modelled as fixed-capacity parallel constant arrays indexed 1..7: a Character value array holding "Rosetta" and Next and Prev link arrays of type 0..7 with 0 as the null link. A Main-level procedure walks from the head following Next while the cursor is nonzero, then from the tail following Prev, emitting each character and ending each pass with a line terminator. Output is done either with Put per character plus a newline or by accumulating into a bounded 7-character buffer and calling Put_Line. About 45 lines.

## Proof obligations to watch

- **index**: The cursor is a subtype 0..7 with 0 meaning no node, and each array access is preceded by a loop condition Cursor /= 0, so the index check follows from the type and the guard.
- **termination**: The link-following while loops live in a procedure, which gets no termination check, and the constant link arrays are acyclic by construction.

## Language surface beyond today's Silver

Characters, ranged subtypes, arrays, while loops, Put without a newline, procedures and string building.

## External effects

- **console output** (allowed): Prints the forward and then the reverse traversal of the list contents to standard output.

Assessed on 2026-10-15 against page revision 412753 of the [task](https://rosettacode.org/wiki/Doubly-linked_list/Traversal) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
