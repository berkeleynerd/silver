# French Republican calendar

**Candidate: proofs likely to discharge automatically.** The task is bounded date arithmetic over a 14-year range with fixed tables and for loops, so every check follows from ranged subtypes and range guards without annotations; the later-date leap-year method can be omitted by documenting the 1805 limit.

Position 811 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Dates are held as records or separate parameters of ranged subtypes. Gregorian to Republican converts to a day count since 22 September 1792 using for loops over years and a constant month-length array, then walks Republican years (leap years 3, 7, 11 only, range limited to 1792-09-22 to 1805-12-31) and 30-day months with for loops; the reverse is done by accumulating days from the Republican date. Month and Sansculottide names are printed with case statements over literal strings, numbers are printed using 'Image, and the five test dates are embedded and converted both ways, with out-of-range dates rejected with a visible message. About 170 lines.

## Proof obligations to watch

- **overflow**: Day counts and year sums are held in ranged subtypes (years 1..14, days 0..6000) with the input checked against that range first, so additions and mod/div on them discharge from type bounds.
- **range**: Month and day lookups for names and month lengths index constant arrays whose index subtypes match the computed month/day subtypes, with a guard rejecting out-of-range dates before conversion.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, case statements, for loops, procedures, functions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints each converted date for the five embedded test dates in both directions.

Assessed on 2026-10-15 against page revision 414225 of the [task](https://rosettacode.org/wiki/French_Republican_calendar) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
