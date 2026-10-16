# FASTA format

**Candidate: proofs plausibly discharge automatically.** Streaming output through unterminated Put means only a bounded line buffer is needed, and every index and length check is guarded by the returned line length, with no loop-carried arithmetic. It needs new stdin-line and Put library operations but no annotations, so proofs should discharge with careful shape around buffer bounds.

Position 1351 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

A single procedure streams stdin with a while loop until end of input, holding only one fixed-capacity line buffer and its length, so the whole file is never held in memory. A line starting with '>' ends the previous record with a newline and prints the name followed by ': ' using Put, while any other line is printed immediately with Put and so concatenated; the first line not starting with '>' or any line over capacity triggers Reject. About 55 lines.

## Proof obligations to watch

- **length**: Each line is read into a fixed-size buffer with a returned length, and a line exceeding the documented capacity is rejected visibly rather than truncated.
- **index**: Checking the first character of a line requires a guard that the returned length is at least 1, and slices are bounded by that length.
- **termination**: The read-until-end-of-input loop lives in a procedure, which gets no termination check.
- **initialization**: The in-record state flag and buffer must be initialized before the first line, which declarations can ensure.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, string indexing, while loops, for loops, procedures, Put without a newline, standard input and exit status.

## External effects

- **standard input** (allowed): The FASTA records are read line by line from standard input.
- **console output** (allowed): Each record is printed as name, colon, space and the concatenated sequence.
- **exit status** (allowed): Malformed input (missing leading '>' or an over-long line) is rejected with a specified failure status.

Assessed on 2026-10-15 against page revision 412786 of the [task](https://rosettacode.org/wiki/FASTA_format) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
