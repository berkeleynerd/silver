# Berlekamp–Massey algorithm

**Candidate: proofs plausibly discharge automatically.** The algorithm is bounded nested for loops over fixed arrays with GF(2) arithmetic, so every check follows from types and index guards, though the loop-carried L and shift offsets need careful guards without invariants. The optional nth-term computation is omitted.

Position 230 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

The 7-element binary sequence is embedded as a constant array, and C, B and a temporary copy are fixed-capacity arrays of 0..1 coefficients with a capacity of 16. A for loop over the sequence computes the discrepancy with an inner for loop with guarded indices, updates C from B using shifted for loops, and adjusts L, m and B per the standard algorithm in a procedure. The result is printed as a line built from the coefficients up to L. About 70 lines.

## Proof obligations to watch

- **index**: Coefficient indices like i-1-j and i-L-1 are loop-carried, so each array access is guarded by an explicit range test just before use, with C and B held in fixed-capacity arrays of ranged index subtypes.
- **range**: The linear complexity L and shift m change inside the loop without an invariant, so they are typed as subtypes bounded by the sequence capacity and each update is guarded to stay within that bound.
- **overflow**: All coefficients and discrepancies are GF(2) values in 0..1 with mod 2 applied, so sums of at most capacity-many products stay far below the Integer limit.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the resulting connection polynomial coefficients as text lines.

Assessed on 2026-10-15 against page revision 414072 of the [task](https://rosettacode.org/wiki/Berlekamp%E2%80%93Massey_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
