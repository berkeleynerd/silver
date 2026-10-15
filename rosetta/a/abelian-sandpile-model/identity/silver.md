# Abelian sandpile model/Identity

**Candidate: proofs plausibly discharge automatically.** Every check is on small fixed-bound arrays with guards before each increment and index, and the only unbounded loop is in a procedure, so no annotation is needed, but the loop-carried cell counts mean the guards must be placed carefully.

Position 729 in the [progression](../../../progression.md#stage-14), in stage 14.

## Approach

The program uses a 3 by 3 constrained two-dimensional array of a bounded cell subtype, with embedded s1, s2, s3, s3_id and the avalanche start pile as aggregates. A Topple procedure scans for the first cell holding at least four, subtracts four, adds one to each in-bounds neighbour after a bound guard, and a while loop in a Stabilise procedure repeats until a function Is_Stable (for loops) returns true. An Add function sums cell by cell, stabilises through a procedure, and Main prints each pile with Put and Integer'Image and compares piles with built-in array equality to print the confirmations. About 130 lines.

## Proof obligations to watch

- **overflow**: Cell counts are carried through the toppling loop, so each increment of a neighbour is guarded by a comparison against the cell type's upper bound with a visible Reject outcome, and the subtraction of four is guarded by the cell being at least four.
- **range**: Cells use a bounded integer subtype and assignments from sums or differences are only safe because of the guards immediately before them, since no invariant carries bounds across iterations.
- **termination**: Stabilisation uses a while loop that lives in a procedure, which gets no termination check, so no variant is needed.
- **index**: Neighbour indexes are checked against the grid bounds by explicit if tests just before each access, and the scan loops run over the array's own ranges.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the avalanche steps, stable sums and equality confirmations as text.

Assessed on 2026-10-15 against page revision 414049 of the [task](https://rosettacode.org/wiki/Abelian_sandpile_model/Identity) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
