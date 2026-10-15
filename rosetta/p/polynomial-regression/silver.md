# Polynomial regression

**Candidate: proofs plausibly discharge automatically.** All data is embedded and small, so exact integer normal equations avoid floating point and every check follows from bounded subtypes or a guard just before the operation, though the loop-carried sums and determinants need careful guard placement.

Position 936 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed the 11 data points as constant arrays of a bounded integer subtype, compute the normal-equation sums (n, sum x^k for k up to 4, sum x^k*y for k up to 2) in for loops with a pre-addition guard against the accumulator limit, then solve the 3x3 system exactly by Cramer's rule in 64-bit integers after checking the determinant is nonzero. Each coefficient is the integer quotient scaled by 1000 with rounding, and a procedure builds a bounded text buffer with sign, integer part and three fractional digits and prints it with Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: Power sums, products and the 3x3 Cramer determinants are loop-carried or nonlinear, so the program uses bounded subtypes for the embedded data, a 64-bit accumulator and a guard before each addition that rejects instead of overflowing.
- **division**: The coefficient quotients divide by the system determinant, which is guarded to be nonzero with a specified rejection outcome for a singular system.
- **range**: Scaling by 1000 for three-decimal rounding and converting digits to text needs bounded intermediate subtypes so the checks follow from declared ranges.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, procedures, string building, 'Image of scalars, Put without a newline, Boolean objects and conditional expressions.

## External effects

- **console output** (allowed): Prints the three fitted coefficients as decimal text.

Assessed on 2026-10-15 against page revision 414410 of the [task](https://rosettacode.org/wiki/Polynomial_regression) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
