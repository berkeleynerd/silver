# Write float arrays to a text file

**Candidate: proofs plausibly discharge automatically.** Everything is a fixed-size loop over constrained arrays, so index and initialization checks are routine, and the only non-routine parts are float range guards for Sqrt and the specified contracts of admitted float-formatting and file-writing operations, none of which need an annotation.

Position 1430 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

The program holds x and y as constrained four-element arrays of a non-negative float subtype, with x embedded as an aggregate and y filled by a for loop that calls an elementary-function Sqrt after the range is established by the subtype. A procedure opens the file named by the first argument (rejecting a missing or unusable name), then for each index formats x with 3 digits and y with 5 through an admitted float-image operation into a bounded buffer and writes the line through an admitted file-output operation. All control flow is for loops over the array's own range inside procedures, with explicit visible outcomes for open or write failure. About 45 lines.

## Proof obligations to watch

- **floating point**: Sqrt needs a non-negative operand and results must stay finite, which the program discharges by declaring a constrained non-negative float subtype for x (1.0e11 is far below the overflow bound) and guarding before each call.
- **range**: Precision values 3 and 5 must be valid digit counts for the admitted float formatter, which constrained integer subtypes for the precisions discharge.
- **length**: Each formatted line must fit a fixed-size bounded buffer, which is sized for the two formatted columns (about 40 characters) and checked against the formatter's specified maximum length.
- **other**: Scientific notation such as 1e+011 for large values depends on a specified admitted float-to-text operation with precision and exponent behavior, which Silver does not yet provide.

## Language surface beyond today's Silver

Floating point, floating-point images, arrays, for loops, procedures, ranged subtypes, string building, file output, Put without a newline and integers.

## External effects

- **files** (allowed): The program creates and writes the two-column text file, and a failure to create or write it needs a specified outcome.
- **arguments** (allowed): The output file name is taken from the first command-line argument, with Input_Is_Valid and Reject for a missing or unusable name.
- **console output** (allowed): A short status or rejection message is printed with Put_Line.

Assessed on 2026-10-15 against page revision 414590 of the [task](https://rosettacode.org/wiki/Write_float_arrays_to_a_text_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
