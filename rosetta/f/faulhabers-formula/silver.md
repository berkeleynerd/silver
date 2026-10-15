# Faulhaber's formula

**Candidate: proofs plausibly discharge automatically.** The task needs only small exact rational arithmetic for fixed p up to 9, whose true values are tiny, so overflow checks are dischargeable with explicit magnitude guards; the plausible rating reflects loop-carried fraction values needing those guards and the gcd needing a procedure-based loop.

Position 941 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Fractions are a record of two 64-bit-range integers; gcd is a while-loop procedure, and Bernoulli numbers B_0..B_9 are computed by the Akiyama-Tanigawa recurrence in a fixed array of fractions, with Pascal's-triangle binomials in a constant-size table. For each p from 0 to 9 a for loop accumulates coefficient terms, skipping zero ones, and prints the sign, fraction text built from 'Image with the leading space trimmed, and the power of n via Put and Put_Line. Magnitude guards before every fraction operation reject visibly instead of overflowing. About 130 lines.

## Proof obligations to watch

- **overflow**: Fraction arithmetic in the Bernoulli recurrence carries values through loops, so each operation is preceded by a magnitude guard (about 10^9 on numerators and denominators) that rejects visibly, which keeps products and cross-sums inside 64 bits.
- **termination**: Euclid's gcd is written as a while loop inside a procedure with an out parameter, since a function would need a variant, and recursion is avoided.
- **division**: Every denominator is kept positive by construction and checked non-zero by a guard before each division, mod or fraction build.
- **index**: Bernoulli and binomial tables are fixed arrays indexed 0..10 by for-loop variables over the array's own range, so indexing is routine.
- **range**: The binomial coefficient is built by Pascal's triangle addition in a small 2D table, avoiding the product/quotient form and keeping values far below the range limit.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the ten closed-form polynomials, one per line, using partial-line output.

Assessed on 2026-10-15 against page revision 415264 of the [task](https://rosettacode.org/wiki/Faulhaber's_formula) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
