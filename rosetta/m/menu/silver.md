# Menu

**Candidate: proofs likely to discharge automatically.** Every check follows from the constant item count, a range guard on the parsed number just before indexing, and fixed-capacity buffers, and the retry loop sits in a procedure where no termination proof is needed. Validated parsing and bounded line reading are admitted library operations with specified failure outcomes.

Position 1212 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The four phrases are held as constant records of a fixed-capacity character buffer plus a length in an array, and a procedure Choose with an out result record handles the empty-list case by returning a zero-length string. A while loop in the procedure prints the whole menu with a for loop, prompts, reads a line with a bounded stdin operation, parses it with a validating text-to-integer operation, and repeats the whole menu on non-integer or out-of-range input. A guard checks 1 <= n <= Count before indexing, end of input ends the loop with a specified rejection, and the main program prints the chosen string. About 75 lines.

## Proof obligations to watch

- **termination**: The retry loop is a while loop inside a procedure, which gets no termination check, and it exits on a valid choice or on end of input, which is reported as a visible rejection.
- **index**: The parsed number is used to index the item array only after an explicit test that it lies between 1 and the item count, so the check discharges from the guard just before use.
- **length**: Each item is stored in a fixed-capacity buffer with its own length, so printing and concatenation stay within declared bounds.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prints the numbered menu, the prompt and the chosen string.
- **standard input** (allowed): Reads the user's selection line, with a specified outcome at end of input.

Assessed on 2026-10-15 against page revision 413305 of the [task](https://rosettacode.org/wiki/Menu) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
