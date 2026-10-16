# Wilkinson's polynomial

**Candidate: proofs plausibly discharge automatically.** No Oracle rule is violated and no annotation is needed because iteration counts are fixed, but proofs are plausible rather than likely because multi-limb arithmetic and complex division run through loops with many loop-carried values that need careful range-bounded types and guards.

Position 1416 in the [progression](../../progression.md#stage-26), in stage 26.

## Approach

Represent coefficients and roots as fixed-point numbers in fixed-capacity limb arrays, with a record pairing two of them as a complex number. Build the perturbed polynomial (second coefficient -210 - 2^-23) from the embedded integer coefficients, run a fixed number of Durand-Kerner sweeps in a for loop using Horner evaluation, then sort and print the 20 roots as text. Division and capacity-overflow guards lead to explicit failure messages. About 420 lines.

## Proof obligations to watch

- **overflow**: Fixed-capacity big-number add, multiply and carry loops must keep every limb and carry inside declared ranges, which holds only if limb types and carries are bounded by construction, with the capacity sized for 20^20-scale coefficients at 20+ digits of fraction.
- **division**: The root iteration divides complex values by products of root differences, so each divisor is guarded for zero with a specified outcome of perturbing the starting point or reporting failure.
- **termination**: A fixed iteration count in a for loop replaces a convergence test, so no variant is needed and the program prints the residual to show how well it converged.
- **index**: Limb indexing in digit-array arithmetic over loop-carried positions needs guards or ranged index types because no loop invariant can be written.
- **range**: Rounding the values to decimal text needs every digit and exponent to be bounded, and the big-number result is checked against the capacity before printing.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, big numbers, string building, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the polynomial coefficients and the computed roots, with real and complex parts, to standard output.

Assessed on 2026-10-15 against page revision 413607 of the [task](https://rosettacode.org/wiki/Wilkinson's_polynomial) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
