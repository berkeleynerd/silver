# Sudoku

**Candidate: proofs plausibly discharge automatically.** Replacing the exception and recursion of the existing solution with an explicit-position backtracking loop in a procedure keeps every check tied to ranged subtypes or an immediate guard, so no annotation is needed. The nonlinear grid indexing and the loop-carried position need careful typing and guards, hence plausible rather than likely.

Position 469 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The puzzle is an embedded constant array of 81 digits of subtype 0..9, copied to a working grid and a fixed-cell constant array. An iterative backtracking procedure keeps a position typed 0..81, uses a while loop to advance past fixed cells, tries digits 1 to 9 using a for-loop-only Is_Valid function that checks row, column and box, and steps back with a guard when no digit fits (pos = 0 reports unsolvable). The result is printed as text rows with box separators using Put, Put_Line and digit characters, or an Unresolvable message. About 95 lines.

## Proof obligations to watch

- **index**: Grid indexes are computed as row*9+i from ranged subtypes (row, column and i all in 0..8), so the product bound must be proved nonlinearly, which range-typed operands should let the provers discharge.
- **range**: The backtracking position and trial digit are loop-carried in a while loop with no invariant, so each step and decrement needs an explicit guard (pos = 0 means unsolvable, digit = 9 means backtrack) just before the update, with the position typed 0..81.
- **termination**: The backtracking search lives in a procedure, which gets no termination check, and the function that tests a digit uses only for loops, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, functions, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): The solved grid, or an unsolvable message, is printed as text through Put and Put_Line.

Assessed on 2026-10-15 against page revision 413072 of the [task](https://rosettacode.org/wiki/Sudoku) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
