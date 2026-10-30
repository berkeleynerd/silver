# Lagrange Interpolation

**Candidate: proofs plausibly discharge automatically.** The task is fixed-size polynomial arithmetic that stays exact in bounded integers with static loop bounds, so checks follow from types and a few guards; the plausible rating reflects accumulator overflow in nested loops and text formatting of the fractions.

Position 915 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the four points in constant arrays of a small ranged integer subtype and build each Lagrange basis polynomial as an integer-coefficient array by repeatedly multiplying by (x - xj), then scale each by the common denominator divided by its own denominator so every coefficient stays exact. Sum the weighted bases into integer numerators over denominator 6 and print each coefficient as a fraction, such as 13/6 x^3 - 16 x^2 + 215/6 x - 21, using Image and bounded concatenation with explicit sign handling in a procedure. About 90 lines.

## Proof obligations to watch

- **overflow**: Polynomial-product and accumulation updates inside loops carry only the coefficient subtype's range, so each is computed in Long_Long_Integer from small-ranged operands and guarded or bounded by the subtype so the stores cannot fail; the fixed 4-point, 4-iteration loops are small enough that GNATprove can unroll them.
- **division**: Dividing the common denominator by each basis denominator is guarded by an explicit nonzero test, with distinct x values rejected visibly, and exactness is kept by scaling all coefficients by the common denominator 6 rather than truncating.
- **index**: Polynomial coefficient indices i+j are bounded by degree-3 array ranges, which follows from the loop ranges over the arrays' own index types.
- **range**: Formatting signed coefficients into a bounded text buffer needs the image length guarded against buffer capacity, which holds because coefficient magnitudes are bounded by the subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the interpolating polynomial's coefficients and form to standard output.

Assessed on 2026-10-15 against page revision 390011 of the [task](https://rosettacode.org/wiki/Lagrange_Interpolation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
