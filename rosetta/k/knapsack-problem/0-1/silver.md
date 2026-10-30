# Knapsack problem/0-1

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-bound for loops over constant arrays with fixed data, so indexes and termination are routine, and the only non-routine check is the loop-carried sum bound, which a visible guard with a Reject outcome can handle without annotations.

Position 815 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

Embed item weights and values as constant arrays of a ranged subtype (22 items), fill a 23 by 401 table with nested for loops using a guarded Weight > J test, then backtrack with a reverse for loop recording a Taken Boolean array and subtracting weights only after a comparison. Print totals with 'Image and print each chosen name via a procedure with a case statement over the item index, with all of it in a single procedure Main. About 110 lines.

## Proof obligations to watch

- **overflow**: The DP cell sum of a loop-carried table value and an item value is only bounded by the cell subtype, so a visible guard before storing (rejecting anything above the 1272 total of all values) is needed.
- **range**: The Weight-indexed lookup W(I-1, J-Weight) and the backtrack subtraction Rest - Weight are each protected by an explicit comparison placed just before the use.
- **index**: All table indexes come from for-loop ranges over constant bounds (1..22, 0..400) so they discharge, though the 2D array write inside nested loops adds some solver load.
- **initialization**: The 23 by 401 table is fully initialized by an aggregate with others so flow analysis is routine.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, case statements, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints total weight, total value and the names of the chosen items.

Assessed on 2026-10-15 against page revision 415486 of the [task](https://rosettacode.org/wiki/Knapsack_problem/0-1) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
