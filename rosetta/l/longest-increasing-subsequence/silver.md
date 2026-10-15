# Longest increasing subsequence

**Candidate: proofs plausibly discharge automatically.** All loops are for loops in a procedure so no termination or variant issue arises, and the only non-routine checks are loop-carried Best lengths and the Pred index chain, which explicit guards can discharge without annotations. Text building of the printed lists adds some bounded-buffer length checks.

Position 1011 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Two constant Integer arrays are embedded, and a procedure computes Best and Pred tables with nested for loops over the array range (O(n^2) DP), then finds the best tail and traces back through Pred into an output array, with explicit guards on index zero and on length limits. The result is rendered into a bounded text buffer using Integer'Image and printed with Put_Line, or element-wise with Put and a final Put_Line. About 80 lines.

## Proof obligations to watch

- **overflow**: The length table Best(J)+1 is a loop-carried value that stays in range only with a guard against a documented maximum length, or via a Best subtype bounded by the array capacity.
- **index**: The predecessor chain walk uses a loop-carried index Pred(Best_Idx) that may be 0 by type, so each Seq(Best_Idx) access needs an explicit guard Best_Idx >= 1 with a visible stop.
- **length**: The output line is assembled in a fixed-capacity buffer sized for the maximum sequence length, with a visible rejection if it would overflow.
- **range**: Assigning Pred(I) := J and Best_Idx from loop-carried values depends on subtypes of the index range, which discharges only with constrained subtypes.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, unconstrained arrays, for loops, procedures, string building, 'Image of scalars, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints the two longest increasing subsequences as text lines.

Assessed on 2026-10-15 against page revision 414313 of the [task](https://rosettacode.org/wiki/Longest_increasing_subsequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
