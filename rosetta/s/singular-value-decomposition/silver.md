# Singular value decomposition

**Candidate: proofs plausibly discharge automatically.** The task fits the Oracle with no conflicts, but iterative floating-point linear algebra with loop-carried accumulators and parsing of real numbers makes automatic proof of overflow, NaN and division checks depend on careful range guards, and exact output matching is only approximate.

Position 1236 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Store A, U and V in fixed-capacity two-dimensional Long_Float arrays (say up to 8 by 8) with validated m and n, parse the input numbers with a checked text parser, and compute the SVD by one-sided Jacobi rotations in a bounded while loop inside a procedure. Every division and square root is guarded, entries are bounded by input validation, and out-of-range or non-convergent cases print a specified rejection message. Results are normalized to U, Sigma and V and printed with a float-formatting routine. About 170 lines.

## Proof obligations to watch

- **floating point**: One-sided Jacobi sweeps use square roots, divisions and products on floats, so the program must reject non-finite or out-of-range inputs with a visible outcome and clamp operands by guards so no overflow or NaN check can fail.
- **division**: Rotation angles divide by off-diagonal terms and normalization divides by singular values, so each division needs an explicit guard on a non-zero denominator with a specified outcome such as leaving a column unchanged.
- **termination**: The sweep-until-converged loop must be a while loop in a procedure with a fixed maximum sweep count, so no variant is needed and non-convergence is reported.
- **index**: Matrices are fixed-capacity two-dimensional arrays with m and n validated against the capacity before use, and loops run over declared ranges.
- **overflow**: Loop-carried float accumulators for dot products lose their bounds after the first iteration, so entries must be range-limited by a type such as a bounded float subtype and validated on input, which GNATprove may still struggle to carry through nested sums.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, floating-point images, text parsing, arrays, multidimensional arrays, for loops, while loops, procedures, functions, standard input, Put without a newline, Boolean objects and conditional expressions.

## External effects

- **standard input** (allowed): The task requires reading m, n and the matrix entries from standard input.
- **console output** (allowed): U, Sigma and V are printed as text matrices.

Assessed on 2026-10-15 against page revision 414471 of the [task](https://rosettacode.org/wiki/Singular_value_decomposition) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
