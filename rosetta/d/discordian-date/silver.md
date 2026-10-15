# Discordian date

**Candidate: proofs likely to discharge automatically.** Every check is bounded by small subtypes, a 1..12 table index and arithmetic on values below 400 after explicit validation, with only for loops, so GNATprove should discharge it with no annotations. The main new surface is ordinary integer, array, enumeration and string-building features that Silver will need anyway.

Position 1178 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Embed several sample Gregorian dates in a constant array, each validated (year range, month 1..12, day within the month length with a leap-year rule); invalid ones print a visible rejection line. Convert uses a cumulative-days table to get the day of year, handles 29 February as St. Tib's Day, shifts later leap-year days by one, then derives season, day and weekday with / and mod by 73 and 5 and prints via case statements on small enumerations and Integer'Image. All loops are for loops over the array range, and no function contains a while loop or recursion. About 120 lines.

## Proof obligations to watch

- **range**: The Gregorian day count is checked against the month length for that year before use, and the derived day-of-season, season index and weekday come from mod and / by constants on a bounded day-of-year, so each conversion into its subtype is within range.
- **index**: The cumulative month-length table is indexed by a month subtype 1..12 that is validated before the lookup, so the index check follows from the type.
- **overflow**: Year is a subtype 1901..2399 and every intermediate is at most 366 or year+1166, so all arithmetic is tiny relative to Integer.
- **length**: The output line is built in a fixed buffer sized for the longest possible text (weekday, season, holiday and year), and each piece's length is known from constant literals before concatenation.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, enumerations, arrays, for loops, case statements, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints one Discordian date line for each embedded sample date.

Assessed on 2026-10-15 against page revision 413692 of the [task](https://rosettacode.org/wiki/Discordian_date) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
