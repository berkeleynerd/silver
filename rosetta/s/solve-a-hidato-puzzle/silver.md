# Solve a Hidato puzzle

**Candidate: proofs plausibly discharge automatically.** Every array index and counter is bounded by declared ranges or guards placed just before use, and recursion is replaced by an explicit stack in a procedure's while loop, so no annotation is needed, though the many loop-carried indices make the guard placement delicate.

Position 736 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The puzzle is embedded as a padded fixed-size integer grid (hole, blank, or given number) with a given-position lookup per number, and the search is an iterative backtracking while loop in a procedure using arrays that record the cell and next-direction index for each step instead of recursion. Each step tries the eight Moore neighbours under bounds guards, accepting a cell only if it is blank and not reserved for a later given, or holds exactly the required number; on exhaustion it backs up one step, and the result is printed row by row via bounded string building. About 130 lines.

## Proof obligations to watch

- **index**: Neighbour coordinates are bounds-guarded, or the grid is padded with a border of hole cells, before any array access.
- **range**: The loop-carried step number and direction counter live in ranged subtypes and are incremented only after a guard such as step < cell count.
- **termination**: The backtracking search is an iterative while loop with an explicit path stack inside a procedure, which gets no termination check, so no variant is needed.
- **other**: Exhausting the search prints a visible 'no solution' outcome, and the givens (1 and the cell count present) are validated at start.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string building, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the initial and solved boards as text rows.

Assessed on 2026-10-15 against page revision 414478 of the [task](https://rosettacode.org/wiki/Solve_a_Hidato_puzzle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
