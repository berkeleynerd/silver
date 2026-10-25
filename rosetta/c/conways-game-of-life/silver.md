# Conway's Game of Life

**Candidate: proofs likely to discharge automatically.** All indexing and arithmetic are bounded by static array ranges, for-loop indexes and a 0..1 cell subtype, so no invariant or variant is needed and the work lives in procedures using only for loops.

Position 657 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Use a constant-size two-dimensional array of 0..1 cells with a dead border, embed the blinker as the initial state, and compute each next generation into a second array with for loops over the interior, summing the eight neighbours and applying the rule with if/elsif. A procedure prints each generation row by row using Put for one character per cell and Put_Line to end each row, for three generations, and no input is read. About 70 lines.

## Proof obligations to watch

- **index**: Neighbour reads at I+-1 and J+-1 are discharged by looping only over the interior of a grid with a one-cell dead border, so for-loop bounds make every access static.
- **range**: The neighbour count is a sum of eight 0..1 cells (at most 8) held in a Natural or 0..8 subtype, so no overflow or range check can fail.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, characters and Put without a newline.

## External effects

- **console output** (allowed): Prints each generation of the blinker as text rows.

Assessed on 2026-10-15 against page revision 415368 of the [task](https://rosettacode.org/wiki/Conway's_Game_of_Life) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
