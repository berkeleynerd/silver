# Fibonacci word/fractal

**Candidate: proofs plausibly discharge automatically.** All data are bounded arrays and subtypes with for loops over known ranges, and the only loop-carried values (word length, turtle position) are protected by explicit guards, so no annotation is needed but the program shape matters. A text-art render meets the display requirement without graphics.

Position 818 in the [progression](../../../progression.md#stage-14), in stage 14.

## Approach

The program builds a fixed Fibonacci word (for example F_word of about 12 steps, a few hundred characters) in a bounded Character array by iterative concatenation of two buffers, then walks a turtle over that word with a for loop, using direction 0..3 and step 2, setting cells in a fixed-size 2D Character grid. Each move is preceded by a guard that the destination is within the grid, and the grid rows are then printed through Put_Line using bounded string building. About 90 lines.

## Proof obligations to watch

- **index**: The turtle's x and y are loop-carried and the prover cannot bound them without an invariant, so each step is guarded by an explicit check that the next cell lies inside the grid, and an out-of-grid walk is reported as a visible rejection.
- **range**: The word buffer lengths in the iterative Fibonacci construction (F(k) = F(k-2) followed by F(k-1)) are loop-carried, so each append is guarded by a capacity check before it, and the fixed word index is stated by a for loop over the buffer's own range.
- **overflow**: The direction counter is kept in a 0..3 subtype and updated with a mod 4 expression, and the coordinates are bounded subtypes, so the arithmetic stays within range after guards.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string building, for loops, while loops, case statements, procedures and records.

## External effects

- **console output** (allowed): The fractal is rendered as text art, one grid row per line, on standard output.

Assessed on 2026-10-15 against page revision 415015 of the [task](https://rosettacode.org/wiki/Fibonacci_word/fractal) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
