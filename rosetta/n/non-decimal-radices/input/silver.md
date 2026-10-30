# Non-decimal radices/Input

**Candidate: proofs plausibly discharge automatically.** Every check follows from the Radix subtype, the string's own index range and an overflow guard before each accumulation, though the loop-carried accumulator needs careful guard shape.

Position 1126 in the [progression](../../../progression.md#stage-18), in stage 18.

## Approach

A procedure Parse takes a String and a Radix (subtype 2..16) and returns an out Boolean Ok and an out bounded Natural Value, scanning characters with a for loop over the string's range and mapping digits and letters through Character'Pos to digit values. Before each accumulate step it checks that the digit is below the base and that the accumulator will not exceed the limit, otherwise it sets Ok False and exits the procedure. Main parses embedded examples such as "ABCF123" in base 16, "7651" in base 8, "1010011010" in base 2 and a decimal string, printing each value or a rejection line, with an invalid string included to show that outcome. About 75 lines.

## Proof obligations to watch

- **overflow**: The accumulator is loop-carried with no invariant, so a guard just before each step rejects the input when acc exceeds (Max_Value - digit) / base, which also proves the multiply-add cannot overflow.
- **range**: The base is a subtype Radix range 2..16 and each digit value is checked below the base before use, so conversions from Character positions stay in range.
- **index**: Loops run over the string's own index range, so indexing is safe, and empty strings are rejected up front with a specified outcome.
- **division**: The divisor is the Radix subtype whose lower bound is 2, so division by zero is excluded by type.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, string indexing, unconstrained arrays, for loops, procedures, 'Image of scalars and text parsing.

## External effects

- **console output** (allowed): Prints each parsed value and any rejection of an invalid digit string.

Assessed on 2026-10-15 against page revision 413803 of the [task](https://rosettacode.org/wiki/Non-decimal_radices/Input) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
