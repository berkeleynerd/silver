# Sort disjoint sublist

**Candidate: proofs likely to discharge automatically.** All indices come from fixed-range array subtypes and loops are for loops over static ranges, so every check follows from types and no invariant is needed.

Position 68 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Values are a constrained array of Integer indexed 1..8 and the indices are a 3-element array of a subtype 1..8, both embedded as constants or initialized variables. A procedure sorts an array with a bubble sort using nested for loops over fixed ranges and a temporary swap, and is applied first to the index array, then to the extracted values, which are written back at the sorted indices. The result is printed with Put and Integer'Image in a loop followed by a line terminator. About 45 lines.

## Proof obligations to watch

- **index**: Index values come from an array of a subtype 1..8 so every Values(Idx(I)) access is in bounds by type, with no guard needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the resulting eight values as one line of text.

Assessed on 2026-10-15 against page revision 414486 of the [task](https://rosettacode.org/wiki/Sort_disjoint_sublist) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
