# Babbage problem

**Candidate: proofs likely to discharge automatically.** The loop index is bounded by its declared range so the square fits in the wide type and the only loop-carried state is a Boolean and a ranged result, so every check follows from types; the not-found branch gives a visible outcome rather than narrowing behavior.

Position 173 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Declare a candidate subtype 1 .. 99_736 and a 64-bit square type, then loop over the candidates with a for loop, converting each to the wide type, squaring it and testing the square mod 1_000_000 = 269_696, exiting on the first hit and recording it in a Boolean-guarded result. After the loop, print the image of the answer if found, otherwise print a fixed not-found message. About 22 lines.

## Proof obligations to watch

- **overflow**: The square of a candidate up to 99_736 reaches about 9.95e9, so it is computed in a declared 64-bit-range type whose range type bounds make the multiplication provably safe.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the found integer (or a not-found message) with Put_Line.

Assessed on 2026-10-15 against page revision 415340 of the [task](https://rosettacode.org/wiki/Babbage_problem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
