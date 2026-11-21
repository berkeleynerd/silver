# Cholesky decomposition

**Candidate: proofs plausibly discharge automatically.** The algorithm is three nested for loops over constant bounds, so index and termination checks are routine, but float overflow on loop-carried sums and the square-root precondition need explicit guards and an admitted Sqrt, which makes discharge depend on careful program shape.

Position 997 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Store each matrix as a fixed-size two-dimensional array of a bounded float subtype, embed the two example matrices as constants, and compute L with nested for loops (row, column, inner sum) inside a procedure. Before the square root and the division, the program guards that the diagonal term is strictly positive and that every accumulated value stays inside the chosen magnitude bound, otherwise it prints a rejection message. Results are printed row by row in a fixed number of decimal places using float formatting and Put. About 95 lines.

## Proof obligations to watch

- **floating point**: The accumulator and products are loop-carried floats that GNATprove knows only by type, so each step needs a range guard (for example rejecting a magnitude above a fixed bound) before the next multiply-add to rule out overflow.
- **floating point**: Square root requires a non-negative argument and the division needs a nonzero pivot, so the program checks the diagonal term is strictly positive and reports the matrix as not positive definite otherwise, which also gives invalid input a specified outcome.
- **other**: Sqrt must come from an admitted library operation with a verified contract, since Silver authors cannot write one and the Ada elementary-functions package is not yet available.
- **index**: The matrix indexes are loop variables over a fixed constrained range, with the inner index K-1 guarded by running J only over 1 .. K-1, so index checks follow from the declared bounds.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, floating point, floating-point images, arrays, multidimensional arrays, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each input matrix and its Cholesky factor as rows of formatted numbers.

Assessed on 2026-10-15 against page revision 414112 of the [task](https://rosettacode.org/wiki/Cholesky_decomposition) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
