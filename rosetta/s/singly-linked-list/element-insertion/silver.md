# Singly-linked list/Element insertion

**Candidate: proofs likely to discharge automatically.** The task needs only a linked structure, which an index-linked array pool expresses without pointers or recursion, and every index and range check follows from the ranged link subtype and explicit guards, so proofs should discharge without annotations.

Position 597 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

The list lives in a fixed-capacity array of records (Value : Character, Next : Link range 0 .. Capacity, where 0 means null) with a free-slot count, replacing access types. An Insert_After procedure takes the pool, anchor and value, and rejects with a visible Boolean failure outcome when the anchor is null or unused or the pool is full, otherwise it allocates the next free slot and splices it after the anchor. Main inserts A, B, then C after A, then walks the links with a for loop bounded by the capacity (stopping at null) to fill a fixed-size string and print A C B. About 55 lines.

## Proof obligations to watch

- **index**: Links are a ranged subtype (0 meaning null) used to index a fixed pool, and each dereference is guarded by an explicit test that the link is not null and the pool is not full, so the checks follow from types and guards.
- **initialization**: The whole pool is initialized by a full array aggregate and the string buffer is filled completely before output, so data-flow analysis needs no annotation.

## Language surface beyond today's Silver

Ranged subtypes, characters, arrays, records, for loops, procedures, Boolean objects, string indexing, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the resulting list order A, C, B to standard output.

Assessed on 2026-10-15 against page revision 413027 of the [task](https://rosettacode.org/wiki/Singly-linked_list/Element_insertion) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
