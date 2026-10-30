# Greed

**Candidate: proofs likely to discharge automatically.** All checks follow from ranged types, a fixed 79 by 22 array and per-step bounds guards before each indexing, and the loops sit in procedures so no termination annotation is needed; the missing pieces are only Silver surface growth such as 2D arrays, loops, stdin and unbuffered Put.

Position 1220 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The board is a two-dimensional array of 0..9 cells (0 meaning eaten) filled by a mod-bounded linear congruential generator, with the cursor stored as ranged column and row variables. A procedure-based game loop prints the grid row by row from a 79-character buffer, reads a direction letter line (Q W E A D Z X C) from standard input, maps it with a case statement to dx and dy, validates every step of the move against the grid edge and eaten cells before erasing, and rejects invalid moves with a message. After each move it scans the eight directions for any legal move and ends the game with the final score when none remain or input ends. About 170 lines.

## Proof obligations to watch

- **overflow**: The deterministic generator state is kept in a ranged type and reduced with mod each step so the multiply cannot overflow.
- **index**: Every step of a move computes the next column and row in plain Integer and checks it lies in 1..79 and 1..22 and is uneaten before converting it to the index subtypes or indexing the grid.
- **range**: The cursor, score and digit values live in ranged subtypes (score at most 1738) so loop-carried updates are bounded by their types without invariants.
- **other**: A move needs a validate pass then an erase pass so that an illegal move leaves the board unchanged and reports a visible rejection.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string building, 'Image of scalars, for loops, while loops, case statements, procedures, functions, Boolean objects, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prints the 79 by 22 text grid, the score and the game-over message after each move.
- **standard input** (allowed): Reads one line per move giving the direction key, with end of input ending the game.

Assessed on 2026-10-15 against page revision 414241 of the [task](https://rosettacode.org/wiki/Greed) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
