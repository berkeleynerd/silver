# Prime decomposition

**Candidate: proofs plausibly discharge automatically.** Trial division uses only guarded integer and limb arithmetic in procedures with bounded arrays, so the checks follow from declared ranges and guards, but the fixed-capacity big-number limb arithmetic and loop-carried divisor need careful shaping, hence plausible rather than likely.

Position 1390 in the [progression](../../progression.md#stage-25), in stage 25.

## Approach

Represent the number as a fixed-capacity record of base-10^k limbs, divide it in place by a small trial divisor in a procedure using a for loop over limbs, and test divisibility by the remainder. A while loop in a procedure tries divisors 2, 3, 4, ... while the divisor squared (compared via a guarded multiply or a quotient test) does not exceed the remaining value, appending each factor to a bounded result array and finally appending the remaining cofactor. Embedded example numbers are decomposed and printed with 'Image-style conversion into a bounded string buffer, with a visible rejection if limb or factor capacity would be exceeded. About 170 lines.

## Proof obligations to watch

- **overflow**: Limb arithmetic (limb times base plus remainder) is bounded by choosing a base and a Long_Long_Integer-based limb range so the products fit, and the trial divisor is a ranged subtype capped by a guard before each increment.
- **index**: The big number is a fixed-capacity limb array with a length field in a ranged subtype, and every loop over limbs uses for loops or a guard just before indexing, but the factor result list needs a guard on its count before each append.
- **termination**: All loops live in procedures (no termination check), and the trial-division while loop is placed in a procedure rather than a function, so no variant is needed.
- **range**: Loop-carried divisor and factor count carry only type ranges, so the divisor subtype and count capacity are sized so that increments are guarded and an over-capacity input is rejected with a specified message rather than clamped.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and big numbers.

## External effects

- **console output** (allowed): Prints each embedded example number's prime factors, one line per number.

Assessed on 2026-10-15 against page revision 414416 of the [task](https://rosettacode.org/wiki/Prime_decomposition) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
