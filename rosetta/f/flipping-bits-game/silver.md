# Flipping bits game

**Candidate: proofs plausibly discharge automatically.** Every array index and arithmetic result follows from declared ranges, for-loop index ranges or a validation guard placed just before use, and the game and retry loops live in procedures so no variant is needed. The outlook is plausible rather than likely because of the LCG multiplication and the guarded loop-carried move counter and input handling.

Position 1243 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program uses a fixed 3x3 Boolean array (rows 1..3, columns 'a'..'c'), a target built from a deterministic seeded LCG, and a start made by applying pseudo-random row and column flips to a copy of the target, retrying in a procedure loop until it differs. A play procedure loops while the boards differ, prints the board and move number, reads a line from stdin, validates it as a row digit or column letter, flips that line with a for loop, and counts moves under a bounded limit. When the boards match it prints the final move count, and end of input or the move limit ends the game with a stated message. About 130 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator multiplies a seed subtype bounded to 0..2**31-1 by a small constant and reduces with mod, so the product stays within 64-bit Integer, though the nonlinear product needs the provers to use those bounds.
- **index**: Row and column indexes come from a typed input line, so each is validated by explicit range comparisons before indexing, and invalid or empty lines print a rejection and are skipped.
- **overflow**: The move counter is a loop-carried value, so it is declared with a bounded range and a guard ends the game with a visible message when the limit is reached.
- **termination**: The play loop and the start-generation loop (retry until start differs from target) are while loops in procedures, which get no termination check.
- **initialization**: Boards are fully assigned by for loops over their own index ranges before use, and the equality check is a function with for loops, which terminate on their own.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, 'Image of scalars, text parsing, for loops, while loops, procedures, functions, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prints the target board, the current board, the move count and the final result.
- **standard input** (allowed): Reads each move (a row number or a column letter) typed by the player, one line at a time.

Assessed on 2026-10-15 against page revision 414215 of the [task](https://rosettacode.org/wiki/Flipping_bits_game) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
