# Prime words

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by Character'Pos at most 255 and the loops are for loops or sit in procedures, so every check follows from types and bounds; the only new need is an admitted line-reading file operation.

Position 1324 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A function Is_Prime on a Natural character code (at most 255) tests divisors with a for loop from 2 to 15 and mod. A procedure opens unixdict.txt through an admitted file-input operation, reads each line into a fixed 64-character buffer with a length, and for each non-empty line loops over its characters with a for loop, then prints the line via Put_Line if every character code is prime. A missing file or over-long line gets a specified rejection outcome. About 55 lines.

## Proof obligations to watch

- **index**: Line buffer indexing is guarded by a length counter that stays within the buffer capacity, with over-long lines rejected visibly.
- **termination**: The file-reading while loop lives in a procedure, which gets no termination check, and the per-character primality test uses a for loop.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, string indexing, string building, for loops, while loops, procedures, functions and file input.

## External effects

- **files** (allowed): Reads unixdict.txt line by line, with a specified outcome if it is missing or unreadable.
- **console output** (allowed): Prints each prime word on its own line.

Assessed on 2026-10-15 against page revision 400976 of the [task](https://rosettacode.org/wiki/Prime_words) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
