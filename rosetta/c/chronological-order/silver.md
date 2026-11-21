# Chronological order

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed capacities, bounded year digits and guards before each index, with no variant or invariant needed, but the parsing and sort loops need careful shape and a file-line-reading library operation must exist.

Position 1355 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Read up to 32 lines of at most 80 characters from table.txt into a fixed array of records holding the text, its length and a signed integer year key, parsed from the line's end (era word CE or BCE, then digits, negating for BCE) so all three table layouts work with or without a trailing newline. Reject files that fail to open, lines that do not end in a valid era and year, and tables over capacity, then sort the records by key with an insertion sort in a procedure and print each line's slice with Put_Line. About 110 lines.

## Proof obligations to watch

- **index**: Scanning each line backwards from its end to find the era and digits uses loop-carried indices, discharged by a guard just before each access and by the index subtype's range.
- **overflow**: The year is accumulated digit by digit in a loop, discharged by rejecting lines with more than four digits so the accumulator stays within a small declared range.
- **length**: Lines are stored in fixed 80-character buffers with a length field and printed as slices, so over-long lines must be rejected explicitly before storing.
- **index**: The insertion sort over a fixed-capacity table uses while-loop indices and a j-1 step, discharged by a guard on j > 1 and by declared index subtypes, and it lives in a procedure so no termination check arises.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, records, unconstrained arrays, string indexing, text parsing, for loops, while loops, procedures, functions, Boolean objects, file input and exit status.

## External effects

- **files** (allowed): The task requires reading the lines of table.txt, so the program needs an admitted line-reading file operation with a specified failure outcome for a missing file.
- **console output** (allowed): Sorted lines are printed with Put_Line.
- **exit status** (allowed): Rejecting an unreadable file or a malformed or over-capacity table needs a visible failing outcome via Reject.

Assessed on 2026-10-15 against page revision 402153 of the [task](https://rosettacode.org/wiki/Chronological_order) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
