# Evaluate binomial coefficients

**Candidate: proofs likely to discharge automatically.** Every check discharges without annotations: the for loop needs no termination variant, the divisor comes from the loop range, and the only loop-carried value, the overflow-prone accumulator, is guarded by a division-based bound test just before each multiply that leads to a reported outcome.

Position 312 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A side-effect-free function Binomial(N, K) takes N and K as ranged subtypes (for example 0 .. 60). It returns 0 when K > N, uses symmetry to set M to the smaller of K and N - K, and then runs the multiplicative formula in a for loop over 1 .. M on a nonnegative 64-bit count, with an overflow guard before each multiply that returns a -1 sentinel. Main calls it on embedded pairs, including (5, 3), and prints each value with 'Image, or a "too large" message when the sentinel comes back. About 40 lines.

## Proof obligations to watch

- **overflow**: The loop-carried product Result * (N - M + I) gets an explicit guard just before it (Result > Count'Last / (N - M + I)), and that guard returns a documented too-large result that Main reports.
- **range**: Result belongs to a nonnegative subtype, and the assignment Result * Factor / I stays in that subtype because both operands are nonnegative and the guard bounds the product, which the provers handle even though the arithmetic is nonlinear.
- **division**: Both divisions are safe: the loop index I runs over 1 .. M, so it is never zero, and the guard divides by N - M + I, which is at least I because M <= N.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the computed coefficients, including C(5,3) = 10, with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415419 of the [task](https://rosettacode.org/wiki/Evaluate_binomial_coefficients) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
