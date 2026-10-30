# Color Difference CIE ΔE2000

**Candidate: proofs plausibly discharge automatically.** The algorithm is straight-line floating-point code with no loop-carried values, so every check depends only on declared input ranges and guards, but float nonlinear arithmetic, elementary-function contracts and 10-decimal formatting make discharge dependent on careful program shape.

Position 1099 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Test colors are embedded in a constant two-dimensional Long_Float array of ranged values, and a pure function computes ΔE2000 straight-line with Sqrt, Sin, Exp and Arctan from an admitted math library, with a hand-written atan2 using explicit branches on the sign of the x term. A for loop over the 15 rows calls the function, scales the result to an integer count of 1e-10 units under a range guard, and builds each output line in a bounded String buffer printed with Put_Line. About 140 lines.

## Proof obligations to watch

- **floating point**: Every Long_Float operation must be shown finite, which holds because L is declared 0..100 and a and b are declared -128..127 so the seventh powers (about 1e16) stay far below overflow, though float provers may struggle without such explicit subtypes.
- **division**: Denominators like 1.0 + 0.015*n/Sqrt(20.0+n) and 1.0 + 0.0225*(c1+c2) are at least 1.0 by construction, but the prover must derive that through nonlinear float expressions, so each is guarded by an explicit comparison with a visible fallback.
- **range**: Sqrt arguments (sums of squares, c1*c2, and the final sum whose cross term c*h*rt can be negative) must be provably non-negative, so the program checks the final sum is at least zero and otherwise reports a failure line rather than clamping.
- **other**: The program needs an admitted Sqrt, Sin, Exp and Arctan library with verified preconditions, which Silver does not yet provide.
- **overflow**: Converting the result times 1e10 to an integer for the 10-decimal text is guarded by a range check before conversion, and rounding must match the required 10 decimals.

## Language surface recorded by this assessment

Floating point, ranged subtypes, multidimensional arrays, for loops, functions, procedures, floating-point images, string building, 'Image of scalars, integer division, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints a table of the 15 input Lab pairs and their computed ΔE2000 values to standard output.

Assessed on 2026-10-15 against page revision 407169 of the [task](https://rosettacode.org/wiki/Color_Difference_CIE_%CE%94E2000) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
