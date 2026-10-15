# Longest string challenge

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded subtypes and guards placed before table appends and slice copies, with out-of-limit input given a specified rejection; the only unknowns are stdin line-reading operations and slice-copy proof shape.

Position 1354 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

A fixed table of up to 256 stored lines (each a 1..255 character buffer plus a length) holds the current longest lines, with a count and best length. A while loop in the Main procedure reads each line from stdin until end of file, rejects lines over 255 characters, then clears the table if the line is longer, appends it if equal and the table is not full (else rejects), and ignores it if shorter; at end of file it prints the stored lines. The restrictions on comparison and arithmetic are treated as the challenge's own puzzle, and the program uses ordinary integer comparison and a bounded table instead of exceptions. About 70 lines.

## Proof obligations to watch

- **index**: Appending a tied line indexes the fixed table only after an explicit Count < Max_Ties guard, and over-limit input takes the Reject path.
- **length**: Copying a line into a table slot slices by its length, which is a subtype bounded by the maximum line length and checked on read.
- **overflow**: The loop-carried tie count and best length are subtypes bounded by their maxima, with the increment guarded just before use.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, records, string indexing, string building, for loops, while loops, procedures, standard input and exit status.

## External effects

- **standard input** (allowed): Reads lines until end of file.
- **console output** (allowed): Prints each longest line.
- **exit status** (allowed): Over-limit input (line too long or too many ties) is rejected with a specified failure status.

Assessed on 2026-10-15 against page revision 413766 of the [task](https://rosettacode.org/wiki/Longest_string_challenge) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
