# Loops/While

**Candidate: proofs likely to discharge automatically.** Every check follows from the Integer type and the constant divisor 2, which cannot be zero or overflow. The while loop sits in a procedure, so no termination check or variant is needed.

Position 183 in the [progression](../../../progression.md#stage-8), in stage 8.

## Approach

A Main procedure declares an Integer variable I initialised to 1024 and runs a while loop (legal because Main is a procedure) guarded by I > 0. Each iteration prints Integer'Image (I) with Silver_IO.Put_Line and sets I := I / 2. Since I is an Integer, the constant divisor 2 and the loop guard keep every check trivial. About 12 lines.

## Language surface recorded by this assessment

Integers, integer division, while loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each value of the halving sequence, one per line.

Assessed on 2026-10-15 against page revision 412899 of the [task](https://rosettacode.org/wiki/Loops/While) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
