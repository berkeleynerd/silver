# Doubly-linked list/Element definition

**Candidate: proofs likely to discharge automatically.** The task only asks for the element definition with mutable next and previous links, which a bounded index-based record pool expresses without access types, and every check follows from declared ranges and for-loop indexes over the array's own range.

Position 586 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

Declare a ranged subtype Link_Index (0 .. 8, with 0 meaning null) and an Element record holding an Integer value plus mutable Next and Prev links of that subtype, stored in a fixed-capacity array pool. Main fills a few elements, assigns Next and Prev by index, then walks forward with a for loop over the pool's own range and prints each value with Put_Line. About 40 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, records, arrays, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the linked values to show the links work.

Assessed on 2026-10-15 against page revision 412751 of the [task](https://rosettacode.org/wiki/Doubly-linked_list/Element_definition) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
