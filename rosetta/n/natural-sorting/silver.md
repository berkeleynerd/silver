# Natural sorting

**Candidate: proofs plausibly discharge automatically.** The first four features (the extra-credit ones are optional) need only bounded buffers, guarded indexed scans and for-loop sorting, so every check follows from types and explicit guards with no annotation, though the paired-cursor comparison loops need careful guard placement.

Position 1488 in the [progression](../../progression.md#stage-28), in stage 28.

## Approach

Each embedded test string is copied into a fixed-capacity record (character array plus length), then normalized into another buffer by trimming, collapsing whitespace runs to one space, lower-casing and dropping a leading "the ". A comparison procedure walks both normalized buffers with guarded indexes, comparing non-digit characters directly and digit runs by stripped length then lexical order, returning a three-way result in an out parameter. A for-loop bubble sort over a constrained array of these records orders each group, which is then printed with Put_Line over slices. About 170 lines.

## Proof obligations to watch

- **index**: Scan positions in the key-building and comparison loops are loop-carried, so each is guarded by an explicit bound test (pos <= Length) just before every access to the fixed-capacity buffer.
- **length**: Normalized text is never longer than the input and the input is checked against the buffer capacity before copying, with over-long input rejected visibly, so appends cannot overflow the buffer.
- **overflow**: Numeric fields are compared as digit runs (leading zeros dropped, then length, then lexical order) instead of being converted to integers, so no arithmetic can overflow however long the run is.
- **termination**: All scanning while loops live in procedures, which get no termination check, and the sort uses for loops only.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, for loops, while loops, procedures, unconstrained arrays and string ordering.

## External effects

- **console output** (allowed): Prints each test group's title and its sorted strings with Put_Line.

Assessed on 2026-10-15 against page revision 412937 of the [task](https://rosettacode.org/wiki/Natural_sorting) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
