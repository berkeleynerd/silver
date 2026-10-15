# Strassen's algorithm

**Candidate: proofs plausibly discharge automatically.** Fixed-size integer matrices with unrolled two-level Strassen need only static bounds and a declared entry range for overflow, so all checks are routine for provers and no annotations are required. The main care points are the nonlinear products (bounded by the range subtype) and the task's recursion, which must be expressed as fixed-depth unrolling rather than a general recursive routine.

Position 752 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Represent matrices as constrained 2D arrays of a ranged integer subtype, with fixed 2x2 and 4x4 types and procedures that add, subtract, naively multiply, split into quadrants and recombine. A 2x2 Strassen procedure uses the seven products on scalars, and a 4x4 Strassen procedure splits into 2x2 blocks and calls the 2x2 procedure seven times, which unrolls the recursion into a fixed two-level depth; embedded example matrices are multiplied both ways and printed with Put_Line of integer images. About 170 lines.

## Proof obligations to watch

- **overflow**: Strassen's sums and products of sub-matrix entries are bounded only by declaring a small entry range (for example -1000..1000) and fixed 4x4 inputs, so each intermediate stays well inside Integer.
- **termination**: Recursion is avoided by unrolling the levels into procedures for 4x4 (using 2x2 blocks) and 2x2 (using scalars), so no variant is needed.
- **index**: Quadrant copy loops use for-loops over fixed constrained ranges with offsets of constant size, so index checks follow from static bounds.
- **floating point**: Using exact Integer matrices (the task's inverse example D can be replaced by an integer permutation or identity pair) avoids floating point entirely.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, for loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the product matrices computed by standard and Strassen multiplication.

Assessed on 2026-10-15 against page revision 414519 of the [task](https://rosettacode.org/wiki/Strassen's_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
