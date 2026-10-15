# Letter frequency

**Candidate: proofs likely to discharge automatically.** Every check follows from the array's declared character-subtype index, a guard before each counter increment, and a for loop over the array's own range, with the only loop being a while loop in a procedure. The remaining dependence is on an admitted file-reading library with specified failure outcomes, which Silver lacks today.

Position 1346 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

A 26-element array of bounded counts indexed by a subtype 'A'..'Z' is zeroed by aggregate; a procedure opens the file through an admitted library operation and loops with while not end-of-file, reading one Character at a time. Characters outside A..Z (after folding lower case by a guarded Pos offset) are skipped, and a counter already at its maximum rejects the input; a for loop over the array's own range then prints each nonzero count with Put_Line using 'Image. About 45 lines.

## Proof obligations to watch

- **overflow**: Each counter is a bounded range type and the increment is guarded by an explicit test against the maximum just before it, rejecting the input rather than saturating.
- **termination**: The read loop is a while loop inside a procedure, which gets no termination check, and the end-of-file test comes from the admitted library operation.
- **index**: The array is indexed by a character subtype A to Z after a range guard on each character, so the index check is routine.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, for loops, while loops, procedures, file input, 'Image of scalars, string building, exit status and case statements.

## External effects

- **files** (allowed): Reads the named text file character by character, with a specified outcome when it cannot be opened or read.
- **console output** (allowed): Prints one line per letter with its count.
- **exit status** (allowed): Reports a rejected input (missing file or counter limit exceeded) through a failure status.

Assessed on 2026-10-15 against page revision 415385 of the [task](https://rosettacode.org/wiki/Letter_frequency) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
