# Long year

**Candidate: proofs likely to discharge automatically.** Every check follows from a bounded Year subtype, small integer arithmetic and a plain for loop, so no annotation is needed.

Position 294 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Declare a subtype Year of 1 .. 9999 and a function Is_Long (Y : Year) return Boolean that computes the weekday index of Dec 31 for Y and Y-1 as (P + P/4 - P/100 + P/400) mod 7 with P a bounded integer, returning true when it is 4 or the previous year's is 3. The previous year's term is computed with a guard so that Y-1 is only used when Y > 1 (year 0 term is 0). Main loops with a for loop over Year 1900 .. 2100, calling Put_Line (Y'Image) for each long year. About 28 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, 'Image of scalars and procedures.

## External effects

- **console output** (allowed): Prints each long year found in the demonstrated range, one per line.

Assessed on 2026-10-15 against page revision 413765 of the [task](https://rosettacode.org/wiki/Long_year) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
