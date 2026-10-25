# Mill game

**Candidate: proofs plausibly discharge automatically.** Every check is an array index or small counter that follows from the 1..24 subtype, validated parsing and guards, and all loops are for loops or while loops in procedures, but the many loop-carried counters and the sizeable game logic make discharge depend on careful program shape.

Position 1250 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The board is a 24-element array of an enumeration (Empty, White, Black) with constant tables for the 16 mills and the neighbours of each point, and the board is printed as text art through a fixed-size string buffer. Procedures run the placing phase, then the moving phase (flying at three pieces), with a mill check after each placement or move prompting a capture that respects mill protection, and each choice is read as a line, parsed into a 1..24 subtype and rejected with a message and re-prompt if invalid. The game ends on fewer than three pieces, no legal move, or end of input (reported as an abandoned game), and the winner is printed. About 260 lines.

## Proof obligations to watch

- **index**: Every board, adjacency and mill table access uses a position subtype 1..24 produced only by validated parsing of the input line, so indexes follow from types and a guard just before use.
- **overflow**: Piece counts and in-hand counters accumulated in loops are declared as small ranged subtypes and incremented only under a guard such as count < 24, since without an invariant only the type range is known after the first iteration.
- **termination**: The input-retry, placing and moving loops are while loops inside procedures, which get no termination check, and helper functions such as mill detection use only for loops.
- **initialization**: The board array is fully initialized by an aggregate and the table constants are static aggregates, so data-flow checks are routine.
- **length**: Input lines are read into a fixed-capacity buffer with an explicit length and parsed with validation, so overlong or non-numeric input leads to a visible re-prompt rather than a failed check.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, string building, text parsing, case statements, for loops, while loops, procedures, functions, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prints the board as text, prompts, mill announcements and the winner.
- **standard input** (allowed): Reads each player's placement, move and capture choices as lines from standard input, with end of input ending the game as a specified outcome.

Assessed on 2026-10-15 against page revision 414341 of the [task](https://rosettacode.org/wiki/Mill_game) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
