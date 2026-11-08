# Angle difference between two bearings

**Candidate: proofs likely to discharge automatically.** Scaled-integer arithmetic over ranged subtypes turns every check into a type-range or guard fact, and the only loop is a for loop over a fixed array, so no annotation is needed.

Position 162 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Bearings are stored as integers scaled by 10000 (ten-thousandths of a degree) in two constant 8-element arrays of a ranged subtype covering -180 to 180 degrees, which holds all eight required pairs exactly. A for loop over the array range computes b2 - b1 in a wider integer subtype, adds or subtracts 360 degrees with if/elsif guards to land in range, then a procedure formats the scaled value as sign, whole degrees and four decimals into a bounded String and prints it. The optional any-finite-bearing extra is left out, since its floating-point test values exceed the fixed scaled range. About 70 lines.

## Proof obligations to watch

- **overflow**: Bearings are scaled integers in a ranged subtype of plus or minus 1_800_000, so the difference of two lies within plus or minus 3_600_000 and the normalising if statements bring it back into range with no loop-carried value.
- **length**: The output line is built in a fixed-size buffer whose capacity covers the longest sign, digits and four-decimal text, with a fixed digit count per field so no length check depends on a loop-carried value.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints one result line per bearing pair with Put_Line.

Assessed on 2026-10-15 against page revision 413637 of the [task](https://rosettacode.org/wiki/Angle_difference_between_two_bearings) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
