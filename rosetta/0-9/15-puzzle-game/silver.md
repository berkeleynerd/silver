# 15 puzzle game

**Candidate: proofs plausibly discharge automatically.** Every array index and arithmetic result follows from subtypes 1..4 and 0..15 and a guard just before each move, and nothing needs a variant because the unbounded loop sits in a procedure; the main care is bounded LCG arithmetic and the move counter.

Position 1242 in the [progression](../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The board is a 4x4 array of tile values 0..15 with the blank tracked as a row/column pair of subtype 1..4. A bounded-range LCG applies a fixed number of legal random moves to scramble from the solved state, then a while loop in a procedure reads a command character from stdin, uses a case statement to attempt Up/Down/Left/Right with an explicit neighbour-bound guard, prints the board with space-padded two-digit tiles, and prints the help text for invalid or impossible commands. A quit command or end of input prints the move count and ends. About 130 lines.

## Proof obligations to watch

- **overflow**: The deterministic shuffle generator is a linear congruential step over a ranged seed subtype, so range guards on the operands keep the product within Integer and the result is reduced with mod into the seed range.
- **index**: The blank position is a loop-carried row/column pair of subtypes 1..4, and each move tests the neighbour bound immediately before changing it, so all board indexes follow from the subtype ranges.
- **overflow**: The move counter is loop-carried, so the game ends with a visible 'move limit reached' outcome at a declared maximum rather than letting the counter wrap or silently stop counting.
- **termination**: The command loop is a while loop with exit, which is only legal because it lives in a procedure (no termination check); all helpers that loop must be procedures or use for loops.
- **other**: Unknown or impossible commands must print the help line and not alter the board, and end of input must exit cleanly, which are explicit guarded outcomes.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, enumerations, arrays, multidimensional arrays, records, case statements, for loops, while loops, procedures, functions, string building, 'Image of scalars, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prints the board after each move, move acknowledgements, help text and the final move count.
- **standard input** (allowed): Reads one command character or line per turn from standard input until quit or end of input.

Assessed on 2026-10-15 against page revision 414920 of the [task](https://rosettacode.org/wiki/15_puzzle_game) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
