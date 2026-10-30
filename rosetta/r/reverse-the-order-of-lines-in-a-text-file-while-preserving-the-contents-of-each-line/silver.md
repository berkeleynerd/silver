# Reverse the order of lines in a text file while preserving the contents of each line

**Candidate: proofs likely to discharge automatically.** All checks follow from fixed array capacities, bounded counters and explicit capacity guards, and the reverse output is a plain for loop. The one new dependency is an admitted bounded line-reading library operation with specified failure outcomes.

Position 1315 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program takes the file name from the first argument, then a procedure reads it line by line through an admitted file-input operation into a fixed array of 100 records, each holding a 200-character buffer and a length. A line or count over capacity, or a missing or unreadable file, is rejected with a specified message. A for loop in reverse order over the stored line count prints each line's slice with Put_Line. About 60 lines.

## Proof obligations to watch

- **index**: Line count and line length are checked against the fixed capacities before every store, and a violation calls Reject, so each buffer index is guarded just before use.
- **range**: The reading loop's carried line count is held in a subtype bounded by the capacity, with the guard before each increment keeping it in range.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, unconstrained arrays, string indexing, string building, for loops, while loops, procedures and file input.

## External effects

- **files** (allowed): Reads the named input file line by line.
- **arguments** (allowed): The input file name comes from the first command-line argument.
- **console output** (allowed): Prints the lines in reverse order with Put_Line.
- **exit status** (allowed): A missing, unreadable or over-capacity file is rejected with a nonzero status.

Assessed on 2026-10-15 against page revision 406562 of the [task](https://rosettacode.org/wiki/Reverse_the_order_of_lines_in_a_text_file_while_preserving_the_contents_of_each_line) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
