# Koch curve

**Candidate: proofs plausibly discharge automatically.** The task needs no floating point or recursion since the 60-degree lattice makes integer step vectors exact, and all loops are for loops over static bounds. The only non-routine checks are the loop-carried position and buffer length, which in-grid and capacity guards just before each use make dischargeable without annotations.

Position 816 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Build the Koch command string iteratively from an axiom with the rule F -> F+F--F+F in two fixed-capacity Character buffers, one expansion per for-loop pass. Then interpret it as a turtle on a triangular lattice with a heading in 0..5 and integer step vectors (no trig), plotting into a fixed 2D Character grid, with every move and every buffer append guarded. Finally print the grid row by row with Put_Line. About 100 lines.

## Proof obligations to watch

- **index**: The turtle position is a loop-carried value, so each plot and each move is guarded by an explicit in-grid test before indexing the character grid, with an out-of-grid step taking a visible outcome (stop and report) rather than being silently clipped.
- **range**: The heading is a subtype 0..5 updated with explicit wraparound guards (if heading = 5 then 0 else heading + 1) so no range check fails without an invariant.
- **overflow**: Rule expansion into a fixed-capacity command buffer is guarded by a length check before every append, and the fixed level (3 or 4) keeps the capacity a static bound.
- **termination**: All iteration uses for loops over static ranges (level expansion, command scan, grid printing), so no variant is needed and the work can sit in procedures.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, for loops, case statements, procedures, string building and Put without a newline.

## External effects

- **console output** (allowed): The curve is rendered as text art lines on standard output, which meets the draw requirement without a display.

Assessed on 2026-10-15 against page revision 414963 of the [task](https://rosettacode.org/wiki/Koch_curve) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
