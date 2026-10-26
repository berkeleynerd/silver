# Numerical integration/Tanh-Sinh Quadrature

**Candidate: proofs plausibly discharge automatically.** Control flow is just bounded for loops, but floating-point hyperbolic functions and a loop-carried accumulator need an admitted math library with range contracts and careful range subtypes, so discharge is plausible rather than routine.

Position 1507 in the [progression](../../../progression.md#stage-29), in stage 29.

## Approach

Define a bounded Float type, an enumeration choosing the integrand (Sin or Exp) in place of a function parameter, and a procedure that runs the nested for loops over k in 1..5 and i in -n..n with h = 0.1, computing sinh, cosh, tanh from an admitted elementary-function library with range-bounded inputs. Early exit on accuracy is a visible stop test between iterations; results are printed through text formatting of the float to eight decimals via integer scaling. About 80 lines.

## Proof obligations to watch

- **floating point**: Sinh, Cosh and Tanh of a bounded t (|t| at most 3.2) stay finite only if the float type is range-constrained and the library functions carry range contracts, which the provers must bound through nonlinear products.
- **overflow**: The integral accumulator ss is loop-carried with no invariant, so each addition must be guarded against the declared float range, with an overflow outcome that is a visible rejection rather than a clamp.
- **range**: The index i from -n to n with n = 2**k - 1 and k at most 5 is bounded by a ranged subtype for k, so i*h stays within a declared range.
- **termination**: All loops are bounded for loops inside a procedure, so no variant is needed; the integrand is selected by an enumeration with a case-style if rather than a function pointer.

## Language surface recorded by this assessment

Integers, integer division, exponentiation, ranged subtypes, Boolean objects, floating point, arrays, for loops, functions, procedures, string building, 'Image of scalars, floating-point images and Put without a newline.

## External effects

- **console output** (allowed): Prints the two integral results as text.

Assessed on 2026-10-15 against page revision 414367 of the [task](https://rosettacode.org/wiki/Numerical_integration/Tanh-Sinh_Quadrature) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
