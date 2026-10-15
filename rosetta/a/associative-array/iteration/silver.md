# Associative array/Iteration

**Candidate: proofs likely to discharge automatically.** Iteration over a small embedded fixed-capacity table with for loops over the array's own range needs only declared ranges and bounded slices, so every check follows from types.

Position 1157 in the [progression](../../../progression.md#stage-20), in stage 20.

## Approach

The associative array is a fixed-capacity constant array of three records holding a padded 5-character key buffer, a key length in 0..5 and an Integer value in a small declared range, in key order. Three for loops over the array's own range print key and value pairs, then keys only, then values only, slicing each key by its stored length and appending the value image. No input, so no validation is needed. About 35 lines.

## Proof obligations to watch

- **length**: Concatenating a key slice with an Integer image has a computed length, which discharges because the key length subtype is at most 5 and the values are in a small declared range.
- **range**: The key slice Key(1..Len) is in bounds because Len has a declared subtype 0..5 matching the fixed key buffer.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, records, string indexing, string building, 'Image of scalars, for loops and enumerations.

## External effects

- **console output** (allowed): Each key-value pair, then the keys alone, then the values alone are printed with Put_Line.

Assessed on 2026-10-15 against page revision 411599 of the [task](https://rosettacode.org/wiki/Associative_array/Iteration) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
