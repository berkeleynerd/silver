# Soloway's recurring rainfall

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged value types, guarded accumulation limits and a count guard before division, with no annotation needed. The main work is careful program shape for the loop-carried sum, count and text buffer, so discharge is plausible rather than routine.

Position 1226 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

A Main procedure loops with a while loop, reading one line at a time from stdin into a bounded string and parsing it into a ranged value, printing a message and skipping the line when it is not a valid integer. It stops at 99999 or end of input, otherwise it adds to a wide Long_Long_Integer sum and a bounded count after guarding both against fixed limits. The average is printed as a decimal with a fixed number of fractional digits, computed by integer division and mod, rather than with floating point. About 90 lines.

## Proof obligations to watch

- **overflow**: The sum and count are loop-carried, so each addition is preceded by a guard on the current sum and count against documented limits, and reaching a limit stops reading with a visible message.
- **range**: Parsed values are validated into a subtype of about plus or minus 99999 before use, and invalid lines are skipped with a printed message.
- **division**: The division by the count is guarded by a check that at least one value was read, otherwise a 'no values' message is printed.
- **index**: Building the decimal text of the average in a bounded buffer needs a position guard before each character is written, since the position is loop-carried.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, text parsing, 'Image of scalars, string building, string indexing, characters, while loops, procedures, standard input and Put without a newline.

## External effects

- **standard input** (allowed): Reads integer values line by line from standard input until 99999 or end of input.
- **console output** (allowed): Prints a message for each rejected line and the final average.

Assessed on 2026-10-15 against page revision 413918 of the [task](https://rosettacode.org/wiki/Soloway's_recurring_rainfall) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
