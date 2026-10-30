# Ordered words

**Candidate: proofs plausibly discharge automatically.** Every index, length and counter is bounded by declared subtypes and explicit guards before use, with the only loop being a procedure-level while that needs no termination proof, so no annotation is needed but the bounded-table and file-input library behavior must be carefully shaped.

Position 1320 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A procedure reads unixdict.txt through an admitted file-input library operation into a fixed 64-character line buffer with a length, and a for loop over 1 .. Length-1 (guarded by Length > 1) tests that each character is not greater than the next. The ordered words are kept in a fixed array of 256 buffers with a count and the current maximum length: a longer ordered word resets the count to 0, an equal-length one is appended only if count is below capacity, and over-long lines or table overflow call Reject. Finally a for loop over 1 .. Count prints each stored word with Put_Line, and a missing file also ends in Reject. About 70 lines.

## Proof obligations to watch

- **index**: The stored-word count and the per-word length are bounded by declared subtypes and each append is guarded by a capacity test just before it, so no index check depends on a loop invariant.
- **length**: Lines longer than the fixed word buffer are rejected with a visible outcome rather than truncated, so the length check follows from the guard before copying.
- **overflow**: The running maximum length and word count are subtypes capped by the buffer and table capacities, so increments are guarded by a capacity test and discharge from types.
- **initialization**: Word buffers and the table are fully initialized by aggregates and only the first Count entries are read, so the flow analysis is routine but must be shaped carefully.
- **termination**: The line-reading while loop sits in a procedure, which gets no termination check, and the ordered test uses a for loop.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, string building, for loops, while loops, procedures, Put without a newline and file input.

## External effects

- **files** (allowed): The task requires reading unixdict.txt line by line, with a specified outcome when the file is missing or unreadable.
- **console output** (allowed): The ordered words of maximal length are displayed one per line.

Assessed on 2026-10-15 against page revision 413822 of the [task](https://rosettacode.org/wiki/Ordered_words) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
