# Number reversal game

**Candidate: proofs likely to discharge automatically.** All checks follow from the array's static bounds, a validated 1..9 subtype for the player's count and a capped counter, and the only unbounded loop sits in a procedure, so no annotation is needed. The one faithfulness cost is a fixed starting permutation instead of a shuffle, which a deterministic generator could replace.

Position 1225 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The board is a constrained array of 9 digits of a 1..9 subtype, initialised from an embedded jumbled permutation that is not sorted, and a function with a for loop checks ascending order. A procedure loops while unsorted: prints the board with Put, reads a line, parses it with validation into 1..9 (invalid text prints a message and re-prompts, end of input ends the game), reverses the first N elements with a for loop over 1..N/2, and increments a capped counter. Finally it prints the board and the score via 'Image. About 80 lines.

## Proof obligations to watch

- **overflow**: The reversal counter is loop-carried, so it is a bounded subtype and the loop stops with a visible message at the cap, letting the increment discharge from the guard.
- **index**: The swap indexes N+1-I are safe because N is parsed into a 1..9 subtype with invalid input re-prompted, and I runs only over 1..N/2.
- **termination**: The play loop is a while loop inside a procedure, which gets no termination check, and the sortedness test is a plain function using a for loop.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, string building, 'Image of scalars, text parsing, standard input, Put without a newline and characters.

## External effects

- **console output** (allowed): Prints the list, the prompt and the final score.
- **standard input** (allowed): Reads the player's reversal count one line at a time, with a specified outcome at end of input.

Assessed on 2026-10-15 against page revision 414362 of the [task](https://rosettacode.org/wiki/Number_reversal_game) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
