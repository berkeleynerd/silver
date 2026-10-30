# QR decomposition

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over fixed array ranges, so index and termination checks are routine, but float arithmetic with sqrt and divisions needs range-bounded Float subtypes, guards and an admitted sqrt, which makes discharge depend on careful program shape rather than on annotations.

Position 1103 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed the 3x3 Wikipedia matrix, and a small fixed-size least-squares example (for example 11x3 polynomial regression) in constrained 2D Float arrays with a documented maximum dimension. Procedures with for loops apply each Householder reflection in place (compute column norm, build v, beta, then update the trailing submatrix and accumulate Q), then back-substitute for least squares, printing rounded values via scaled integer text. Every divisor and sqrt argument is guarded with a reported outcome for degenerate input. About 170 lines.

## Proof obligations to watch

- **floating point**: Householder norms, sqrt, division by u1 and by v^T v need no overflow or NaN, discharged by a bounded Float subtype for matrix entries and explicit guards that reject zero or degenerate columns with a visible message.
- **overflow**: Nested dot-product and matrix-update loops carry accumulators whose range is known only from the type, so entries and sums must be clamped by subtype bounds with a documented magnitude limit and guards before each accumulate.
- **division**: Beta = 2/(v^T v) and back substitution divide by R diagonal entries, so each divisor is tested non-zero just before use and a zero diagonal reports rank deficiency.
- **index**: Loops over submatrix rows and columns are indexed by for-loops over declared constant ranges of fixed-size arrays, so indexing is routine.
- **floating point**: Formatting reals with 4 decimals needs a bounded scaled-integer conversion with range guards because float-image is not available, and sqrt requires an admitted elementary-function library with a non-negative argument guard.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, floating point, floating-point images, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the Q and R matrices and the least-squares solution as text lines.

Assessed on 2026-10-15 against page revision 414420 of the [task](https://rosettacode.org/wiki/QR_decomposition) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
