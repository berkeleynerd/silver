# General FizzBuzz

**Candidate: proofs plausibly discharge automatically.** Everything is bounded by validated ranges and fixed buffers, and the work is simple loops in procedures, but the text parsing of user input with loop-carried accumulators and buffer indexing requires careful guards, hence plausible rather than likely.

Position 1228 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Store three records of factor (Positive range) plus a bounded word buffer with length, read from stdin lines via a validating parse procedure that rejects malformed input, then order the three entries by factor with a few compare-and-swap steps. A for loop from 1 to Max checks each factor with mod, appends matching words into a bounded line buffer (or prints with Put), and prints the number image when none matched. About 110 lines.

## Proof obligations to watch

- **overflow**: Digit-by-digit parsing of the max and factors accumulates a value in a loop, so each step is guarded to stop at a documented limit (e.g. 1_000_000) and reject larger input.
- **index**: Splitting a line into number and word and copying words into fixed buffers needs explicit length and position guards before each indexing, which discharge as guards precede the access.
- **division**: The mod by each factor is safe because parsing rejects factors below 1 so the factor type excludes zero.
- **length**: Words are stored in fixed-capacity buffers with a length field and over-long or empty words are rejected, so slices stay in range.
- **termination**: All loops live in procedures (the output and parsing loops are for loops or bounded while loops) so no termination check arises.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, Put without a newline and standard input.

## External effects

- **standard input** (allowed): The task requires reading the maximum number and three factor-and-word lines from standard input.
- **console output** (allowed): Each number or concatenated word string is printed on its own line.

Assessed on 2026-10-15 against page revision 414232 of the [task](https://rosettacode.org/wiki/General_FizzBuzz) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
