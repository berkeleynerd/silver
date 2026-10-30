# Logistic curve fitting in epidemiology

**Candidate: proofs plausibly discharge automatically.** Everything is bounded floating-point arithmetic over a fixed 96-element array with a capped search loop in a procedure, so no annotation is needed, but proving no overflow in Exp and the squares depends on careful range guards and an admitted Exp.

Position 1063 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Store the 96 daily totals as a constant Integer array and implement the sum of squared errors as a function over a bounded Real candidate r, guarding r to a safe interval before calling Exp. A procedure runs the pattern search (step doubling or halving) in a for loop with a fixed iteration cap, then computes R0 = Exp(12*r) and prints both values with a fixed-decimal float image. About 80 lines.

## Proof obligations to watch

- **floating point**: Exp of R*I can overflow unless R is clamped to a guarded range (for example -1.0 to 1.0, with I at most 95) before each Exp call, and the clamp must reject out-of-range candidates visibly rather than alter the result.
- **overflow**: The squared-error sum over 96 terms and the division by 1 + N0*(Eri-1)/K need range guards on the operands so the provers can bound them and the denominator stays nonzero.
- **termination**: The search loop lives in a procedure and uses a fixed iteration cap so no variant is needed and the result is not altered.
- **other**: Whether the elementary function library admits Exp with a verified contract is an assumption about future library operations.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, floating-point images, arrays, for loops, procedures, functions, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the fitted r and R0 to standard output.

Assessed on 2026-10-15 against page revision 414311 of the [task](https://rosettacode.org/wiki/Logistic_curve_fitting_in_epidemiology) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
