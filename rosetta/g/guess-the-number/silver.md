# Guess the number

**Candidate: proofs likely to discharge automatically.** All checks follow from the 1..10 subtype, bounded line buffer and validated parsing, and the while loop is in a procedure so no variant is needed. The only new work is admitted stdin line reading and text-to-integer parsing with specified failure outcomes.

Position 1346 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The secret is a constant in 1..10 produced by a small deterministic generator (or fixed constant) held in a ranged subtype. Main loops while the guess is not equal, using Put for the prompt, a bounded stdin line read, validated text-to-integer parsing, and a visible message for invalid or wrong guesses. End of input leads to an explicit rejection with a nonzero exit status, and the loop exits with "Well guessed!" on a match. About 30 lines.

## Proof obligations to watch

- **termination**: The guessing loop sits in the Main procedure, which gets no termination check, and end of input exits it through an explicit rejection.
- **range**: The parsed guess is validated into a bounded integer before comparison, and unparsable or out-of-range lines print a specified message and ask again rather than being clamped.

## Language surface beyond today's Silver

Integers, ranged subtypes, text parsing, while loops, procedures, Put without a newline, standard input, exit status and string building.

## External effects

- **console output** (allowed): Prints the prompt, the wrong-guess message and "Well guessed!".
- **standard input** (allowed): Reads each guess as a line from standard input until the guess is correct.
- **exit status** (allowed): Input that ends before a correct guess is rejected with a specified nonzero exit status.

Assessed on 2026-10-15 against page revision 415024 of the [task](https://rosettacode.org/wiki/Guess_the_number) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
