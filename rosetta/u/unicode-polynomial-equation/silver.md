# Unicode polynomial equation

**Candidate: proofs plausibly discharge automatically.** The task needs only bounded integer parsing, arrays and string building, but a hand-written rational parser with many loop-carried values needs careful guards at every arithmetic step, so discharge is plausible without annotations rather than routine.

Position 1513 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

Embed the test polynomials as byte strings, strip spaces into a bounded buffer, and parse with a while-loop scanner over UTF-8 byte sequences (written with Character'Val codes) into terms holding a rational coefficient (Long_Long_Integer numerator and positive denominator) and an exponent. Accumulate terms into a fixed array of rational coefficients indexed by a bounded exponent range, then print nonzero terms from highest exponent down, mapping exponent digits to UTF-8 superscript bytes and reducing coefficients to mixed or vulgar fractions. Every arithmetic step is preceded by an overflow, range, zero-divisor or index guard that rejects the input with a printed message. About 650 lines.

## Proof obligations to watch

- **overflow**: Rational coefficients with decimal scaling, exponent shifts, duplicate-term summation and fraction normalisation are loop-carried in 64-bit numerator/denominator pairs, so each step needs a guard just before the operation that rejects the input with a visible message when the limit would be exceeded.
- **division**: Divisors from '/' and the fraction slash may be zero, and gcd reduction divides by a loop-carried value, so each is guarded by an explicit nonzero test with a rejection outcome.
- **index**: The scan position into the compacted UTF-8 byte buffer and the exponent-indexed coefficient table are loop-carried, so every lookahead tests the position against the length and every exponent is range-checked before indexing, rejecting out-of-range exponents.
- **range**: Multi-digit and signed exponents (including 007, scientific e-notation and negative superscripts) are accumulated in loops, so digit counts and magnitudes are capped by guards before each accumulation step.
- **termination**: All parsing and gcd loops are while loops, which is acceptable because they live in procedures and not in functions, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, exponentiation, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Each embedded test polynomial and its normalised form are printed as UTF-8 text.

Assessed on 2026-10-15 against page revision 396822 of the [task](https://rosettacode.org/wiki/Unicode_polynomial_equation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
