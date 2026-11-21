# Multiple regression

**Candidate: proofs plausibly discharge automatically.** The task is plain linear algebra on small fixed arrays with for loops, but float arithmetic carried through elimination loops needs careful range guards and a nonzero-pivot test, so discharge depends on program shape without any annotation. Output needs float-to-text formatting, which Silver lacks today.

Position 1018 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the two example datasets in fixed-size constrained Float arrays, form the normal equations (X^T X) beta = X^T y with nested for loops, and solve them by Gauss-Jordan elimination with partial pivoting in a procedure on a small fixed matrix. A pivot whose magnitude is below a tolerance rejects the input with a visible message, intermediate magnitudes are guarded against a documented limit, and the coefficients are printed as text. About 130 lines.

## Proof obligations to watch

- **floating point**: Gauss-Jordan elimination on Float needs range guards so intermediate products, quotients and sums provably stay finite, which the prover handles only with bounded input types.
- **division**: The pivot divisor must be shown nonzero, so the program tests the pivot magnitude against a small tolerance just before dividing and rejects a singular matrix visibly.
- **overflow**: Row operations are loop-carried float values that lose their bounds after the first iteration, so each update must be clamped by an explicit guard that rejects the input when a magnitude limit is exceeded.
- **index**: Pivot search and row swaps use for-loop indexes over fixed array ranges, so indexes are routine, but a while-loop pivot search needs a guard on its running index.
- **termination**: Elimination uses only for loops and procedures, so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, floating point, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, Put without a newline, 'Image of scalars, floating-point images and conditional expressions.

## External effects

- **console output** (allowed): Prints the input data and the fitted coefficients with Put_Line.

Assessed on 2026-10-15 against page revision 414351 of the [task](https://rosettacode.org/wiki/Multiple_regression) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
