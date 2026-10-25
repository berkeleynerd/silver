# Calendar

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged subtypes, constant loop bounds and constant-divisor arithmetic, and the task needs no recursion, while loops, input, or exceptions, so only the String slice index bounds need careful shaping. The optional Julian-to-Gregorian transition and arbitrary page widths are left out, with the 80-column device chosen.

Position 789 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the twelve centered 20-character month names and the weekday header as constants, and compute each month's 6x20 character grid in a three-dimensional or array-of-String buffer using a closed-form weekday (Zeller-style, Gregorian only) and a case-based days-in-month with the leap-year rule. Print the year heading, then for each of four rows of three months build each output line in a fixed 72-character String by slice assignment and emit it with Put_Line; the digits of each day are written directly as characters, so no 'Image is needed. All loops are for loops over fixed ranges with no loop-carried state, and the year is a range-limited subtype whose test value is 1969. About 110 lines.

## Proof obligations to watch

- **index**: Row and column positions for each day are computed from the weekday offset and day number, and the 0..5 row and 1..20 column bounds follow from constant-divisor arithmetic on ranged subtypes, which the provers should discharge without a loop invariant.
- **overflow**: The day-of-week calculation uses the year, so Year is a subtype limited to 1..9999 (a documented resource limit) and the intermediate products stay far inside Integer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, case statements, for loops, procedures and functions.

## External effects

- **console output** (allowed): The calendar lines for 1969 are written to standard output with Put_Line.

Assessed on 2026-10-15 against page revision 413658 of the [task](https://rosettacode.org/wiki/Calendar) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
