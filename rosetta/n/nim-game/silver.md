# Nim game

**Candidate: proofs plausibly discharge automatically.** Every check is bounded by the 0..12 subtype or a guard just before use, and the loops sit in procedures, but the loop-carried token count and the line parsing need careful guards, so discharge depends on program shape.

Position 1228 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program keeps the remaining tokens in a subtype 0..12 and loops in the main procedure while tokens remain: it prompts, reads a line from standard input, parses it into 1..3 and re-prompts with an 'Invalid input.' message on bad or too-large values. The computer then takes 4 minus the human's take after a guard that enough tokens remain, prints both moves using integer images, and finally prints that the computer won, rejecting at end of input. About 70 lines.

## Proof obligations to watch

- **range**: The token count is a loop-carried subtype 0..12, so every subtraction is guarded by a take-not-more-than-remaining test and the computer's reply is checked against the remaining count, with an unreachable failure branch that visibly rejects.
- **termination**: The game loop and the re-prompt loop are while loops inside the main procedure or procedures, which get no termination check, and end of input ends the program with a rejection rather than looping.
- **length**: Each input line is read into a bounded buffer and over-long or non-numeric lines are reported as invalid input before parsing.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, while loops, procedures, 'Image of scalars, text parsing, standard input, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the token count, prompts, moves, invalid-input messages and the final result.
- **standard input** (allowed): Reads the human player's token choice one line at a time, with a specified outcome at end of input.

Assessed on 2026-10-15 against page revision 412268 of the [task](https://rosettacode.org/wiki/Nim_game) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
