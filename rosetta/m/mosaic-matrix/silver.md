# Mosaic matrix

**Candidate: proofs likely to discharge automatically.** Row+Col lies in 2..16 and divisor 2 is nonzero. No array, declared subtype, mutable object or scalar refinement is needed; each output is a bounded literal.

Position 30 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main fixes Side : constant Integer := 8 and nests Row and Col loops over 1 .. Side. If ((Row + Col) mod 2)=0 it writes "1 " with Put, otherwise ". "; an empty Put_Line ends each row. This is the task's fixed 8-by-8 alternating text grid. About 19 lines.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic, interval-checked Integer division and Put without a newline.

## External effects

- **console output** (allowed): The matrix is drawn as text art on standard output, which the task's GUI request does not require.

Initially assessed on 2026-10-15 against page revision 399918 of the [task](https://rosettacode.org/wiki/Mosaic_matrix) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-division-20261025.md).
