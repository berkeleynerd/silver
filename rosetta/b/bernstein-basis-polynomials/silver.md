# Bernstein basis polynomials

**Candidate: proofs plausibly discharge automatically.** All code is loop-free and recursion-free with literal data, so the only non-routine checks are floating-point overflow and range on a handful of products, which declared subtype bounds should let the provers discharge. The heavier part is the new surface (floating point, float formatting), so discharge depends on careful range choices rather than any annotation.

Position 1102 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Define a bounded Float subtype for coefficients and for t, then write five small procedures and functions (tobern2, evalbern2, tobern3, evalbern3, bern2to3) as straight-line code with no loops, using the embedded example polynomials and the points 0.25 and 7.50. The main procedure calls them in the task's order and prints each result as a rounded two-decimal value through a fixed-width formatter built on a bounded buffer. Inputs are all constants inside the declared ranges, and any generic entry point would reject out-of-range coefficients with a visible message. About 130 lines.

## Proof obligations to watch

- **floating point**: Every Float add and multiply needs a finite-result check, which discharges only if inputs are range-subtyped (coefficients within a few thousand, t within 0.0 .. 10.0) so the provers can bound each intermediate de Casteljau value.
- **overflow**: Chained products such as s*b01 + t*b12 are nonlinear, so the subtype bounds must be tight enough that interval reasoning proves the results stay inside the Float range.
- **range**: Results of tobern and bern2to3 are assigned to range-constrained out parameters, so the subtype bounds must be wide enough for all in-range inputs or the program needs a visible guard that rejects out-of-range coefficients.
- **length**: Formatted float text is built in a fixed bounded buffer, so a clamp or fixed-width formatter must show the length can never exceed the buffer.

## Language surface recorded by this assessment

Floating point, ranged subtypes, procedures, functions, floating-point images, string building and Put without a newline.

## External effects

- **console output** (allowed): The program prints the coefficient and evaluation tables to standard output.

Assessed on 2026-10-15 against page revision 413653 of the [task](https://rosettacode.org/wiki/Bernstein_basis_polynomials) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
