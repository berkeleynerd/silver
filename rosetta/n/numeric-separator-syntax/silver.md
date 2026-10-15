# Numeric separator syntax

**Candidate: proofs likely to discharge automatically.** Every value is a static literal constant and the output is fixed text plus 'Image of in-range constants, so no check depends on loop-carried values or annotations.

Position 49 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

The program prints String-literal lines stating Ada's rule (underscore only, single, between digits) and declares Integer constants written with separators such as 1_000_000 and 16#FF_FF#. It compares each with its separator-free literal using if statements and prints the 'Image of each value and an equal or differs line. All values are static constants within Integer, so no loop or guard is needed. About 25 lines.

## Language surface beyond today's Silver

Integers, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the description of the separator rules and the demonstrated values with Put_Line.

Assessed on 2026-10-15 against page revision 413863 of the [task](https://rosettacode.org/wiki/Numeric_separator_syntax) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
