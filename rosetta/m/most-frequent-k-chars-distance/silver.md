# Most frequent k chars distance

**Candidate: proofs plausibly discharge automatically.** Every operation is a bounded for-loop over arrays and strings with plain integer arithmetic, so the checks follow from types and guards, but several loop-carried counters need careful range subtypes and guards to discharge without invariants.

Position 629 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Strings are fixed-capacity buffers (a record of a length and a 128-character array); a procedure fills a 256-entry count array and a first-occurrence array by one for loop, then k for-loop rounds each pick the unselected character with the highest count, breaking ties by the smaller first position, marking it in a Boolean array. Similarity sums count1+count2 for characters selected in both, and the distance is n minus that; the five examples are embedded and printed with 'Image through Put_Line, with oversize inputs rejected explicitly. About 110 lines.

## Proof obligations to watch

- **overflow**: Per-character counts and the similarity sum are loop-carried, so each increment is guarded against a documented limit (oversize inputs are rejected visibly) and the sum is held in a subtype whose bound makes the addition safe.
- **index**: Counts are indexed by Character'Pos in an array declared over the full Character range, and string positions come from for loops over the string's own range, so indexing is routine.
- **range**: The first-occurrence position and selection results are stored in ranged subtypes and must be guarded because loop-carried values are known only by type.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, 'Image of scalars, for loops, procedures and functions.

## External effects

- **console output** (allowed): Prints each string pair with its SDF value, including the 100-length protein example.

Assessed on 2026-10-15 against page revision 387691 of the [task](https://rosettacode.org/wiki/Most_frequent_k_chars_distance) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
