# Leap year

**Candidate: proofs likely to discharge automatically.** Every check is a rem by a nonzero literal on a bounded integer inside a for loop with no loop-carried state, so all of them follow from types and static bounds. Only the scalar-image and string-building library operations are new, and the program needs no annotations.

Position 293 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A subtype Year_Number range 1 .. 9999 and a side-effect-free function Is_Leap_Year (Year) returning (Year rem 4 = 0) and then ((Year rem 100 /= 0) or else (Year rem 400 = 0)). Main runs a for loop over a fixed sample range such as 1896 .. 2004 and prints each year's 'Image concatenated with a leap or common verdict through Silver_IO.Put_Line. Rem by non-zero literals cannot fail, and the loop index stays within Year_Number's range by declaration. About 22 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each sample year with its leap or common verdict via Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415546 of the [task](https://rosettacode.org/wiki/Leap_year) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
