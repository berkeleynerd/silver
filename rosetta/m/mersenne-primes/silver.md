# Mersenne primes

**Candidate: proofs likely to discharge automatically.** All loops are for loops over declared ranges, so there is no termination or invariant issue, and the only nonlinear terms (2**P and D*D) are bounded by the declared ranges; the fixed exponent limit is a documented resource bound because the task says "until some limitation is reached".

Position 1497 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

A Main procedure loops P over the ranged subtype 2..31, computes M as 2**P - 1 in a 64-bit integer type, and tests primality by an inner for loop over divisors D in 2..46341 that sets a Boolean flag when D*D <= M and M mod D = 0. If the flag stays clear, it prints the exponent with Put_Line and 'Image. The documented limit is exponent 31, which yields the eight Mersenne primes 2, 3, 5, 7, 13, 17, 19 and 31 shown in the sample output. About 30 lines.

## Proof obligations to watch

- **overflow**: 2**P - 1 and D*D are bounded by declaring P as a range 2..31 and D as a range 2..46341 in a 64-bit integer type, so the provers only need modest bound reasoning.
- **division**: The mod divisor D comes from a loop range starting at 2, so it is never zero.

## Language surface recorded by this assessment

Integers, integer division, exponentiation, ranged subtypes, Boolean objects, for loops, 'Image of scalars and procedures.

## External effects

- **console output** (allowed): Prints each Mersenne exponent found, one per line.

Assessed on 2026-10-15 against page revision 410682 of the [task](https://rosettacode.org/wiki/Mersenne_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
