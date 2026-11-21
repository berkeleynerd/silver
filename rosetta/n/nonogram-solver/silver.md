# Nonogram solver

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed 25-by-25 bounds, small ranged subtypes and for-loop indexes, and the iterative solver needs no recursion or annotations, but loop-carried indexes in the line-solving dynamic program and the explicit search stack need carefully placed guards.

Position 1196 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The four embedded puzzles are stored as clue strings parsed (letter minus 'A' plus 1) into fixed-capacity run arrays for at most 25 rows and 25 columns, with a grid of an enumeration type Unknown, Filled or Empty. A procedure repeatedly line-solves each row and column with a for-loop dynamic program over positions and run indexes, intersecting feasible placements until no cell changes, and an iterative explicit-stack backtracking procedure picks an unknown cell and tries both values when propagation stalls. Each puzzle prints the grid as '#' and '.' rows or a "No solution" line, and invalid or oversized clues print a specified rejection message. About 260 lines.

## Proof obligations to watch

- **index**: Clue letters are parsed into bounded per-line run arrays whose counts and positions come from loop-carried values, so each store needs a guard against the declared capacity that rejects oversized clues visibly.
- **overflow**: Run-length sums, dynamic-programming positions and cell counters are held in small ranged subtypes bounded by the 25-by-25 grid limit, with guards before each addition.
- **termination**: Constraint propagation and the backtracking search are while loops inside procedures with an explicit bounded stack, so no termination check arises and no function contains a loop without a for-loop bound.
- **index**: The explicit search stack depth is limited by the cell count, and a guard before each push makes the bound visible without an invariant.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, for loops, while loops, procedures, functions, case statements and Put without a newline.

## External effects

- **console output** (allowed): Prints each puzzle's solved grid as text rows, or a failure message, to standard output.

Assessed on 2026-10-15 against page revision 414360 of the [task](https://rosettacode.org/wiki/Nonogram_solver) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
