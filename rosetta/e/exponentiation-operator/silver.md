# Exponentiation operator

**Candidate: proofs plausibly discharge automatically.** All checks follow from bounded subtypes and guards placed just before each multiply or divide in for loops, with no annotations needed, but the loop-carried accumulators (especially the floating-point one) make discharge depend on careful program shape.

Position 1071 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Declare bounded subtypes for base, exponent and result, and write procedures Exponentiate for int^int and float^int with an out Boolean Ok flag, plus overloaded functions named "**" that call them and return a fixed result when Ok is false. Each loop is a for loop over 1 .. abs Exponent that guards the accumulator magnitude before every multiply or divide, and a zero base with a negative exponent is rejected before the loop. Main embeds the two example cases, formats results via 'Image or a scaled-integer rendering, and prints them with Put_Line. About 80 lines.

## Proof obligations to watch

- **overflow**: The integer accumulator is loop-carried, so before each multiply a guard compares abs Result with a fixed limit divided by abs Argument and the routine reports overflow as a visible failed outcome instead of wrapping or clamping.
- **floating point**: The float accumulator needs a magnitude guard before each multiply or divide so the result stays finite, and prover support for float multiplication and division is weaker than for integers.
- **division**: Negative exponents divide by the base, so a zero base is rejected with a specified outcome before the loop.
- **range**: Exponent is a declared bounded subtype so the for loop ranges are static, and negating its lowest value cannot overflow.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, floating point, floating-point images, 'Image of scalars, string building, for loops, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): Prints the example results 2.5 ** 3 and -12 ** 3 with Put_Line.

Assessed on 2026-10-15 against page revision 412780 of the [task](https://rosettacode.org/wiki/Exponentiation_operator) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
