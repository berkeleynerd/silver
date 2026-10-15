# Compile-time calculation

**Candidate: proofs likely to discharge automatically.** The only arithmetic is a static expression that the compiler folds to 3628800, which fits in Integer, so no run-time check remains apart from the routine 'Image and output call. The proof should discharge trivially once integer constants and 'Image are admitted.

Position 35 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Main declares a static Integer constant Factorial_10 equal to 10*9*8*7*6*5*4*3*2*1, which Ada evaluates exactly at compile time as a static expression. Main then prints it with Silver_IO.Put_Line(Integer'Image(Factorial_10)). It has no loops, guards or input. About 8 lines.

## Language surface beyond today's Silver

Integers and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the precomputed value of 10! with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 403674 of the [task](https://rosettacode.org/wiki/Compile-time_calculation) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
