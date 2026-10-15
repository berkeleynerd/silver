# Roots of any polynomial

**Candidate: proofs plausibly discharge automatically.** The program needs only bounded loops, fixed arrays and bounded-float complex arithmetic, so no annotation is needed, but floating-point nonlinear range and overflow checks across nested iteration loops depend on careful guard placement and may stress the provers.

Position 1119 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Represent a polynomial as a fixed array of 72 bounded Float coefficients plus a degree in 1..71, and complex numbers as records of two bounded Floats; embed a representative set of the task's example polynomials, including the degree-71 Conway polynomial, in a constant table. Roots are found by Durand-Kerner iteration in a procedure with nested for loops (fixed 1000 rounds, convergence flag), starting from powers of a fixed complex seed rather than trigonometric functions and comparing squared magnitudes to avoid square roots, with each complex operation guarded against range violation and zero divisors. Main prints each polynomial, each root and the Horner-evaluated residual, or a visible non-convergence message when a guard trips. About 230 lines.

## Proof obligations to watch

- **floating point**: Every complex multiply, add and divide in the Horner and denominator loops can overflow a Float64, so components use a bounded subtype and each result is range-guarded before assignment, with a visible 'did not converge' report on violation.
- **range**: Loop-carried root values and accumulators are known only by their subtype range after the first iteration, so every update needs a guard just before assignment or the range check cannot be proved.
- **division**: The Durand-Kerner correction divides by a product of root differences and the leading coefficient, so each divisor's squared magnitude is tested against a positive threshold before dividing, with a specified outcome when it is too small.
- **termination**: The iteration uses a fixed-count for loop (for example 1000 rounds) with a convergence flag instead of a while loop, so no variant is needed and the loops live in procedures.
- **overflow**: Degree and index arithmetic over a 72-entry coefficient table is bounded by the declared index subtype and static maximum degree, so it is routine.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, floating point, floating-point images, 'Image of scalars, arrays, multidimensional arrays, records, for loops, procedures, functions, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints each polynomial, its computed roots and the evaluated residual of each root.

Assessed on 2026-10-15 against page revision 411377 of the [task](https://rosettacode.org/wiki/Roots_of_any_polynomial) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
