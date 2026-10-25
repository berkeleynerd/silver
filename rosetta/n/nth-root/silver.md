# Nth root

**Candidate: proofs plausibly discharge automatically.** Everything is bounded by float subtypes and fixed-count for loops with no annotations, but proving float range/overflow on a loop-carried iterate through nonlinear arithmetic depends on careful clamping, so it is plausible rather than likely.

Position 1060 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A function Nth_Root takes a bounded float subtype A (1.0 to 1.0e9) and N in a small integer subtype (1..200), starts at x = A, and runs a fixed-count for loop of Newton steps x := ((N-1)*x + A/x**(N-1))/N, computing the power quotient by an inner for loop of N-1 divisions so no overflow occurs. Inputs below 1.0 are inverted and the root reciprocated, and out-of-range inputs are rejected with a printed message; the main procedure embeds the four sample cases and prints each result via a float-to-text image. About 70 lines.

## Proof obligations to watch

- **floating point**: Float overflow and range checks on the loop-carried iterate are discharged only by a bounded float subtype (about 1.0 to 1.0e9), range-guarded inputs and a clamp before each store, since no invariant can carry bounds.
- **overflow**: Computing A / x**(n-1) directly would overflow for the 125th root, so the program divides by x repeatedly n-1 times in an inner for loop while x stays at least 1, so the quotient only shrinks.
- **division**: The divisor x is nonzero because its subtype has a lower bound of 1.0 and A below 1 is handled by taking the root of 1/A, with inputs outside the documented range rejected visibly.
- **termination**: Iteration uses a for loop with a fixed count (about 5000) instead of a convergence test, so no variant is needed and the result is exact to printed precision since Newton converges monotonically.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, floating-point images, 'Image of scalars, string building, for loops, procedures, functions, arrays and records.

## External effects

- **console output** (allowed): Prints each root result line with Put_Line.

Assessed on 2026-10-15 against page revision 412941 of the [task](https://rosettacode.org/wiki/Nth_root) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
