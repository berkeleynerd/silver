# Last Friday of each month

**Candidate: proofs likely to discharge automatically.** Everything is bounded integer arithmetic over a validated year with a fixed 12-iteration for loop, so all checks follow from types and guards just before use, with only the argument parse loop needing a careful guard.

Position 1118 in the [progression](../../progression.md#stage-18), in stage 18.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

Parse the first argument into a Year subtype (1583..9999) with a digit-by-digit loop that guards the accumulator before each multiply, rejecting non-digit, empty or out-of-range input. For each month in a for loop over 1..12, take the month length from a constant array (February adjusted by a leap-year test using mod), compute the weekday of the last day with a Zeller-style integer formula bounded by the ranged types, subtract the offset back to Friday, and build the "YYYY-MM-DD" line in a fixed 10-character String from digit characters before calling Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The parsing accumulator is loop-carried, so each digit step is preceded by a guard that the value is at most 999, keeping value*10+digit within the Year range.
- **range**: The weekday formula uses mod and division on values bounded by the Year subtype and month table, so intermediate sums stay far below Integer limits and results map into 0..6 and 1..31 subtypes.
- **index**: Writing digits into the 10-character output buffer uses fixed literal positions and digit values proven 0..9 by mod and division of bounded numbers.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, while loops, text parsing, string indexing, string building, 'Image of scalars, procedures and case statements.

## External effects

- **arguments** (allowed): The year is read from the first command-line argument.
- **console output** (allowed): Twelve ISO date lines are written to standard output.
- **exit status** (allowed): Invalid or missing year input is rejected with a specified failure status.

Assessed on 2026-10-15 against page revision 414729 of the [task](https://rosettacode.org/wiki/Last_Friday_of_each_month) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
