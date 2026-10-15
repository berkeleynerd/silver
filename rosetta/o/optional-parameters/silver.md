# Optional parameters

**Candidate: proofs likely to discharge automatically.** All checks follow from declared ranges: indexes come from for loops over static bounds or from a parameter of the index subtype, and a cell's trimmed length is bounded by the cell size. No while loop or recursion is needed, so nothing requires an annotation.

Position 1484 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

The table is a constrained array of rows, and each row is a constrained array of fixed-length, space-padded String cells. A procedure Sort takes the table as in out, plus Order_By (an enumeration with Lexicographic as default and By_Length as the alternative, chosen with a case statement), Column (a ranged subtype, default 1) and Reverse_Order (Boolean, default False). It sorts with a simple bubble sort written as nested for loops over static bounds, because Silver has no admitted sort routine. Main calls Sort with defaults, with positional arguments and with named association, printing the table after each call. About 90 lines.

## Proof obligations to watch

- **index**: The column parameter has a declared subtype equal to the row's index range, and the bubble-sort loops run over static subranges of the table's index type, so every index check follows from types.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, string indexing, string ordering, case statements, for loops, procedures and functions.

## External effects

- **console output** (allowed): The program prints the embedded table after each call to the sort procedure with a different mix of default, positional and named parameters.

Assessed on 2026-10-15 against page revision 411872 of the [task](https://rosettacode.org/wiki/Optional_parameters) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
