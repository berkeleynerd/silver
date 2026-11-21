# Numerical integration/Gauss-Legendre Quadrature

**Candidate: proofs plausibly discharge automatically.** The task is bounded, uses a fixed 5-point rule and float arithmetic over small ranges, so it needs no annotations, but proving no overflow or division-by-zero through loop-carried floats and Newton updates depends on careful subtype bounds and guards. Float formatting and an admitted elementary-function library (Exp, Cos) are new surface that makes it plausible rather than likely.

Position 1008 in the [progression](../../../progression.md#stage-16), in stage 16.

## Approach

Fixed constant N=5 with arrays of Long_Float for the Legendre coefficients, roots and weights, built with nested for-loops and a bounded Newton iteration (while loop with an iteration cap inside a procedure); the integrand exp(x) is a function applied over the shifted nodes on [-3,3], and the results are printed via a fixed-precision float-to-text routine into bounded String buffers. Every loop-carried float is declared in a bounded subtype and guards precede each division, so the failure outcome is visible (a printed message) rather than silently altered. About 110 lines.

## Proof obligations to watch

- **floating point**: Exp, Cos and the Newton iteration need operands bounded by a subtype such as Float range -1.0e3 .. 1.0e3, with the division by the derivative guarded against zero (visible fallback outcome) so no overflow or division check can fail.
- **termination**: The Newton loop is a while loop in a procedure with a fixed iteration cap (e.g. 100) and a convergence exit, so no termination check applies and no variant is needed.
- **range**: Computed values stored back into range-limited Long_Float subtypes (the iterate x, the polynomial values) need clamping guards or wide subtypes, otherwise the loop-carried values only have type-range knowledge and each store checks against that range.
- **index**: Legendre coefficient table indices 0..5 come from for-loops over the array's own range, but expressions like n-2 need loop bounds starting at 2 to stay in range.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, arrays, for loops, while loops, procedures, functions, Put without a newline, string building, integers, integer division and Boolean objects.

## External effects

- **console output** (allowed): Prints the 5 roots, 5 weights and the integral estimate as text lines.

Assessed on 2026-10-15 against page revision 414365 of the [task](https://rosettacode.org/wiki/Numerical_integration/Gauss-Legendre_Quadrature) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
