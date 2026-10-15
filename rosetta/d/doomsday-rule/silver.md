# Doomsday rule

**Candidate: proofs likely to discharge automatically.** All arithmetic is small bounded integer mod arithmetic on subtyped values with constant embedded inputs, and there are no while loops, recursion or functions needing variants, so every check follows from types and static bounds.

Position 790 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Seven embedded dates sit in constant arrays of ranged subtypes (Year 1800..2200, Month 1..12, Day 1..31), and a for loop over the array's own range calls a procedure that computes the answer. Pure functions compute the leap flag and the year's doomsday with mod, a constant table gives the first doomsday of each month for common and leap years, and (7 + d - anchor) mod 7 plus the year doomsday selects a weekday in 0..6. A case statement maps the weekday to a literal name printed with Put_Line, and the dates are constants so no input validation is needed. About 85 lines.

## Proof obligations to watch

- **range**: Array indexes for the month, leap flag and weekday are bounded by ranged subtypes and mod 7 results, so index and range checks follow from types and the embedded dates sit inside the subtype ranges.
- **overflow**: The year is a subtype limited to 1800..2200, so 2 + 5*(y mod 4) + 4*(y mod 100) + 6*(y mod 400) stays far below the Integer limit.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, case statements, for loops, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): Prints the weekday name for each of the seven dates, one per line, with Put_Line.

Assessed on 2026-10-15 against page revision 412749 of the [task](https://rosettacode.org/wiki/Doomsday_rule) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
