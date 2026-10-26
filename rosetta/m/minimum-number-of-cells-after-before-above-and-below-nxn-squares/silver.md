# Minimum number of cells after, before, above and below NxN squares

**Candidate: proofs likely to discharge automatically.** The current fragment computes the required 10x10 grid with two finite Integer loops and one mutable Integer range 0..9 object. All subtraction intervals and assigned values lie in 0..9; the actual minima lie in 0..4, but admission does not need scalar guard refinement, a named subtype, Natural or a minimum library operation.

Position 36 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Declare M : Integer range 0 .. 9 := 0. For each I and J in 1 .. 10, assign M := (I - 1), then compare and replace M successively with (10 - I), (J - 1) and (10 - J) whenever the candidate is smaller. This computes min(I-1,10-I,J-1,10-J), the minimum cells between that cell and any grid edge. Put(Integer'Image(M)) emits each one-digit entry with a leading space; Put_Line("") ends each of ten rows. Each RHS independently fits the full declared 0..9 range, so branch refinement and a loop invariant are unnecessary. About 22 lines.

## Language surface recorded by this assessment

Bounded mutable Integer objects, immutable Integer arithmetic, Integer range for loops, Put without a newline and Integer image.

## External effects

- **console output** (allowed): Prints the 10x10 grid of minimum distances to the edge, one row per line.

Initially assessed on 2026-10-15 against page revision 406018 of the [task](https://rosettacode.org/wiki/Minimum_number_of_cells_after,_before,_above_and_below_NxN_squares) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-reconciliation-20261025.md).
