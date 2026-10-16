# Kernighans large earthquake problem

**Candidate: proofs plausibly discharge automatically.** Everything reduces to bounded string scanning, integer-tenths parsing and line output in procedures, so no annotation should be needed, but the file-reading library operation and validated number parsing must exist in Silver and the digit accumulation needs careful guards.

Position 1332 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program reads data.txt through an admitted line-reading file operation into a fixed-capacity line buffer with explicit length, trims blanks, skips empty lines, and finds the last space with a bounded scan. It parses the final field as a decimal number into integer tenths (digits, optional point, one fractional digit, with validation), compares it to 60 with 6.0 exclusive, and prints the original line when greater, reporting a specified message for malformed lines or overlong lines. About 80 lines.

## Proof obligations to watch

- **index**: Scanning each bounded line buffer for the last space and slicing out the magnitude field is discharged by a for loop over the buffer's own range and guards on the found position before each slice.
- **overflow**: Parsing the magnitude as fixed-point integer tenths accumulates digits in a loop, so the accumulator needs a guard on digit count or a saturating bound before each multiply-add to discharge without an invariant.
- **length**: Lines longer than the fixed buffer capacity must have a specified outcome (rejection or truncation reported visibly), and echoing the trimmed line needs a bounded length copy.
- **termination**: The read-until-end-of-file loop lives in a procedure, which gets no termination check, so it is routine as long as the loop is not inside a function.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, text parsing, for loops, while loops, procedures, Boolean objects, file input and standard input.

## External effects

- **console output** (allowed): Prints each qualifying event line to standard output.
- **files** (allowed): The task reads a named data file (data.txt) of event lines, so the file read must be an admitted library operation with specified failure outcomes.

Assessed on 2026-10-15 against page revision 415429 of the [task](https://rosettacode.org/wiki/Kernighans_large_earthquake_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
