# Input/Output for lines of text

**Candidate: proofs likely to discharge automatically.** Every check follows from a ranged count subtype, a fixed-capacity line buffer with library-reported length and status, and a for loop that needs no invariant, so proofs should discharge once Silver gains the stdin line-reading and number-parsing operations.

Position 1208 in the [progression](../../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

An admitted stdin library procedure reads the first line into a bounded buffer, a text-parsing operation converts it to a count in a ranged subtype, and invalid or missing input calls Reject. A for loop over 1 .. Count calls a small Echo procedure that reads one bounded line (with a status check) and writes it through Put_Line, with no loop-carried state besides the loop index. About 35 lines.

## Proof obligations to watch

- **range**: The parsed count is validated into a bounded subtype (for example 0 to 1000) before the for loop, with a visible rejection otherwise, so the loop bounds are type-safe.
- **length**: Each line is read by an admitted library operation into a fixed-capacity buffer with a length and status, and over-long or missing lines (end of input) are rejected visibly so the echo procedure only sees valid lengths.

## Language surface recorded by this assessment

Integers, ranged subtypes, text parsing, string building, for loops, procedures and standard input.

## External effects

- **standard input** (allowed): Reads the count line and then that many text lines from standard input.
- **console output** (allowed): Writes each line to standard output.

Assessed on 2026-10-15 against page revision 415209 of the [task](https://rosettacode.org/wiki/Input/Output_for_lines_of_text) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
