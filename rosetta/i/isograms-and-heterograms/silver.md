# Isograms and heterograms

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared subtypes, fixed capacities with explicit reject guards, and loops in procedures, but it needs a file-reading library operation, string ordering and careful guard placement in the sort and the counting loops.

Position 1485 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Each line of unixdict.txt is read into a bounded buffer with a length (rejecting over-long lines), lowercased, and its characters tallied in a 256-entry count array; a for loop then checks that all nonzero counts are equal, giving n. Words with n>1, or n=1 and length>10, go into two fixed-capacity result tables (records of buffer, length, n), kept ordered by an insertion sort in a procedure comparing n, then length descending, then lexicographic ascending, and the tables are printed with scalar images. About 130 lines.

## Proof obligations to watch

- **index**: The count table is indexed by Character'Pos over a 0..255 subtype and result-array indexes are guarded by a capacity check before each insertion, so both discharge from types and guards.
- **overflow**: Per-character counts are bounded by the maximum word length, which is a declared subtype range, so increments cannot overflow.
- **length**: Words longer than the fixed buffer, or more results than the table holds, are rejected with a visible outcome rather than truncated, so buffer lengths are guarded before use.
- **termination**: Line reading and insertion-sort shifting use while loops, but they live in procedures, which get no termination check.
- **initialization**: The count table and result arrays are fully initialized by aggregates or reset loops per word, so flow analysis is routine.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, string ordering, 'Image of scalars, for loops, while loops, procedures, functions, file input, Put without a newline, exit status and conditional expressions.

## External effects

- **files** (allowed): Reads the word list unixdict.txt line by line, with a specified outcome if it is missing or unreadable.
- **console output** (allowed): Prints the two sorted result lists to standard output.
- **exit status** (allowed): Reports a rejected file or an over-limit word or result count through a failure exit status.

Assessed on 2026-10-15 against page revision 414272 of the [task](https://rosettacode.org/wiki/Isograms_and_heterograms) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
