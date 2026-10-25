# Holidays related to Easter

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded integer math with literal divisors on a ranged year, and every loop is a for loop over fixed small arrays, so checks follow from types and guards without annotations.

Position 799 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the 16 requested years in a constant array, define a ranged Year subtype, and implement the Julian and Gregorian computus as integer functions returning the March-based day offset of Easter. Convert offsets (Easter plus 39, 49, 56, 60, 70 days) to month and day by scanning a constant month-length array in a for loop, with the Julian-to-civil shift computed from century arithmetic, and print each line through bounded string concatenation and 'Image of small integers with Put_Line. About 130 lines.

## Proof obligations to watch

- **overflow**: The Gregorian and Julian computus formulas use mod and division by literals on a Year subtype of 1..4000, so every intermediate fits Integer and the ranges are provable from the type.
- **index**: Day-offset-to-month conversion walks a constant month-length array with a for loop and a guarded subtraction, so the month index stays in 1..12 and a day-of-year past December is guarded as a specified outcome.
- **range**: Computed day and month values assigned to subtypes are guarded by explicit range comparisons before conversion so no range check depends on a loop invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, string building, 'Image of scalars, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints a labelled line of Easter, Ascension, Pentecost, Trinity, Corpus Christi and All Saints dates per year and computus.

Assessed on 2026-10-15 against page revision 414655 of the [task](https://rosettacode.org/wiki/Holidays_related_to_Easter) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
