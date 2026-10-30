# Subleq

**Candidate: proofs likely to discharge automatically.** Every array index, character conversion and subtraction is protected by a guard just before use with a defined halt outcome, and the loop lives in a procedure so no variant is needed, so the proofs should discharge without annotations.

Position 1216 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program holds memory as a constant-size array of a 32-bit ranged Word type initialized by an aggregate with the Hello world words and others => 0, then runs a procedure with a while loop over the program counter and a step counter. Each iteration guards that PC+2 is inside memory, then branches on A = -1 (read a character), B = -1 (write a character, guarded to 0..255) or subtract-and-branch (guarding A and B as addresses, computing the difference in Long_Long_Integer and rejecting results outside Word); negative PC halts normally, and every guard failure prints a specified fault or step-limit message and stops. About 95 lines.

## Proof obligations to watch

- **overflow**: The subtraction of two 32-bit words is computed in 64-bit Long_Long_Integer and range-tested before storing, so the check follows from types and a guard just before the store.
- **index**: Every memory access uses an address first tested to lie in 0 .. Size-1 (and PC+2 in range), with out-of-range addresses halting the machine with a visible fault message.
- **range**: Character'Val on a memory word is guarded by a 0 .. 255 test, with out-of-range output words halting with a fault message.
- **termination**: The interpreter loop is a while loop inside a procedure, which gets no termination check, and a documented step limit also stops runaway programs with a visible message.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, Put without a newline and standard input.

## External effects

- **console output** (allowed): Emulated output instructions write characters to standard output, plus a message when the machine stops abnormally.
- **standard input** (allowed): The emulated input instruction (A = -1) reads one character from standard input, with end of input stored as -1.

Assessed on 2026-10-15 against page revision 413067 of the [task](https://rosettacode.org/wiki/Subleq) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
