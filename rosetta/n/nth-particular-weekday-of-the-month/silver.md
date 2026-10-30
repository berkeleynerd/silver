# Nth Particular Weekday of the Month

**Candidate: proofs likely to discharge automatically.** Everything is bounded integer arithmetic on small ranged subtypes in a fixed for loop with no loop-carried values, so the checks follow from types and the error case is a visible zero result.

Position 771 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Use ranged subtypes for Year, Month (1..12), Weekday (0..6) and N (1..5), a loop-free function giving the weekday of the first of a month, a Days_In_Month function with leap-year logic, and Nth_Weekday returning the day number or 0 when absent. A for loop over 2020..2029 calls it for October second Monday and November fourth Thursday and prints each line using Image with a leading-zero guard, so all arithmetic is bounded by types and no loop-carried state exists. About 70 lines.

## Proof obligations to watch

- **overflow**: The weekday-of-first computation uses a Sakamoto-style formula on ranged Year (1900..2100) and Month subtypes, so every intermediate is bounded and discharges from types.
- **range**: Result day is computed as 1 + offset + 7*(N-1) in a small Integer range and returned as 0 when it exceeds the month length (a visible 'no such day' value), so no subtype check can fail.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, functions, 'Image of scalars, string building, case statements and Put without a newline.

## External effects

- **console output** (allowed): Prints a header and one line per year 2020 through 2029 with the two Thanksgiving dates.

Assessed on 2026-10-15 against page revision 414735 of the [task](https://rosettacode.org/wiki/Nth_Particular_Weekday_of_the_Month) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
