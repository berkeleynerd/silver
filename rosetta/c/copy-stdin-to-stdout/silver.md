# Copy stdin to stdout

**Candidate: proofs likely to discharge automatically.** The only state is one Character with no arithmetic, indexing or accumulator, and a while loop in a procedure gets no termination check, so nothing needs an annotation. The proof burden lies in the admitted stdin and output library contracts, not in the program.

Position 1213 in the [progression](../../progression.md#stage-22), in stage 22, which adds standard input.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The Main procedure holds one Character variable and loops with a while loop until an admitted end-of-input test reports no more input. Each iteration reads one character through an admitted stdin operation and writes it with Put, so the copy is exact and needs no buffer or length limit. Read failures have a specified outcome in the library operation (for example end of input or rejection). About 12 lines.

## Language surface beyond today's Silver

Characters, while loops, standard input and Put without a newline.

## External effects

- **standard input** (allowed): The program reads every character of standard input until end of input.
- **console output** (allowed): Each character read is written unchanged to standard output.

Assessed on 2026-10-15 against page revision 413161 of the [task](https://rosettacode.org/wiki/Copy_stdin_to_stdout) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
