# Spoof game

**Candidate: proofs likely to discharge automatically.** Every check follows from small ranged subtypes, a bounded generator and parse-then-validate guards just before use, and the round count is fixed so no loop needs an invariant or variant. The task is under-specified, so a simple interactive round-based game meets it without recursion, heap or annotations.

Position 1219 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

The program plays a fixed number of rounds in a for loop inside a procedure, keeping coin counts and guesses in small ranged subtypes and drawing the computer's choices from a bounded linear congruential generator seeded by a constant. Each round reads two lines from standard input, parses and validates them against their ranges (rejecting end of input or bad values with a specified message), then compares the guesses to the coin total with if/elsif to print draw, computer wins, player wins or no winner. About 95 lines.

## Proof obligations to watch

- **overflow**: The deterministic generator multiplies a state bounded to a 31-bit subtype by a constant, which fits in 64 bits by the declared range, though the nonlinear product needs the provers to cope.
- **range**: Parsed player input is checked against 0..3 for coins and 0..6 for guesses before conversion to the ranged subtypes, with a Reject outcome on invalid or missing input.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, procedures, Put without a newline, standard input, text parsing and 'Image of scalars.

## External effects

- **console output** (allowed): Prompts, the computer's coin count and guess, and each round's result are printed.
- **standard input** (allowed): The player's coin count and guess are read as lines of text for each round.

Assessed on 2026-10-15 against page revision 414514 of the [task](https://rosettacode.org/wiki/Spoof_game) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
