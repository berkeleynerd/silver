# Sum digits of an integer

**Candidate: proofs plausibly discharge automatically.** Every check follows from subtype ranges for Base and a guard before the accumulator addition, and the loop sits in a procedure so no variant is needed; the only care needed is the loop-carried Sum overflow guard.

Position 224 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A procedure Sum_Of_Digits takes a Natural value N and a Base of subtype 2..36 and returns the digit sum through an out parameter, using a while loop that adds Val mod Base to Sum and divides Val by Base. Sum is a ranged subtype with a guard before each addition that rejects if the limit would be exceeded. Main calls it on the embedded examples (1, 1234, 16#fe#, 16#f0e# in the proper bases) and prints each result with Integer'Image through Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The loop-carried Sum has only its type range after the first iteration, so each addition is preceded by a guard against Sum exceeding a declared limit that leads to a visible rejection, which can never trigger for 31-bit inputs.
- **termination**: The digit-extraction loop lives in a procedure, so no termination check is generated, and the loop is still finite because Val shrinks by division by Base of at least 2.
- **division**: Base is a subtype ranging 2..36 so the mod and / divisors are statically nonzero.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, procedures, while loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The sums for the embedded example numbers are printed with Put_Line.

Assessed on 2026-10-15 against page revision 413075 of the [task](https://rosettacode.org/wiki/Sum_digits_of_an_integer) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
