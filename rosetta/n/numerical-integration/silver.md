# Numerical integration

**Candidate: proofs plausibly discharge automatically.** The task is plain numerical code with no Oracle conflict and loops that are for loops, but proofs for float accumulators over millions of iterations only discharge if each step carries an explicit range guard, which makes it plausible rather than likely. Float formatting and the 1/x domain guard add further care but need no annotations.

Position 1187 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Real is a bounded Long_Float subtype and the integrand is selected by an enumeration (Cubed, Reciprocal, Identity) through a case-based function F rather than a function parameter or generic. Five procedures (left, right, midpoint, trapezium, Simpson) use for loops over 1 .. N with each x computed directly from the index, and each accumulation is guarded against leaving the bounded range, rejecting visibly if it would. A main procedure runs the four embedded test cases and prints results through a bounded float-to-text routine. About 170 lines.

## Proof obligations to watch

- **floating point**: Float sums carried through loops of up to 6,000,000 iterations know only the type range afterwards, so each accumulation step is guarded against leaving a declared bounded float subtype and rejects visibly otherwise.
- **division**: The 1/x integrand and the step-size division by N need a nonzero divisor, which is discharged by guarding x against a positive lower bound just before dividing and by N being a Positive subtype.
- **overflow**: The x**3 and 4*sum1 style products need operand ranges small enough to stay within the float subtype, which declared bounds on a, b, n and the integrand domain provide.
- **range**: Converting the loop index to a float and computing a + h*i produces a loop-carried value whose range is not known, so it is computed directly from the index and clamped by a guard to the interval before calling the integrand.
- **other**: Printing floats needs a bounded float-to-text conversion that scales to integers with guarded range checks, whose proof depends on the admitted library or a carefully guarded scaling routine.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, enumerations, floating point, floating-point images, string building, 'Image of scalars, case statements, for loops, procedures, functions and conditional expressions.

## External effects

- **console output** (allowed): Prints the five method results for each of the four demonstration integrals.

Assessed on 2026-10-15 against page revision 414364 of the [task](https://rosettacode.org/wiki/Numerical_integration) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
