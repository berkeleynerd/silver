# N-queens problem

**Candidate: proofs plausibly discharge automatically.** All values are small ranged integers and every array access can be guarded just before use, and the only loop-carried state is the pair of cursors, so discharge depends on careful shape but needs no annotation. The search is an iterative procedure, so there is no recursion or termination obligation.

Position 236 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

The board is a one-dimensional array of eight row numbers, one per column (0 meaning empty), solved by an iterative backtracking while loop in a procedure with a column cursor and a row candidate. A for loop over earlier columns tests row and diagonal conflicts using differences of small ranged values, and the result is printed row by row with Put for cells and Put_Line for row ends, ending with the file-letter footer. If the search backs off the first column it prints a visible "no solution" line. About 70 lines.

## Proof obligations to watch

- **index**: The backtracking column and row cursors are loop-carried, so every Cols(Col) access sits directly under a guard that Col is in 1..8, and the column and row cursors have subtypes wide enough to hold the one-past-end value.
- **range**: Incrementing or decrementing the cursors and storing a row into the Integer range 0..8 component is guarded just before each assignment so no invariant is needed.
- **termination**: The search loop is a while loop inside a procedure, which receives no termination check, and the search is never put in a function.
- **other**: The no-solution branch is unreachable in fact but is kept as a visible Put_Line outcome rather than an assertion or a raise.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The program prints the found 8x8 board with Put and Put_Line.

Assessed on 2026-10-15 against page revision 415109 of the [task](https://rosettacode.org/wiki/N-queens_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
