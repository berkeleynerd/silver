# Bitmap/Flood fill

**Candidate: proofs plausibly discharge automatically.** The iterative worklist fill needs only range-typed coordinates, boundary guards before each neighbour access and a stack sized to the cell count, so every check follows from types and guards and the while loop sits in a procedure. Discharge depends on careful program shape (a guarded stack top and loop-carried coordinates), but nothing needs an annotation.

Position 1183 in the [progression](../../../progression.md#stage-21), in stage 21.

## Approach

The image is a fixed 2D Character array (for example 16x16) embedded as aggregate rows, with a start point and fill character as constants. An iterative four-neighbour flood fill uses an explicit stack array of coordinates and a while loop in a procedure, marking cells when they are pushed and checking each neighbour's bounds with guards before indexing. The result is printed row by row with Put_Line, building each row string in a fixed-length buffer. About 70 lines.

## Proof obligations to watch

- **index**: Neighbour coordinates are computed only after explicit guards (X > 1, X < Width and so on) and stored in range-typed subtypes, so the array accesses discharge.
- **overflow**: The stack top counter has a declared range equal to the capacity and is incremented only after a guard that the stack is not full, so the increment cannot overflow.
- **termination**: The worklist loop lives in a procedure, which gets no termination check, and each cell is pushed at most once because it is marked as filled when pushed.
- **other**: Stack capacity equals the number of cells, so a push can never find the stack full, and a guarded visible reject path covers it regardless.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, for loops, while loops, procedures, Put without a newline, case statements and records.

## External effects

- **console output** (allowed): The filled image is printed as text art, one row per line.

Assessed on 2026-10-15 against page revision 414085 of the [task](https://rosettacode.org/wiki/Bitmap/Flood_fill) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
