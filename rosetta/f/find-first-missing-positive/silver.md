# Find first missing positive

**Candidate: proofs likely to discharge automatically.** All loops are for loops over array ranges or bounded integer ranges inside a procedure, with no loop-carried arithmetic, so every check follows from types and static bounds.

Position 1038 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Declare a bounded index subtype (1 .. 100) and an unconstrained Integer array type, with the three example arrays as constants with aggregates. A procedure Report scans candidates K in 1 .. Nums'Length + 1 with an outer for loop, searches Nums with an inner for loop over Nums'Range, and records the first K not found before exiting; by pigeonhole an answer always exists, and the default result is Nums'Length + 1. It prints the result with Put_Line using Integer'Image. About 35 lines.

## Proof obligations to watch

- **overflow**: The candidate Nums'Length + 1 cannot overflow because the array index type is a declared range such as 1 .. 100 that bounds the length.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, unconstrained arrays, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the three answers 3, 2, 1, one per line, with Put_Line.

Assessed on 2026-10-15 against page revision 407943 of the [task](https://rosettacode.org/wiki/Find_first_missing_positive) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
