# Five weekends

**Candidate: proofs plausibly discharge automatically.** Every check follows from subtype ranges, mod 7 and guarded counters, with no recursion, while loops or annotations needed, so proofs should discharge, though loop-carried counters need careful guards.

Position 159 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Iterate years 1900..2100 and months 1..12 with for loops, carrying the weekday of the 1st as a 0..6 subtype and advancing it by the month length (leap year via mod 4, 100, 400) modulo 7. A month with 31 days whose 1st is a Friday is printed with Put_Line, counted under a guard, and marks the year as having a five-weekend month; a per-year flag then drives the printing of years without one and their count. About 45 lines.

## Proof obligations to watch

- **overflow**: The month counter and the count of years without a five-weekend month are loop-carried, so each increment is guarded by a comparison against its subtype's upper bound with a visible Reject outcome.
- **range**: The weekday of the 1st is carried across iterations, so each update is computed with mod 7 into a 0..6 subtype, which follows from the type alone.
- **length**: Output lines concatenate Integer'Image results with literals, whose bounded lengths follow from the Year and Month subtypes.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each five-weekend month, the total count, and the years lacking one.

Assessed on 2026-10-15 against page revision 413988 of the [task](https://rosettacode.org/wiki/Five_weekends) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
