# Pfaffian and hfaffian

**Candidate: proofs plausibly discharge automatically.** All checks follow from ranged entry types, fixed matrix bounds and guards, with no annotation needed, but the loop-carried 3.6-million-term sum and the index-heavy permutation stepping require careful guard placement.

Position 742 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed four integer matrices (2x2, 4x4, a symmetric 6x6, 10x10) in a bounded two-dimensional array of a ranged subtype, with an even-size check and an antisymmetry check that print a specified rejection message. A procedure enumerates permutations iteratively with next-permutation using while loops, accumulating the signed and unsigned products into guarded range-limited sums, then divides exactly by 2^n times n!. Results are printed with Put and Integer'Image. About 170 lines.

## Proof obligations to watch

- **overflow**: The running sum over up to 10! permutations is loop-carried, so each addition is guarded against a documented bound and an exceeded bound prints a visible overflow rejection instead of a result.
- **index**: The next-permutation steps move indexes with while loops in a procedure, and each index decrement is guarded by an explicit bound test before the array access.
- **termination**: The permutation enumeration is a while loop that must live in a procedure, since a function would need a variant annotation.
- **division**: The final division by 2^n times n! uses a constant nonzero divisor derived from the bounded half-size, so it discharges from the type range.
- **range**: Entries use a small ranged subtype with products of at most five entries and the sign taken from an inversion count, so the nonlinear products stay within a bounded accumulator type.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each embedded matrix, its Pfaffian and hafnian, or the rejection message for invalid matrices.

Assessed on 2026-10-15 against page revision 385310 of the [task](https://rosettacode.org/wiki/Pfaffian_and_hfaffian) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
