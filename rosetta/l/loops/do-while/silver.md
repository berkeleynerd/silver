# Loops/Do-while

**Candidate: proofs likely to discharge automatically.** The bounded index avoids a loop-carried accumulator, and mod 6 has a nonzero literal divisor. The plan still needs conditional loop exit in addition to integer remainder; a counted-loop bound alone would not demonstrate the requested post-body condition.

Position 171 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

Main declares a subtype Counter of Integer range 1 .. 6 and runs a for loop over Counter, giving the successive values obtained by starting at zero and adding one before each body. Each iteration prints Integer'Image (Value) with Put_Line and then executes exit when Value mod 6 = 0. The bounded counted loop supplies the increment and conditional exit supplies the post-body termination test, so the body executes at least once and prints 1 through 6. Conditional loop exit is future while-loops surface even inside a for loop. About 12 lines.

## Language surface recorded by this assessment

Integers, integer division, for loops, 'Image of scalars, ranged subtypes and while loops.

## External effects

- **console output** (allowed): Prints each loop value on its own line through Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 412892 of the [task](https://rosettacode.org/wiki/Loops/Do-while) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../../assessment-division-20261025.md).
