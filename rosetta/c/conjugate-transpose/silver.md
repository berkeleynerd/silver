# Conjugate transpose

**Candidate: proofs plausibly discharge automatically.** All data is fixed-size with bounded float components and for-loop indexing, so index and finiteness checks follow from types and no recursion, while-loop or inverse is needed; the plausible rating reflects floating-point accumulation in matrix products that needs range guards or unrolling.

Position 1018 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Represent a complex number as a record of two bounded Float components and matrices as constrained 2-D arrays of that record (fixed 3x3, with the 2x2 case padded or handled by a second constrained type). Procedures compute the conjugate transpose, the products M*M^H and M^H*M, and tolerance-based comparisons for Hermitian, normal and unitary (M^H*M close to identity, avoiding a general inverse), using for loops over the arrays' own ranges. The embedded example matrices are printed together with Boolean results using Put_Line and a bounded float formatter. About 130 lines.

## Proof obligations to watch

- **floating point**: Every real component is a subtype bounded to about +-1.0e3 and products and sums of at most three terms stay below Float'Last, so finiteness checks discharge from ranges alone.
- **overflow**: Matrix-product sums are accumulated in a loop-carried value, so the program either unrolls the fixed 2x2 and 3x3 sums or guards the accumulator against a bound before each addition and rejects out-of-range input visibly.
- **range**: Assigning a computed product or difference back into the bounded component subtype needs an explicit conversion guarded by a bound test, which nonlinear float reasoning may need extra care to prove.
- **index**: Nested for loops run over the matrix's own constrained index ranges, so index checks for M(i,j) and its transpose M(j,i) follow from the declared square bounds.
- **other**: Formatting floats to four decimals for output needs a bounded-buffer float-to-text routine whose own internal checks must be provable (an admitted library operation would be ideal).

## Language surface recorded by this assessment

Floating point, ranged subtypes, records, multidimensional arrays, arrays, for loops, procedures, functions, Boolean objects, 'Image of scalars, floating-point images, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each matrix, its conjugate transpose and the three classification results with Put_Line.

Assessed on 2026-10-15 against page revision 413672 of the [task](https://rosettacode.org/wiki/Conjugate_transpose) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
