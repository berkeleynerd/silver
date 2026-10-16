# Guess the number/With feedback

**Candidate: proofs likely to discharge automatically.** Every check follows from the declared range subtype, a bounded generator state and a validated parse flag tested just before use, with the loop confined to a procedure so no variant is needed. The only new library needs are line input and validated integer parsing, which the Oracle admits as specified operations.

Position 1217 in the [progression](../../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program embeds fixed limits (for example 1 to 100) as a ranged subtype, derives the target from a constant-seeded linear congruential step reduced with mod into that range, then loops in a procedure reading lines from stdin. Each line goes through a validating text-to-integer parse that reports success and a value constrained to the subtype; failed parses or out-of-range values print "inappropriate input", otherwise it prints too high, too low or well guessed, and end of input prints a specified message and stops. About 55 lines.

## Proof obligations to watch

- **overflow**: The deterministic generator step multiplies a state held in a bounded subtype by a constant, which fits in 64 bits by the state's declared range, and the result is reduced with mod into the limits.
- **termination**: The guess loop lives in a procedure so it needs no termination check, and it also ends on end of input with a specified message.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, text parsing, standard input, while loops, Put without a newline and procedures.

## External effects

- **standard input** (allowed): The player's guesses are read as lines from standard input until the guess is correct or input ends.
- **console output** (allowed): Prompts and the feedback messages (too high, too low, invalid input, well guessed) are written to standard output.

Assessed on 2026-10-15 against page revision 415510 of the [task](https://rosettacode.org/wiki/Guess_the_number/With_feedback) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
