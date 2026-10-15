# Day of the week of Christmas and New Year

**Candidate: proofs likely to discharge automatically.** The program is loop-free integer arithmetic over ranged subtypes small enough that no overflow, index or range check can fail, so every check follows from declarations and no invariant is needed.

Position 768 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed both dates as constants of ranged subtypes (Year 1583..9999, Month 1..12, Day 1..31) and compute the weekday with Sakamoto's loop-free formula using a constant 12-entry offset array indexed by Month and integer / and mod. A function returns a 0..6 subtype and Main prints the day name through a case statement over the seven values, with literal date text in Put_Line. About 45 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, functions and case statements.

## External effects

- **console output** (allowed): Prints the weekday of 2021-12-25 and 2022-01-01 with Put_Line.

Assessed on 2026-10-15 against page revision 415392 of the [task](https://rosettacode.org/wiki/Day_of_the_week_of_Christmas_and_New_Year) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
