# Morpion solitaire

**Candidate: proofs plausibly discharge automatically.** All checks come from fixed array bounds, subtype ranges and explicit pre-index guards, and the only loops needing care are bounded for loops inside a procedure, but the triply nested candidate scan with loop-carried coordinates and nonlinear LCG arithmetic makes discharge depend on careful program shape.

Position 847 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The board is a fixed 2D Boolean array of occupied points plus four 2D Boolean arrays marking unit segments already used per direction (so parallel lines may touch at one end point but never overlap), seeded with the 36-point cross at an offset. Each turn a for loop scans every empty cell, direction and offset of the 5-point window, with bounds guards before every index, and picks one legal candidate by reservoir selection using a fixed-seed LCG; the chosen point and its four segments are marked and the move is printed. The game stops when no candidate exists or the fixed move cap is reached, and finally prints the move count. About 170 lines.

## Proof obligations to watch

- **index**: Every board access along a candidate line is guarded by an explicit coordinate range test before indexing, since the coordinates are loop-carried values with only subtype bounds.
- **overflow**: The deterministic linear congruential generator keeps its state in a bounded range (or a modular type) so the multiplication cannot overflow, and the move count and tally are bounded by the fixed move limit.
- **termination**: The play loop is a for loop over a fixed maximum number of moves with a done flag, so no variant is needed and the game still ends when no legal move remains.
- **range**: Selecting a random candidate uses mod of a count that is guarded to be positive, and the board must be sized large enough that a line never needs to leave it, with a specified stop outcome when a candidate would leave the grid.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and case statements.

## External effects

- **console output** (allowed): The program prints each move (point and line direction) and the final move count as text.

Assessed on 2026-10-15 against page revision 414972 of the [task](https://rosettacode.org/wiki/Morpion_solitaire) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
