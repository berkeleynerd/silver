# Singly-linked list/Traversal

**Candidate: proofs likely to discharge automatically.** Every index check follows from the cursor's subtype 0..10 plus the guard that it is nonzero just before indexing, and the for loop terminates by itself, so no annotation is needed.

Position 44 in the [progression](../../../progression.md#stage-4), in stage 4.

## Approach

The list is stored in fixed-capacity arrays indexed 1..10, a Value array of Integer and a Next array of a 0..10 subtype where 0 means the end, linked by a for loop and the head index held in a variable. Traversal is a for loop of exactly capacity iterations carrying a cursor of subtype 0..10, which prints Integer'Image of the element and advances to Next only when the cursor is nonzero. About 30 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Each visited element's value is printed with Put_Line.

Assessed on 2026-10-15 against page revision 413028 of the [task](https://rosettacode.org/wiki/Singly-linked_list/Traversal) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
