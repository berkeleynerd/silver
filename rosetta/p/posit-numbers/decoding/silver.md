# Posit numbers/decoding

**Candidate: proofs plausibly discharge automatically.** Every operation is bounded integer arithmetic on a fixed 16-bit array with loop-carried values confined by ranged subtypes and guards, so no annotation is needed but the shifted-scale arithmetic needs careful shaping.

Position 1509 in the [progression](../../../progression.md#stage-29), in stage 29.

## Approach

Store the example word 0000110111011101 as a constant array of 16 bit values (0..1), and in a procedure decode the sign, count the regime run with a for loop and a stop flag, then read the es=3 exponent bits and fraction bits into ranged integers. Special encodings (zero, NaR) are handled by explicit guards with printed outcomes, and the result is printed as the exact fraction numerator/2**power using 'Image and bounded concatenation (477/134217728 for the example), with a guard if the power exceeds 62. About 80 lines.

## Proof obligations to watch

- **overflow**: The fraction accumulator (value*2+bit over up to 13 bits) and the power-of-two scaling are loop-carried, so they are declared with ranged subtypes (fraction below 2**16, scaling exponent capped at 62) and shifted only after an explicit guard that falls back to printing the exponent form.
- **index**: Bit positions walk a constant 16-element array with for loops over its own range, plus a guard before each computed index (regime end, exponent start), so no loop invariant is needed.
- **range**: The regime run length k and the combined scale k*2**es+e are loop-carried values bounded only by their declared subtypes (-16..16 and -128..128), which must be chosen wide enough for the checks to discharge.
- **termination**: All scanning uses for loops with an exit or a flag in a procedure, so no variant is required.

## Language surface recorded by this assessment

Integers, integer division, exponentiation, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the decoded fraction (and optionally the sign/regime/exponent fields) with Put_Line.

Assessed on 2026-10-15 against page revision 401000 of the [task](https://rosettacode.org/wiki/Posit_numbers/decoding) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
