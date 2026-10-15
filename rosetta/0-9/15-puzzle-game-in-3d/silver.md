# 15 puzzle game in 3D

**Candidate: proofs plausibly discharge automatically.** The task is a playable text-art cube puzzle needing stdin and console output, and all checks come from ranged types, fixed-size arrays and adjacency guards before each swap, so no annotation is needed, though the rendering and input-validation code needs careful shape.

Position 1245 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Play the 8-puzzle with a 9-element Integer array board (0 is blank), scrambled deterministically by applying a fixed list of legal blank moves from the solved state, and render each tile as a three-line ASCII cube in bounded string buffers. A procedure loop reads a line from standard input, validates it as a tile number 1..8 or a quit command, and swaps that tile with the blank only if it is adjacent according to row and column guards, otherwise printing a specified rejection message. After each move the program checks for the solved state and prints the move count and a victory message, ending at solved, quit or end of input. About 150 lines.

## Proof obligations to watch

- **index**: Neighbor positions of the blank (plus or minus 1 or 3) are indexed only after explicit row and column guards, so each index is provably within 1..9.
- **overflow**: The move counter is a range-bounded Natural that stops counting at a documented cap, and the cap is reported visibly rather than hidden.
- **length**: Cube text-art lines are composed in fixed-capacity buffers whose maximum width is sized for 3 cubes per row, so concatenation lengths are bounded by declarations.
- **initialization**: The board is fully initialized from a constant aggregate, and the scramble is a fixed sequence of legal blank moves, which keeps every state solvable.
- **termination**: The input loop is a while loop inside a procedure and therefore receives no termination check.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions, Put without a newline and standard input.

## External effects

- **console output** (allowed): Each turn prints the board as text-art cubes plus move count and a solved message.
- **standard input** (allowed): The player types a tile number per line, and end of input or a quit command ends the game.

Assessed on 2026-10-15 against page revision 415495 of the [task](https://rosettacode.org/wiki/15_puzzle_game_in_3D) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
