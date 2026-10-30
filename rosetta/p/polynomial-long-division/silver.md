# Polynomial long division

**Candidate: proofs plausibly discharge automatically.** All checks follow from bounded coefficient and index types plus explicit guards, and the while loop is replaced by a for loop in a procedure, so no annotation is needed, though loop-carried coefficient arithmetic needs careful range guards.

Position 820 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Polynomials are fixed-capacity arrays of a bounded coefficient subtype indexed 0..Max with the task's example embedded; a Degree procedure scans in reverse, and the division is a for loop over the quotient degree from high to low, subtracting the shifted scaled divisor with per-element guards. Zero divisors, non-exact leading coefficient divisions and out-of-range results are rejected with a visible message, and output is built from per-term text via Image into a bounded buffer and printed with Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: Coefficient products and subtractions in the loop are bounded by a small declared coefficient subtype with a guard rejecting any step whose result would leave the range, giving a visible rejection rather than silent change.
- **division**: The divisor is the leading coefficient of D, which is guarded non-zero by an explicit check before the division; the quotient's range is also guarded (Integer'First / -1).
- **termination**: The division loop runs in a procedure with no termination check, and is written as a for loop over the quotient degree from high to low so it terminates by construction.
- **index**: Shifted indices (I+K) are guarded against the fixed capacity before each access, and the degree is found by a reverse for loop over the array range.
- **range**: Degree values use a subtype including -1 for the zero polynomial, with loop-carried degree typed by that range so no invariant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints the numerator, denominator, quotient and remainder polynomials.

Assessed on 2026-10-15 against page revision 415186 of the [task](https://rosettacode.org/wiki/Polynomial_long_division) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
