# Days between dates

**Candidate: proofs likely to discharge automatically.** All checks follow from the character-class guards, ranged year, month and day subtypes, and a bounded day-number formula, with no loops carrying values and no recursion, so the proofs should discharge without annotations.

Position 1124 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the eight example date pairs as string literals and pass each pair with its comment to a procedure that parses each date with a function that checks length 10, the two dashes, digit characters, month 1..12 and day within the month length (with a leap-year test), using a ranged Year/Month/Day record or out parameters. A pure function converts a validated date to a day number with integer division and mod formulas, and the procedure prints the signed difference using 'Image, or prints a visible "invalid date" rejection line when parsing fails. About 95 lines.

## Proof obligations to watch

- **range**: Digit values come from Character'Pos only after an explicit check that each character is between '0' and '9', so the year, month and day conversions stay in their subtypes.
- **overflow**: Year is restricted to 1..9999 and month to 1..12 by the parser, so the day-number formula (era and day-of-year arithmetic) is bounded well within Integer and the difference of two day numbers cannot overflow.
- **index**: Every string index is a static position 1..10 into a String that is first checked to have length 10, and the month-length table is indexed by a month already validated to 1..12.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, 'Image of scalars, text parsing, case statements, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints one result line per embedded date pair, and a rejection line for invalid dates.

Assessed on 2026-10-15 against page revision 415393 of the [task](https://rosettacode.org/wiki/Days_between_dates) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
