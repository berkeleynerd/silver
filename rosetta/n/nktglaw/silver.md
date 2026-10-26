# NKTgLaw

**Candidate: proofs likely to discharge automatically.** Only a few integer multiplications and sign comparisons are needed, and ranged input subtypes make every overflow check follow from types, so proofs should discharge without annotations.

Position 76 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

Use scaled integer values in ranged subtypes for x, v, m and dm/dt, embedded as constants, and compute p, NKTg1 and NKTg2 as integer products in wider declared ranges. Print each value via 'Image concatenated into bounded strings, and select the tendency text with if/elsif/else on the sign of NKTg1 and NKTg2, including a specified zero case. About 45 lines.

## Proof obligations to watch

- **overflow**: The products m*v, x*p and dm/dt*p are discharged by declaring inputs as small ranged integer subtypes (for example -1000..1000) so every product fits in 64 bits.

## Language surface recorded by this assessment

Integers, ranged subtypes, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints p, NKTg1, NKTg2 and the two tendency lines with Put_Line.

Assessed on 2026-10-15 against page revision 411993 of the [task](https://rosettacode.org/wiki/NKTgLaw) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
