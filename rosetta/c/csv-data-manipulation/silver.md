# CSV data manipulation

**Candidate: proofs plausibly discharge automatically.** Everything is bounded text scanning and small-integer parsing in procedures, so all checks follow from types and guards without annotations, but Silver needs file I/O, argument access, string building and a fair amount of loop-carried index and sum guarding. The main work is the new library surface, not proof difficulty.

Position 1453 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The program takes the input and output file names from the arguments, then reads the header and up to a fixed maximum number of rows (bounded line length and column count) into a fixed table of bounded strings. For each row a procedure scans fields by position with guards, parses non-negative decimal integers with a digit-by-digit range guard, and sums them in a ranged accumulator, rejecting malformed or oversized input with a message and a nonzero exit status. It appends ",SUM" to the header and "," plus the image of the sum to each row in a bounded buffer, then writes the lines to the output file. About 150 lines.

## Proof obligations to watch

- **overflow**: Each row sum is a loop-carried accumulator, so each field is limited to a declared range (such as 0..999999999), the field count is capped, and a guard before each addition rejects the row if the sum would exceed a declared sum subtype.
- **index**: Field scanning uses a loop-carried position in a while loop, so every character access is guarded by a comparison with the line length just before use.
- **length**: The output line is built in a fixed-capacity buffer, so a guard checks that the line, the comma and the sum digits fit before each append, and an over-long line is rejected with a specified message.
- **range**: Digit-by-digit parsing accumulates a value in a loop, so a guard rejects a field when the accumulated value would pass its declared limit before the next digit is added.
- **termination**: Scanning and the read-until-end loops live in procedures, which get no termination check, and the row count is bounded by a fixed table size.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, records, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions, file input, file output, further arguments and exit status.

## External effects

- **files** (allowed): The task reads a named CSV file and writes the modified CSV to another file, with specified outcomes for a missing, unreadable or unwritable file.
- **arguments** (allowed): The input and output file names come from command-line arguments.
- **exit status** (allowed): Rejected input or I/O failure must be reported with a nonzero exit status.
- **console output** (allowed): Rejection reasons are printed to the console.

Assessed on 2026-10-15 against page revision 414643 of the [task](https://rosettacode.org/wiki/CSV_data_manipulation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
