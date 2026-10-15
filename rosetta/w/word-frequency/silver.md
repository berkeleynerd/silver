# Word frequency

**Candidate: proofs plausibly discharge automatically.** Every check is an index, length or counter bound that an explicit guard before the operation can discharge, and all open-ended loops sit in procedures, but the many loop-carried indexes and counts in the scan and lookup need careful guarding. The only new needs are bounded file reading and text building, with no annotation required.

Position 1366 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The program reads the path from the first argument, reads each line into a bounded buffer, lowercases ASCII letters and scans for maximal letter runs with a while loop in a procedure. Each word is copied into a fixed-length buffer and looked up linearly in a fixed-capacity table of word and count records, then either incremented or appended, with explicit guards that reject on a full table, an over-long word, an over-long line or a count at its limit. The top 10 are chosen by ten selection passes over the table with for loops and printed with their counts, taking n as the fixed value 10 from the task example. About 130 lines.

## Proof obligations to watch

- **index**: Word-table and line-buffer indexes are loop-carried, so each is guarded just before use (table full or line too long leads to a visible rejection) rather than relying on an invariant.
- **overflow**: Counts live in a declared range and are checked against its upper bound before each increment, rejecting the input instead of saturating.
- **length**: Words longer than the fixed word buffer are rejected with a specified message, not truncated, so the tallies stay faithful.
- **termination**: The line-reading and token-scanning loops are while loops inside procedures, which get no termination check, and the table scans are for loops.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, unconstrained arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions, file input, Put without a newline and exit status.

## External effects

- **files** (allowed): Reads the named text file line by line, with a specified outcome when it cannot be opened or read.
- **arguments** (allowed): Takes the file path from the first command-line argument.
- **console output** (allowed): Prints the ten most common words with their counts, one per line.
- **exit status** (allowed): Reports an unreadable file or an exceeded resource limit through a non-zero status.

Assessed on 2026-10-15 against page revision 415386 of the [task](https://rosettacode.org/wiki/Word_frequency) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
