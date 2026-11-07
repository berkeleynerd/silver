# Lucas-Lehmer test

**Candidate: proofs likely to discharge automatically.** Every loop is a for loop with static bounds and all values are bounded by declared subtypes under a documented 31-exponent limit, so checks discharge without annotations; the task explicitly permits stopping at the implementation's maximum precision, so the 47th prime is not required.

Position 311 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Declare a subtype for exponents 2..31 and a 64-bit signed integer subtype for residues below 2**31; a function Is_Mersenne_Prime computes the modulus by a doubling for loop, then runs the fixed-count for loop S := (S*S - 2) mod MP and returns S = 0 (P = 2 handled by an explicit guard). The main procedure loops P over 2..31 and prints each exponent whose Mersenne number passes, with the 31-bit precision limit documented as the implementation's maximum precision. About 40 lines.

## Proof obligations to watch

- **overflow**: S*S-2 stays within 64-bit signed because S is a subtype bounded below 2**31 and the exponent is limited to 31, so the bound follows from declared ranges, though the mod result must be shown to fit the subtype.
- **range**: The modulus 2**P-1 is built by a bounded for-loop of doublings (or a constant table) so no variable-exponent ** is needed, keeping the nonlinear step easy for the provers.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, functions, procedures, 'Image of scalars, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints the exponents of the Mersenne primes found, one per line or space-separated.

Assessed on 2026-10-15 against page revision 413768 of the [task](https://rosettacode.org/wiki/Lucas-Lehmer_test) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
