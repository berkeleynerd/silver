# Day of the week

**Candidate: proofs likely to discharge automatically.** Zeller's formula on a loop index with a declared range gives small bounded arithmetic with no loop-carried state, so overflow, range and division checks all follow from types and nothing needs an annotation. The only new surface is integer division, 'Image and a bounded concatenation.

Position 1532 in the [progression](../../progression.md#stage-32), in stage 32, which adds membership tests.

## Approach

A for loop over Year in 2008 .. 2121 (a ranged subtype) computes the weekday of 25 December with Zeller's congruence in plain integer arithmetic, so no standard date library is needed. When the result is Sunday, the program prints the year with its 'Image text and the suffix "-12-25". Every operand is bounded by the loop range, and the divisors are literal constants, so no guards are needed. About 22 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, 'Image of scalars, string building and membership tests.

## External effects

- **console output** (allowed): Prints each qualifying year, one line per year, with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415391 of the [task](https://rosettacode.org/wiki/Day_of_the_week) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
