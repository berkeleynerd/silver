# Convert day count to ordinal date

**Candidate: proofs likely to discharge automatically.** All values are bounded by declared subtypes (day count 0..146096, year 0..399, month 1..12), and loops use for-loop indexes with guards before each subtraction, so every check follows from types and local guards with no variant or invariant needed.

Position 514 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed the three example day counts in a constant array of a ranged subtype 0..146096; a function decides leap years by mod 4/100/400 on a year subtype 0..399, then a for loop over years subtracts each year's length from a remaining-days variable under a guard and a found flag, followed by a for loop over a month-length table. Digits for DD, MM and the zero-padded YYYY are built in a fixed-length String from division and mod of bounded values, and printed with Put_Line. About 70 lines.

## Proof obligations to watch

- **range**: The remaining-days accumulator is a ranged subtype of 0..146096 and is only decremented inside a guard comparing it with the current year or month length, so subtraction stays in range without an invariant.
- **initialization**: Year, month and day outputs are initialized to defaults before the search loops, and a found flag guards each assignment so no path leaves them unset.
- **index**: Month-length table lookups use a for-loop index over the table's own range, and zero-padded digit output indexes a fixed two- or four-character buffer by constants derived from values bounded by subtypes.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, 'Image of scalars, string building, string indexing and characters.

## External effects

- **console output** (allowed): Prints the DD/MM/YYYY triplet for each of the three embedded example day counts.

Assessed on 2026-10-15 against page revision 406635 of the [task](https://rosettacode.org/wiki/Convert_day_count_to_ordinal_date) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
