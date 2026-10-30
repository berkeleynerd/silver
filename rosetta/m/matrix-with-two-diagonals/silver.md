# Matrix with two diagonals

**Candidate: proofs likely to discharge automatically.** Every check is an index into a String by a for-loop variable over its exact range plus small constant integer arithmetic, so all of it discharges from types and static bounds with no loop-carried state. The only new capabilities are character assignment into a String and for loops, and the output is plain line printing.

Position 470 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A fixed side-length constant N (for example 9) and a single Row string of N characters initialized with an others aggregate are used instead of a 2D array. Nested for loops over 1 .. N pick row and column, assign '1' when Col = Row or Col + Row = N + 1 (else '0') into Row (Col), and Put_Line prints Row after each inner loop. All indexes come from for-loop ranges equal to the string's own bounds, so nothing needs a guard. About 22 lines.

## Language surface recorded by this assessment

Integers, characters, string indexing, arrays, for loops and ranged subtypes.

## External effects

- **console output** (allowed): Each matrix row is printed as a line of text via Put_Line, which meets the draw requirement without a GUI (the GUI is only an optional wish).

Assessed on 2026-10-15 against page revision 405044 of the [task](https://rosettacode.org/wiki/Matrix_with_two_diagonals) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
