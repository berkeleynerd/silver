# Roots of a quartic polynomial

**Candidate: proofs plausibly discharge automatically.** There are no loops apart from for loops over fixed data, and no recursion, so termination and indexing are routine. Discharge depends on placing magnitude and precondition guards before every nonlinear floating-point operation and elementary-function call, which takes careful program shape but no annotations.

Position 1114 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

A Complex record of two Long_Float components with small add, subtract, multiply, divide and square-root functions; Ferrari's method solves the resolvent cubic for one real root by Cardano/trigonometric cases, then two complex quadratics give the four roots, with a biquadratic shortcut when b = d = 0. The twelve example polynomials are embedded as an array of coefficient records iterated by a for loop in Main, and every division, square root, arccos and large product is preceded by an explicit guard whose failure prints a visible rejection message for that polynomial. About 220 lines.

## Proof obligations to watch

- **floating point**: Products such as f*f*f, g*g, the squared modulus in complex square root and the complex multiply/divide can overflow Long_Float unless each intermediate is range-guarded (for example rejecting a polynomial whose normalized coefficients or intermediates exceed a documented magnitude with a visible message), which is feasible but must be done at every nonlinear step.
- **division**: Normalizing by the leading coefficient, complex division by s and the -0.5*g/(j*j*j) step each need an explicit nonzero (or minimum-magnitude) guard immediately before the division, with a zero leading coefficient reported as not a quartic.
- **other**: Preconditions of the SPARK elementary functions (Sqrt argument non-negative, Arccos argument in [-1,1], Arctan not both zero, ** with non-negative base) must be met by guards such as clamping (r + re)/2 and the Arccos argument against rounding just before the call, which the provers cannot otherwise derive from IEEE facts like sqrt(x*x+y*y) >= |x|.
- **range**: Formatting a root as text requires the float image or rounding conversion to stay within its target type, which a magnitude guard before conversion discharges.

## Language surface recorded by this assessment

Integers, floating point, floating-point images, 'Image of scalars, records, arrays, Boolean objects, functions, procedures, for loops and Put without a newline.

## External effects

- **console output** (allowed): Each equation and its four real or complex roots are printed to standard output.

Assessed on 2026-10-15 against page revision 410085 of the [task](https://rosettacode.org/wiki/Roots_of_a_quartic_polynomial) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
