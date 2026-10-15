# Levenshtein distance/Alignment

**Candidate: proofs plausibly discharge automatically.** All checks come from declared index subtypes, for-loop ranges and guards just before each decrement or write, but the traceback's loop-carried indices and the bounded matrix cell values make discharge depend on careful program shape rather than being routine.

Position 711 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

Embed the two words as String constants, fill a 0..11 by 0..13 integer matrix with nested for loops over the constants' own ranges, then trace back from the corner in a procedure with a while loop that emits the aligned source and target characters (using '-' for gaps) into two fixed 24-character buffers from the end. Each step is guarded by explicit comparisons of I, J and the output position to zero, and the final rows are printed with Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: The traceback loop carries I, J and the output position through a while loop with no invariant, so each decrement and array access is preceded by an explicit guard (I > 0, J > 0, P > 0) and the indices have subtypes bounded by the string lengths.
- **overflow**: Matrix cells are stored in a bounded subtype, so the DP recurrence needs a guard that rejects or clamps-free-checks a candidate value above the subtype limit before assignment because min of three sums is not provably small without an invariant.
- **length**: The two output rows are filled backwards in fixed 24-character buffers and the used part is sliced, so the alignment length is guarded against the buffer capacity with a visible rejection outcome.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, procedures and Boolean objects.

## External effects

- **console output** (allowed): The two aligned rows are printed with Put_Line.

Assessed on 2026-10-15 against page revision 415112 of the [task](https://rosettacode.org/wiki/Levenshtein_distance/Alignment) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
