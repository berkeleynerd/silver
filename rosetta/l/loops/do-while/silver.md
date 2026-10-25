# Loops/Do-while

**Candidate: proofs likely to discharge automatically.** The for-loop index is bounded by its declared range, so the only checks are Value mod 6 (divisor is a nonzero literal) and the 'Image output, all of which follow from types. A while-style loop with an unbounded Value + 1 would need an overflow guard, which the bounded for loop avoids.

Position 98 in the [progression](../../../progression.md#stage-6), in stage 6.

## Approach

Main declares a subtype Counter of Integer range 1 .. 6 and runs a for loop over Counter, which executes the body at least once. Each iteration prints Integer'Image (Value) with Put_Line and ends with exit when Value mod 6 = 0, so the program prints 1 through 6. The loop index comes from the for-loop range, so no loop-carried accumulator or overflow check exists. About 12 lines.

## Language surface recorded by this assessment

Integers, integer division, for loops, 'Image of scalars and ranged subtypes.

## External effects

- **console output** (allowed): Prints each loop value on its own line through Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412892 of the [task](https://rosettacode.org/wiki/Loops/Do-while) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
