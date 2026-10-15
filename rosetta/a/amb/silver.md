# Amb

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size arrays and range-typed indices with a procedure-only while loop, so checks follow from types and guards, but the odometer loop and buffer assembly need careful shaping to avoid loop-carried unknowns.

Position 702 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Words are stored in a 2D Character table (set, choice) padded to a fixed capacity with a parallel length table, and an Amb-like procedure holds a choice index per set and advances them odometer-style with backtracking in a while loop with exit when. Each candidate is checked by a constraint function comparing the last character of one word with the first of the next, and the first success is copied into a bounded buffer and printed, with a specified message if none exists. All indices are range subtypes and increments are guarded by the set sizes. About 90 lines.

## Proof obligations to watch

- **index**: Word buffers are indexed by subtypes of the stored lengths and choice indexes are subtypes of each set's size, so a guard comparing length with zero and a range-typed index make the first and last character reads discharge.
- **overflow**: The odometer increment of a choice index is guarded by a comparison with that set's count just before the addition, so it cannot exceed the subtype.
- **length**: The output buffer is sized for the longest sentence and each word copy is guarded by the word length, so slice assignment lengths match only if the offsets stay in a bounded subtype.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, Boolean objects, for loops, while loops and procedures.

## External effects

- **console output** (allowed): The chosen sentence, or a specified no-solution message, is printed with Put_Line.

Assessed on 2026-10-15 against page revision 412644 of the [task](https://rosettacode.org/wiki/Amb) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
