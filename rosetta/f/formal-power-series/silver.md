# Formal power series

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded rational arithmetic in fixed-size arrays with guards and rejection outcomes, so checks follow from types and guards, but loop-carried rational values need careful range guards and the gcd and nonlinear products make provers work harder.

Position 866 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Represent a rational as a record of a bounded numerator and positive denominator and a series as a fixed-length array of rationals, with add, multiply (convolution), divide (term-by-term recurrence), differentiate and integrate (integration constant zero) as procedures that report an overflow or invalid-division flag. Sine and cosine are built together in one for loop using sin[n+1]=cos[n]/(n+1) and cos[n+1]=-sin[n]/(n+1), then printed as text built in a bounded buffer, with a quotient such as sin/cos series shown as a demonstration of division. Every rational operation normalizes via a gcd procedure and guards intermediate magnitudes before use. About 230 lines.

## Proof obligations to watch

- **overflow**: Rational add and multiply cross-products are computed in a wider integer type and each is guarded by a range test, with an overflow outcome of printing a rejection message rather than altering a result.
- **division**: Series division and rational division guard the divisor against zero (a zero leading coefficient is rejected visibly), and the gcd loop divides only by a value guarded to be nonzero.
- **termination**: The Euclid gcd and any while loops live in procedures so no termination check arises, while all series loops are for loops over fixed indexes.
- **index**: Convolution indexes I+J and N-I are bounded by the fixed term capacity through for-loop ranges and a guard before each store.
- **other**: Lazy infinite series is replaced by a fixed-capacity truncation (for example 12 terms) with documented limits, and the mutually recursive sin/cos definition is computed iteratively term by term, which is faithful for the coefficients shown but not truly lazy.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, records, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints the truncated sine, cosine and a quotient series as text lines.

Assessed on 2026-10-15 against page revision 414219 of the [task](https://rosettacode.org/wiki/Formal_power_series) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
