# Run-length encoding

**Candidate: proofs plausibly discharge automatically.** Encode and decode are iterative loops over a bounded input in a procedure, with each loop-carried index and count protected by guards that reject on overflow, so no annotation is needed but several guards must be placed carefully.

Position 553 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The program embeds the example input as a String constant and, in the main procedure, encodes it with a while loop into a fixed-capacity Character buffer plus a length, writing each run count as decimal digits via integer division and mod, then decodes that buffer back into a second bounded buffer. Every write is guarded by a capacity test that prints a visible rejection message on overflow, the decode accumulator is guarded against exceeding the buffer capacity, and the encoded and decoded text are printed with Put_Line and checked for equality with the input. About 95 lines.

## Proof obligations to watch

- **index**: Run-end and output positions are loop-carried, so each buffer write and input read is preceded by an explicit bound guard, with a visible rejection when capacity is exceeded.
- **overflow**: The decode count accumulator (count*10 + digit) is guarded to stay below the buffer capacity before each multiplication, otherwise decoding is rejected visibly.
- **termination**: All loops live in a procedure, which gets no termination check, so while loops need no variant.
- **range**: Digit extraction with division and mod and conversion to Character via 'Val needs the count bounded by a range type or guard so the digit lies in 0..9.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, while loops, for loops and procedures.

## External effects

- **console output** (allowed): Prints the encoded string and the decoded string with Put_Line.

Assessed on 2026-10-15 against page revision 414664 of the [task](https://rosettacode.org/wiki/Run-length_encoding) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
