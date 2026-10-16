# Sign of an integer (signum)

**Candidate: proofs likely to discharge automatically.** The function is a three-way comparison with no loop-carried values, so every check follows from types and guards. Integer has no signed zero, so the optional signed-zero clause does not apply and nothing conflicts with the Oracle.

Position 761 in the [progression](../../progression.md#stage-15), in stage 15, which adds case statements.

## Approach

Declare a function Signum over Integer returning Integer in -1 .. 1, using an if/elsif/else on x < 0 and x > 0, and embed the examples -10, 42 and 0 in a constant Integer array. A for loop over the array's own range calls Signum and prints each input and result via 'Image concatenation into a bounded String; Integer'Image of an Integer is bounded and fits a fixed buffer. About 30 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, functions, procedures, for loops, arrays, 'Image of scalars, string building and case statements.

## External effects

- **console output** (allowed): Prints each example input and its signum result with Put_Line.

Assessed on 2026-10-15 against page revision 413025 of the [task](https://rosettacode.org/wiki/Sign_of_an_integer_%28signum%29) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
