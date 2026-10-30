# A+B

**Candidate: proofs likely to discharge automatically.** Every check follows from the validated -1000..1000 ranges and a bounded line buffer, with no loop-carried values, recursion or annotations needed.

Position 1203 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Read one line from standard input into a bounded buffer, then parse two integers separated by spaces with a validating text parser that reports success. If both parse and lie in -1000..1000, convert them to a ranged subtype, add them and print the sum with scalar image; otherwise print a specified rejection message. About 25 lines.

## Proof obligations to watch

- **range**: Parsed values are validated to lie in -1000..1000 before conversion to a ranged subtype, so the sum stays within -2000..2000 and cannot overflow.

## Language surface recorded by this assessment

Integers, ranged subtypes, text parsing, standard input and 'Image of scalars.

## External effects

- **standard input** (allowed): The two integers A and B are read from the input stream.
- **console output** (allowed): The sum, or a message for invalid input, is written to standard output.

Assessed on 2026-10-15 against page revision 412633 of the [task](https://rosettacode.org/wiki/A%2BB) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
