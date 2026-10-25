# Roots of a cubic polynomial

**Candidate: proofs plausibly discharge automatically.** The program is straight-line bounded floating-point arithmetic with a for loop over embedded data and no recursion or annotation-requiring loops, so it should prove if the float ranges are bounded and elementary functions carry admitted contracts, but floating-point proof effort makes it plausible rather than likely.

Position 1104 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed the six test matrices as a constant array of 3x3 arrays of a bounded Long_Float subtype, compute the monic characteristic polynomial coefficients from trace, principal minors and determinant, then solve the cubic in closed form (trigonometric branch for three real roots, Cardano branch for one real plus a complex pair) into a small complex record array. The error estimate is the residual of the polynomial evaluated at each root, printed with Put_Line and float image formatting in a procedure driven by a for loop over the matrices. About 170 lines.

## Proof obligations to watch

- **floating point**: Every Long_Float operation must be shown finite, which works only if matrix entries are a bounded subtype (for example +/-1.0e6) so the cubic coefficients and the error evaluation cannot overflow.
- **range**: The trigonometric solution needs the Arccos argument within -1..1 and Sqrt arguments non-negative, so each is guarded just before use (clamping only for rounding noise, and the discriminant sign selects the branch).
- **division**: Divisions by the leading coefficient and by the Cardano radius are safe because the polynomial is monic and a zero or tiny radius is handled by an explicit branch.
- **other**: The task has no specified root-finding method beyond estimating errors, so a closed-form solution without loops is chosen to avoid loop-carried float values with no invariant.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, arrays, multidimensional arrays, records, for loops, procedures, functions, Boolean objects, integers, Put without a newline, 'Image of scalars and conditional expressions.

## External effects

- **console output** (allowed): The program prints each embedded matrix, its characteristic polynomial, the eigenvalues and the error estimates.

Assessed on 2026-10-15 against page revision 410080 of the [task](https://rosettacode.org/wiki/Roots_of_a_cubic_polynomial) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
