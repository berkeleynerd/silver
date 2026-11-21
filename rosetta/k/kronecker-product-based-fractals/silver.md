# Kronecker product based fractals

**Candidate: proofs likely to discharge automatically.** Everything is fixed-size array indexing with for loops over constant ranges and div/mod by 3, so run-time checks follow from types and loop bounds with no recursion, while loops or loop-carried unbounded values.

Position 667 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Represent the 3x3 seed matrices as constant two-dimensional arrays of a 0..1 subtype and the result as a fixed 81x81 array, building each order with a Kronecker-product procedure that writes a second buffer from the previous one, using index arithmetic i / 3 and i mod 3 within for loops over the fixed order sizes. Do this for the Vicsek and Sierpinski carpet seeds to order 4, then print each result row by filling an 81-character String buffer with '#' or ' ' and calling Put_Line. All sizes are constants and every index is a for-loop variable or a div/mod of one, so no guards beyond the loop ranges are needed. About 80 lines.

## Proof obligations to watch

- **index**: Indexes such as i / 3, i mod 3 and the block offsets are computed inside nested for loops over fixed ranges, so the provers bound them from the loop ranges and the constant divisor without any invariant.
- **overflow**: Cell values are a 0..1 subtype and products of two such values stay in 0..1, while loop-carried sizes are declared subtypes or constants, so nothing can overflow.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The two order-4 fractals (81 by 81) are printed as ASCII art rows.

Assessed on 2026-10-15 against page revision 414297 of the [task](https://rosettacode.org/wiki/Kronecker_product_based_fractals) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
