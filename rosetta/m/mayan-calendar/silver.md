# Mayan calendar

**Candidate: proofs likely to discharge automatically.** Everything is bounded integer arithmetic over embedded constant dates with subtype-limited ranges, plus case statements for names and for loops over a constant array, so all checks follow from types and static bounds. No while loops, recursion, parsing or heap are needed, and the year restriction keeps the day count nonnegative so mod and division are well defined.

Position 798 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the seven example dates as constant arrays of year, month and day with ranged subtypes. A function computes the Julian day number with integer division. The Long Count is five digits from division and mod by 144000, 7200, 360, 20 and 1, using the offset of the Julian day over 584283, which stays positive given the year bound. A procedure then prints the Tzolk'in number and name, the Haab' day (Chum when 0) and month name, and the G-number, with Put and the case statements selecting each string literal. About 110 lines.

## Proof obligations to watch

- **overflow**: The Julian day arithmetic (153*m, 365*y) stays far below 2**31 because year, month and day are subtypes (year 1900..2100, month 1..12, day 1..31), so the solver bounds every intermediate by type ranges.
- **range**: Mod and division results feed name-selecting case statements, and the divisor is a nonzero literal, so each result is bounded by the mod range and every case choice list is closed by the type.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, case statements, procedures, functions, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Prints one line per embedded Gregorian date with its Long Count, Calendar Round and Lord of the Night.

Assessed on 2026-10-15 against page revision 413780 of the [task](https://rosettacode.org/wiki/Mayan_calendar) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
