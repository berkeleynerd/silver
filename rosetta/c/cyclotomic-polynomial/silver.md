# Cyclotomic polynomial

**Candidate: proofs plausibly discharge automatically.** The mathematics is plain integer array loops with static capacity, so checks follow from types and guards, but loop-carried coefficient arithmetic over a degree of several thousand needs careful per-operation guards, making discharge plausible rather than likely.

Position 948 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Represent each polynomial as a fixed-capacity Integer coefficient array with a degree variable, and compute Phi_n as the product over divisors d of n of (x^d - 1)^mu(n/d) using in-place O(degree) multiply and exact-divide passes by (x^d - 1), with n bounded by a documented limit of 12000. Print the first 30 by looping from the highest degree down, emitting signs, coefficients and exponents with Put and Integer'Image, then scan n upward in a procedure tracking the maximum absolute coefficient to report the first n reaching each height from 2 to 10. Every array access and coefficient update is preceded by an explicit bounds or range guard that rejects out-of-capacity cases. About 160 lines.

## Proof obligations to watch

- **overflow**: Coefficient updates in the multiply and divide by (x^d - 1) loops are loop-carried array values, so each addition or subtraction is guarded with a visible Reject when it leaves a declared coefficient range, since only types are known after the first iteration.
- **index**: Shifted indices such as i+d and i-d are guarded by explicit bounds tests against the fixed maximum degree (about 6400 for n up to 10465, buffer sized to 12000) before each access.
- **termination**: All unbounded searches (the next n with the required coefficient height) live in procedures and for loops, so no function needs a variant.
- **range**: The Moebius value and divisor tests come from trial division in for loops with small declared ranges, and the degree computation phi(n) is guarded to stay within the buffer bound.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the first 30 polynomials and the ten smallest orders with n or -n as a coefficient.

Assessed on 2026-10-15 against page revision 414146 of the [task](https://rosettacode.org/wiki/Cyclotomic_polynomial) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
