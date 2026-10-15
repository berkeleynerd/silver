# Largest proper divisor of n

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by the 1..100 loop ranges (the divisor D is always at least 1 and Result is always within Integer), and both loops are for loops, so every check follows from types and no annotation is needed.

Position 113 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Main uses a subtype N_Range is Integer range 1 .. 100 and an outer for loop over it, with an inner forward for loop over 1 .. N / 2 that sets Result to the divisor whenever N mod D = 0, so the last hit is the largest and no exit is needed. Each value is printed with Integer'Image, padded with one extra space when below 10, and Put_Line of an empty string ends a row when N mod 10 = 0. About 22 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 100 values as ten rows of ten right-aligned numbers.

Assessed on 2026-10-15 against page revision 414303 of the [task](https://rosettacode.org/wiki/Largest_proper_divisor_of_n) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
