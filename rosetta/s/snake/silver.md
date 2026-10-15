# Snake

**Candidate: proofs likely to discharge automatically.** Everything is bounded arrays, ranged coordinates and for loops with guards before each index, and the only while loop sits in a procedure, so no annotation is needed; the main care is guarding loop-carried length and head coordinates, and the interactive stdin plus random food are met by line input and a deterministic generator.

Position 1296 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The board is a fixed 10x10 grid, and the snake is two fixed-capacity coordinate arrays (100 entries) plus a length. The main procedure loops in a procedure reading one direction line per move from stdin, validating it (invalid or end of input ends the game with a stated outcome), then computes the new head, checks wall and self collision by for loops over the body, shifts the body, and on eating places new food using a deterministic LCG then scanning forward for a free cell. After each move the board is rendered into a bounded string buffer row by row and printed, and a collision prints Game over with the score. About 170 lines.

## Proof obligations to watch

- **index**: Head position after a move is computed from a ranged coordinate, so a guard rejecting off-board cells (game over) precedes every array index.
- **overflow**: The pseudo-random generator uses a modular type or a range-guarded multiply-and-mod so the product cannot overflow.
- **range**: The snake length is a subtype bounded by the board's cell count and growth is guarded by a full-board win outcome, so the increment is checked against that bound.
- **termination**: The input loop is a while loop with exit inside a procedure (no termination check), and food placement uses a for loop over cells instead of a retry while loop.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, string building, case statements, for loops, while loops, procedures, functions, standard input, 'Image of scalars and modular types.

## External effects

- **standard input** (allowed): Direction keys are read as lines from standard input, one move per line, so the player steers interactively.
- **console output** (allowed): The board is printed as text art after each move and the game-over message and score are printed at the end.

Assessed on 2026-10-15 against page revision 414884 of the [task](https://rosettacode.org/wiki/Snake) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
