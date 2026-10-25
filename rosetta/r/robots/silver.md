# Robots

**Candidate: proofs plausibly discharge automatically.** Nothing here needs recursion, floating point or annotations, and all coordinates are range-typed grid indices guarded at boundaries, so only the LCG arithmetic and the many loop-carried positions need careful guarding; the task itself is only a game clone with no specified behavior beyond that, so a text turn-based form is faithful.

Position 1244 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program uses a fixed-size 2D array of cell kinds (enumeration) with a bounded robot count, a record for the player position, and a deterministic LCG for placement and teleport. A procedure-based main loop reads one command character per line from stdin, validates it (unknown commands are reported and ignored), applies the move or teleport or wait, moves each robot one step toward the player with collision handling that turns colliding robots into scrap, prints the text board and score, and ends on death, victory of the level (next level adds robots up to a capacity limit) or end of input. About 220 lines.

## Proof obligations to watch

- **overflow**: The deterministic pseudo-random generator uses a small modulus on a ranged state so the multiplication stays within Integer, which needs bounded-operand guards.
- **range**: Player and robot moves are clamped by explicit boundary guards that reject blocked moves with a visible message, so coordinates stay inside the subtype range.
- **index**: Robot chase steps move one cell toward the player within a fixed-size grid, so every index is derived from range-typed coordinates and discharges from types.
- **termination**: The main game loop and the search for an empty cell are while loops inside procedures with bounded attempt counters and end-of-input exit, so no termination check applies.
- **initialization**: The board, robot array and counters are fully initialized by for loops before use, which is routine but touches several nested arrays.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, for loops, while loops, case statements, procedures, functions, string building, 'Image of scalars, Put without a newline and standard input.

## External effects

- **console output** (allowed): The program prints the board, score and game-over messages as text.
- **standard input** (allowed): The player's move commands are read as lines or characters from standard input, with end of input ending the game.

Assessed on 2026-10-15 against page revision 414446 of the [task](https://rosettacode.org/wiki/Robots) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
