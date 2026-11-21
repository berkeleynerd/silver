# Execute Computer/Zero

**Candidate: proofs likely to discharge automatically.** Every check is bounded by the 8-bit modular type and 0..31 index subtype, and the only loop is a while loop in a procedure with a step cap, so no annotations are needed.

Position 1460 in the [progression](../../../progression.md#stage-27), in stage 27.

## Approach

Memory is a 32-element array of a modular byte type, and the sample programs are embedded as array aggregates with opcode*32+operand encoded as literals. A Run procedure loops with a bounded step counter, decoding opcode with / 32 and operand with mod 32 into a case statement over 0..7, with STP exiting and returning the accumulator, and a driver procedure runs each program and prints the name and value with Put_Line. Self-modifying code works naturally because STA writes into the same array that is fetched from. About 110 lines.

## Proof obligations to watch

- **index**: Memory is an array of 32 bytes indexed by a subtype 0..31 whose operand and pc come from div and mod 32 of a byte, so every index check follows from the types.
- **overflow**: Accumulator add and subtract use an 8-bit modular type, so wraparound is defined and no overflow check can fail.
- **termination**: The fetch loop is a while loop inside a procedure, which gets no termination check, and a step cap makes it bounded with a specified outcome of reporting a step-limit rejection.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, enumerations, arrays, records, string building, 'Image of scalars, for loops, while loops, case statements, procedures, functions and packages.

## External effects

- **console output** (allowed): Prints each sample program's name and final accumulator value.

Assessed on 2026-10-15 against page revision 414649 of the [task](https://rosettacode.org/wiki/Execute_Computer/Zero) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
