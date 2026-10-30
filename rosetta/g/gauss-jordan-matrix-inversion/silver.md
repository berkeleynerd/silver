# Gauss-Jordan matrix inversion

**Candidate: proofs plausibly discharge automatically.** All indexes and loop bounds are static and the program is a procedure with only for loops, so the only non-routine obligations are float overflow and zero-pivot division, which explicit magnitude guards with a visible reject outcome can discharge without annotations. Float arithmetic in nested loops and float formatting make it plausible rather than likely.

Position 1075 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A fixed 3x3 (constant N) example matrix is embedded and copied into an augmented N by 2N array of a bounded Long_Float subtype; for each column a for loop picks the largest-magnitude pivot row, rejects if it is near zero, swaps rows, normalizes the pivot row and eliminates that column from all other rows, with magnitude guards before each arithmetic step. The right half is printed row by row using a float-to-text routine, with a printed rejection message for singular or out-of-range input. About 100 lines.

## Proof obligations to watch

- **floating point**: Every multiply, subtract and divide on loop-carried matrix entries is guarded by magnitude tests (for example absolute value at most 1.0E100 before use), and an out-of-range entry rejects the input with a visible message.
- **division**: The pivot is searched by partial pivoting and a pivot of magnitude below a small threshold is reported as a singular matrix before dividing.
- **index**: All indexes are for-loop variables over a fixed constrained subtype range, or a pivot row variable of that subtype, so they discharge.
- **overflow**: Loop-carried float values only carry their type range after the first iteration, so each guard must be placed immediately before the operation rather than relying on earlier checks.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, floating point, multidimensional arrays, for loops, procedures, floating-point images, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): The original and inverted matrices are printed as text lines.

Assessed on 2026-10-15 against page revision 413731 of the [task](https://rosettacode.org/wiki/Gauss-Jordan_matrix_inversion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
