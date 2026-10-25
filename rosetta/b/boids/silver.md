# Boids

**Candidate: proofs likely to discharge automatically.** The simple rule-based textual boids simulation uses only bounded integer coordinates, a fixed grid and for loops with explicit bounds guards before each array access, so every check follows from types and guards. The optional vector-based flocking with floating point is left out, and the task accepts the textual simulation.

Position 788 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The program stores the cave as a constant 16x86 Character grid of walls and free cells and keeps up to 18 boids as bounded x/y coordinate arrays, all initialised from embedded data. For a fixed number of frames a procedure moves each boid right if the target cell is inside the grid, not a wall and not occupied, otherwise tries up or down with the same guards, and another procedure prints the framed board using a bounded row buffer with Put_Line. Boids that cannot move simply stay in place, which is a specified visible outcome. About 110 lines.

## Proof obligations to watch

- **index**: Neighbour cells (x+1, y-1, y+1) are indexed only after explicit guards that the coordinates lie inside the declared 16x86 grid, with the frame cells also being walls so moves never leave the board.
- **overflow**: Frame counters and coordinates are subtypes bounded by the grid size and a fixed frame count, so loop-carried values stay in type range without invariants.
- **termination**: All iteration is for loops or while loops inside procedures with a fixed frame count, so no function needs a variant.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string building, for loops, while loops, procedures, functions, case statements and Put without a newline.

## External effects

- **console output** (allowed): The textual simulation prints each frame of the framed board with walls and boids to standard output.

Assessed on 2026-10-15 against page revision 415144 of the [task](https://rosettacode.org/wiki/Boids) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
