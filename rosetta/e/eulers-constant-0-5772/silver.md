# Euler's constant 0.5772...

**Candidate: proofs likely to discharge automatically.** The task only asks to compute gamma, so a fixed-precision integer long division of a closed-form rational avoids floating point and loop-carried accumulators, and every check follows from subtype ranges and the for-loop index over the buffer's own range.

Position 436 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Evaluate the Castellanos rational approximation (990^3 - 55^3 - 79^2 - 16)/70^5 exactly in 64-bit integer constants, then produce 14 decimal digits by schoolbook long division in a for loop over a fixed-length String buffer, with the remainder held in a subtype ranged 0 .. Den-1. The digit (remainder*10 / Den, in 0..9) is converted to a Character via 'Val and written at the loop index of the buffer, then the buffer is printed after "0." with Put_Line. About 35 lines.

## Proof obligations to watch

- **overflow**: The exact numerator 970126368 and denominator 1680700000 fit easily in Integer, and the remainder times 10 stays under 1.7e10, so a 64-bit integer subtype with remainder range 0 .. Den-1 discharges the multiplication and the mod result's range check.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, for loops, string building, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the computed constant 0.57721566490153 as text.

Assessed on 2026-10-15 against page revision 414189 of the [task](https://rosettacode.org/wiki/Euler's_constant_0.5772...) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
