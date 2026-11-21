# Numerical integration/Romberg integration

**Candidate: proofs plausibly discharge automatically.** All loops are bounded for loops and the data is small, but floating-point checks on loop-carried accumulators only discharge through declared range subtypes plus explicit guards, so success depends on careful program shape; Silver also needs float types and float formatting that it lacks today.

Position 998 in the [progression](../../../progression.md#stage-16), in stage 16.

## Approach

Fixed-size arrays of a bounded Real subtype hold the previous and current Romberg rows (6 entries), and the integrand exp(x) is a function using a fixed-term Taylor series with range reduction avoided by the narrow domain [-3, 3]. The trapezoid refinement is nested for loops (intervals doubling via an integer counter bounded by 32), with guards before each accumulation that print a rejection if a value leaves the bounded range, and the final value is printed through float-to-text formatting. About 95 lines.

## Proof obligations to watch

- **floating point**: Every float add, multiply and divide needs a bounded operand range, which the program gets from a ranged Real subtype and from guards before each operation that reject (printing a visible failure) if a value leaves the range.
- **overflow**: Loop-carried sums and the extrapolation values R(k) are known only by their subtype range, so each is guarded just before the update against a fixed bound far above the expected magnitudes (about 60).
- **division**: The divisors (f-1) with f=4**k and the interval count are constants or loop-bounded positive values, so a guard or the subtype lower bound shows they are nonzero.
- **termination**: All loops are for loops over fixed small ranges and exp is a fixed-term Taylor series, so no variant or recursion is needed.
- **range**: The Taylor terms term*x/k stay bounded only through a guard on the magnitude of each term, which must hold for x in [-3, 3] without changing the computed value.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, arrays, for loops, functions, procedures, integers, Boolean objects, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the Romberg result for the integral of exp(x) from -3 to 3 with 5 steps.

Assessed on 2026-10-15 against page revision 414366 of the [task](https://rosettacode.org/wiki/Numerical_integration/Romberg_integration) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
