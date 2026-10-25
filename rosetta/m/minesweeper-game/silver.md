# Minesweeper game

**Candidate: proofs plausibly discharge automatically.** All array indexes and counters are bounded by ranged subtypes and boundary guards, and recursion and unbounded loops are avoided in functions, so no annotation is needed, but careful shape is required for the flood fill, neighbour counting and input parsing.

Position 1243 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Two 6 by 4 arrays hold mine placement and cell state (hidden, marked, opened), with four mines placed by a bounded deterministic generator in a procedure, and a fixed 24-pass iterative flood fill replaces recursion. A while loop in a procedure reads a line per move, validates command letter and coordinates with explicit guards, and prints the grid as text via bounded string building each turn. The game ends on hitting a mine, on correctly marking all mines, or on end of input. About 210 lines.

## Proof obligations to watch

- **index**: Neighbour access at X+-1 and Y+-1 is discharged by explicit boundary guards just before each indexing, with coordinates typed as ranged subtypes 1..6 and 1..4.
- **overflow**: The neighbour count is a small ranged integer incremented at most eight times inside nested for loops, which could need a guard or a type range wide enough for the loop-carried accumulator.
- **overflow**: The deterministic linear congruential generator keeps its state in a bounded range type with mod, so multiplication cannot overflow Integer.
- **termination**: The recursive flood fill is replaced by a for-loop repeated a fixed 24 passes over the grid, so no variant is needed, and the play loop and mine placement loop are while loops in procedures with no termination check.
- **range**: Move parsing of the command letter and two coordinates validates length and digit characters and range-checks the coordinates before converting, with invalid lines printing a rejection and reprompting.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions, Put without a newline, standard input and conditional expressions.

## External effects

- **console output** (allowed): Prints the mine count, the 6 by 4 grid after each move and the win or loss message.
- **standard input** (allowed): Reads each move line (clear or mark plus coordinates), with end of input a specified outcome that ends the game.

Assessed on 2026-10-15 against page revision 415107 of the [task](https://rosettacode.org/wiki/Minesweeper_game) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
