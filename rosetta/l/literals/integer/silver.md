# Literals/Integer

**Candidate: proofs likely to discharge automatically.** Every value is a static literal within Integer's range, so the only checks are compile-time constant range checks plus a call to 'Image, which raise nothing, and the proofs are trivial.

Position 43 in the [progression](../../../progression.md#stage-3), in stage 3.

## Approach

Main declares Integer constants written as Ada based literals (2#10_1101_0111#, 8#1_327#, 10#727#, 16#2D7#, with underscores and an exponent form like 7#1#E2). Each one is printed with Silver_IO.Put_Line of the constant's 'Image. There are no loops, no input and no arithmetic beyond static literal values. About 20 lines.

## Language surface beyond today's Silver

Integers and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the value of each based literal with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412883 of the [task](https://rosettacode.org/wiki/Literals/Integer) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
