# Pentomino tiling

**Candidate: proofs plausibly discharge automatically.** Everything is bounded arrays and small ranged integers, and the search can be turned into an iterative procedure with explicit stack and guards, so no annotations are needed, but the loop-carried indices and the backtracking state require careful program shape.

Position 866 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The 12 pentominoes' orientations are embedded as constant tables of cell offsets in arrays, with the 4 holes chosen by a deterministic pseudo-random generator held in a small modular or bounded-range state. An iterative backtracking procedure with an explicit stack arrays fills the first empty cell with each unused shape orientation, guarding every offset against the 8x8 bounds before touching the grid. If no solution exists for the chosen holes the program prints a visible 'no solution' message, otherwise it prints the grid with letters and '-' for holes. About 230 lines.

## Proof obligations to watch

- **termination**: The backtracking search is written as an iterative procedure with an explicit fixed-size stack and while loops, since procedures get no termination check and recursion depth would be unbounded for the prover.
- **index**: Every grid and placement-table access is guarded by explicit bounds tests on the row and column offsets before use, because the loop-carried cursor and stack depth are known only by type range.
- **range**: The stack depth and position cursor are declared with subtypes bounded by 12 and 64 and guarded before each increment or decrement, with a visible outcome if a bound is hit.
- **overflow**: All counters and positions are small ranged subtypes, so the arithmetic on them stays within Integer.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, Put without a newline, string building and case statements.

## External effects

- **console output** (allowed): Prints the 8x8 tiling grid, one row per line.

Assessed on 2026-10-15 against page revision 414387 of the [task](https://rosettacode.org/wiki/Pentomino_tiling) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
