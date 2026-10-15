# Input loop

**Candidate: proofs likely to discharge automatically.** Every check follows from the buffer's declared bounds and the read operation's verified postcondition, and the unbounded stream is handled by a procedure-level while loop that needs no variant.

Position 1214 in the [progression](../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Main declares a fixed-capacity String buffer, a Natural length and a Boolean end-of-input flag, then runs a while loop in the procedure that calls an admitted Silver_IO line-read operation (returning the length and the end flag) and echoes Line(1..Length) with Put_Line until end of input. The read operation's contract guarantees Length is within the buffer bounds and defines what happens to over-long lines, so the only loop-carried values are bounded by their types. About 20 lines.

## Proof obligations to watch

- **length**: An input line longer than the fixed buffer must have a specified visible outcome (for example splitting it across reads or rejecting it), which the admitted read operation's contract provides so the slice Line(1..Length) is always in range.
- **termination**: The while loop sits in the Main procedure, which gets no termination check, so no variant is needed even though the input length is unbounded.

## Language surface beyond today's Silver

Standard input, while loops, string building, string indexing, integers, Boolean objects and ranged subtypes.

## External effects

- **standard input** (allowed): The program reads standard input line by line until end of data.
- **console output** (allowed): Each line read is written to standard output.

Assessed on 2026-10-15 against page revision 412849 of the [task](https://rosettacode.org/wiki/Input_loop) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
