# Minimum numbers of three lists

**Candidate: proofs likely to discharge automatically.** All indexes come from a for loop over the arrays' own range and the values are fixed Integer constants, so every check follows from types and static bounds with no loop-carried state.

Position 873 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Three constant arrays of five Integers with embedded data, and a Result array of the same type filled by a for loop over the array range using if comparisons to pick the minimum of the three elements. A second for loop prints each result with 'Image and Put, followed by a Put_Line to end the line. About 25 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the five resulting minimums on one line.

Assessed on 2026-10-15 against page revision 415517 of the [task](https://rosettacode.org/wiki/Minimum_numbers_of_three_lists) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
