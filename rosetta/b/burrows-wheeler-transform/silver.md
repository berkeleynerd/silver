# Burrows–Wheeler transform

**Candidate: proofs plausibly discharge automatically.** Everything is bounded for loops over fixed-capacity arrays with range-subtype indices and mod-based wraparound, so checks follow from types and guards, though the sort comparison and inverse mapping need careful shaping. No annotations are required, and the nested loops carry no facts beyond types.

Position 1016 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Each test string is copied into a bounded Character buffer of capacity 64 with a length, after being checked for STX or ETX (rejected with a printed message), and then wrapped as STX, text, ETX. A rotation-start index array is sorted with a bounded bubble sort of for loops whose comparison function scans two rotations with (i+k) mod n indexing, and the last characters of the sorted rotations form the output. The inverse builds a stable rank mapping from the transformed buffer by counting, walks it for n steps in a for loop to rebuild the text, and prints it. About 130 lines.

## Proof obligations to watch

- **index**: Rotation indexing (start + k) mod n is discharged by a ranged subtype for n with n at least 1 and by mod yielding a value below n, and each test string is checked against the buffer capacity before use.
- **overflow**: All counters and rotation offsets are subtypes capped at the small buffer capacity, so sums such as start + k stay within Integer.
- **index**: The inverse follows the rank-permutation chain for exactly n steps in a for loop, and every stored index is of a range subtype bounded by the buffer length, so no loop invariant is needed.
- **length**: Output strings are assembled in a fixed-capacity buffer with explicit length guards, and over-long or marker-containing input is rejected with a visible message rather than truncated.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, string building, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints each embedded test string, its transform and the recovered original, plus a rejection message for input containing the STX or ETX markers.

Assessed on 2026-10-15 against page revision 412689 of the [task](https://rosettacode.org/wiki/Burrows%E2%80%93Wheeler_transform) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
