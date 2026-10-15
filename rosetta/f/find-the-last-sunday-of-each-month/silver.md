# Find the last Sunday of each month

**Candidate: proofs likely to discharge automatically.** All arithmetic is on a validated bounded year and month index inside a for loop with no loop-carried state, so every check follows from types and the entry guard.

Position 1125 in the [progression](../../progression.md#stage-19), in stage 19.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

The program parses a four-digit year from the first argument, rejecting anything else, then loops over months 1..12 with a constant days-in-month array adjusted for leap years. For each month it computes the weekday of the last day with a closed-form (Sakamoto-style) formula using mod, steps back to Sunday, and builds the 10-character date in a fixed String from zero-padded digit characters before calling Put_Line. About 60 lines.

## Proof obligations to watch

- **range**: The parsed year is validated as exactly four digits and range-checked to 1583..9999 before any arithmetic, so the year subtype conversion and day-of-week arithmetic stay in bounds.
- **overflow**: The weekday formula uses mod and division on a year bounded to 9999 in a wide Integer, so intermediate sums stay far below overflow.
- **index**: Each digit is read at a fixed index of a String guarded by a 'Length = 4 test, and the month loop indexes the days-in-month array over its own range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, text parsing, for loops, procedures and Boolean objects.

## External effects

- **arguments** (allowed): The year is read from the first command-line argument.
- **console output** (allowed): Twelve date lines are written with Put_Line.
- **exit status** (allowed): A missing or invalid year is rejected with a specified nonzero status.

Assessed on 2026-10-15 against page revision 414756 of the [task](https://rosettacode.org/wiki/Find_the_last_Sunday_of_each_month) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
