# Singly-linked list/Element definition

**Candidate: proofs likely to discharge automatically.** The task only needs a record type with a numeric field and a mutable link, which an index-linked fixed array expresses without heap allocation, and all index checks follow from the ranged link type and a null-link guard.

Position 588 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

Define a record Element with a numeric Data : Integer and a mutable Next link of a ranged subtype 0..Capacity (0 meaning no next element) in place of an access type, held in a fixed-capacity array pool. A main procedure links three elements by assigning Next, then walks the chain with a for loop over the pool's index range and a guard on the link before each indexed read, printing each Data with Integer'Image. About 40 lines.

## Proof obligations to watch

- **index**: Link values are a ranged subtype 0..Capacity with 0 as the null link, and every traversal step guards the link against 0 just before indexing the pool, so the check discharges.
- **termination**: The traversal runs in a procedure (no termination check) and is bounded anyway by a for loop over the pool's own range.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, records, for loops, while loops, 'Image of scalars, string building and procedures.

## External effects

- **console output** (allowed): Prints the element values of a small demonstration list with Put_Line.

Assessed on 2026-10-15 against page revision 413026 of the [task](https://rosettacode.org/wiki/Singly-linked_list/Element_definition) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
