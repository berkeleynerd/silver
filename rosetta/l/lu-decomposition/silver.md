# LU decomposition

**Candidate: proofs plausibly discharge automatically.** All loops are for loops with bounded indexes in procedures, so indexes and termination are routine, but the loop-carried accumulations and scaled fixed-point products need careful range guards and decimal formatting is manual, so discharge is plausible rather than likely.

Position 847 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Matrices are fixed-capacity two-dimensional arrays (max order 4) of scaled-integer entries held in a bounded Long-range integer type, with a procedure Decompose doing pivot selection, row permutation recorded in P, and Doolittle/Crout loops with for loops only. Each multiplication and division is guarded by explicit range and nonzero-pivot checks leading to a printed rejection, and a Print procedure formats each entry to five decimals via integer division and mod with Put_Line/Put. Both example matrices are embedded as constant aggregates. About 150 lines.

## Proof obligations to watch

- **overflow**: Exact rational arithmetic would overflow with loop-carried numerators, so the program uses small integer matrices scaled to fixed-point (integer scaled by 100000) with each product range-guarded before use, and rejects with a visible outcome when a guard fails.
- **division**: The pivot divisor is checked non-zero by an explicit guard just before each division, and a singular matrix yields a printed rejection rather than an altered result.
- **index**: Pivot row search and row swaps use indexes of a ranged subtype over a fixed maximum order, so for-loop indexes over the array's own range discharge them.
- **overflow**: The accumulated sums in the inner K loops carry no invariant, so each addition needs a guard against the type bound, or the accumulator is a wide integer type whose range is shown to hold by bounding entries.
- **floating point**: Using true floating point would need range guards on every operand, so scaled integers are preferred, but this risks formatting 5-decimal outputs that must be built manually from integer parts.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, string building, 'Image of scalars, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints the A, L, U and P matrices for both examples.

Assessed on 2026-10-15 against page revision 414299 of the [task](https://rosettacode.org/wiki/LU_decomposition) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
