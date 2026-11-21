# Deconvolution/2D+

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic over fixed-size arrays with for loops in procedures, so checks follow from ranged types and explicit guards before each accumulation, division and assignment, but the many loop-carried sums and shifted indexes need careful guard placement.

Position 1540 in the [progression](../../../progression.md#stage-32), in stage 32.

## Approach

Use integer 3D constrained arrays with embedded g, f and expected sizes (floating point is unnecessary since the data are integers and the system is triangular), and a procedure Deconv that solves for each h element in lexicographic order by subtracting already-known contributions from g and dividing exactly by f(0,0,0), rejecting if the pivot is zero, division is inexact or values leave bounds. Run it twice (g,f gives h; g,h gives f), then recompute the convolution in a verification procedure and print the arrays row by row with a Valid flag, with a visible rejection message otherwise. All loops are for loops inside procedures. About 130 lines.

## Proof obligations to watch

- **overflow**: Accumulated sums of f*h products in loops carry only their type range, so each term is added under a guard that rejects when the running sum leaves a declared bound (values are ranged subtypes so products fit in 64 bits).
- **division**: Dividing by the pivot f(0,0,0) is preceded by an explicit zero test that rejects, and exact divisibility is checked via rem so inexact results are rejected rather than rounded.
- **range**: Each recovered element is a loop-carried computed value stored into a ranged element type, so an explicit bounds guard before assignment rejects out-of-range results.
- **index**: Shifted indexes such as i+a or i-a are guarded by comparisons against the constant array bounds just before use, and the dimension sizes of h are fixed constants derived from g and f.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, procedures, 'Image of scalars, string building, Put without a newline and membership tests.

## External effects

- **console output** (allowed): Prints the two recovered 3D arrays (h from g and f, f from g and h) as rows of integers.

Assessed on 2026-10-15 against page revision 414149 of the [task](https://rosettacode.org/wiki/Deconvolution/2D%2B) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
