# Palindrome dates

**Candidate: proofs likely to discharge automatically.** Every check follows from subtype ranges, for-loop bounds, a Count guard and fixed string positions, and no loop carries a value needing an invariant. The fixed year bound 2200 is a documented resource limit that covers all 15 required results.

Position 526 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Nested for loops over Year 2020..2200, Month 1..12 and Day 1..Days_In_Month(Year, Month) enumerate dates in order (the leap-year rule uses mod), skipping dates up to 2020-02-02. Each date is tested by comparing digits of the year with the reversed digits of month and day (extracted with / and mod), and a match with Count < 15 builds a 10-character String and prints it with Put_Line, then increments Count. The 15th palindrome falls in 2150, so the 2200 bound is sufficient and the loops run to completion without a while loop. About 70 lines.

## Proof obligations to watch

- **overflow**: The Count increment is guarded by Count < 15 just before it, so the type range discharges it.
- **index**: Digit characters are written to fixed positions 1..10 of a 10-character String, which are static bounds.
- **range**: Digit extraction via /, mod and Character'Val is bounded by year, month and day subtypes, but the provers must see the quotient is 0..9, which is routine for small ranges.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, for loops, functions, procedures, string indexing, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 15 palindromic dates, one per line.

Assessed on 2026-10-15 against page revision 413826 of the [task](https://rosettacode.org/wiki/Palindrome_dates) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
