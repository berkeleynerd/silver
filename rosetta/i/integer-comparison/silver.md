# Integer comparison

**Candidate: proofs likely to discharge automatically.** After validated parsing, the program only compares two Integer values, which raises no run-time checks, so every obligation follows from the parse operation's contract and explicit rejection of invalid input.

Position 1434 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

Main reads two command-line arguments, parses each into an Integer with validation, and rejects the input with a specified message if either argument is missing or not a valid in-range integer. It then tests A < B, A = B and A > B in three separate if statements and prints the matching message for each case. About 30 lines.

## Proof obligations to watch

- **overflow**: Converting argument text to Integer must reject out-of-range digit strings, which a validated parse operation (or a guard before each multiply-add) discharges, after which the three comparisons carry no checks at all.

## Language surface recorded by this assessment

Integers, text parsing and further arguments.

## External effects

- **arguments** (allowed): The two integers are read from the first two command-line arguments.
- **console output** (allowed): The comparison messages, or a rejection message, are printed with Put_Line.

Assessed on 2026-10-15 against page revision 414785 of the [task](https://rosettacode.org/wiki/Integer_comparison) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
