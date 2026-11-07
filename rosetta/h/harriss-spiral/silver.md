# Harriss Spiral

**Candidate: proofs plausibly discharge automatically.** The task is a picture with no window requirement, so text art satisfies it, and integer-scaled geometry with grid-bounds guards keeps all checks routine apart from bounded fixed-point multiplication and the explicit-stack subdivision.

Position 833 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Use integer-scaled geometry (rectangle edge lengths divided by a fixed-point plastic ratio) with a fixed-depth subdivision, driven by an explicit stack array and for loops in procedures instead of recursion. Squares and their quarter-circle arcs are rasterised into a fixed-size character grid using an integer-only arc approximation (stepped points via a precomputed small sine/cosine table), guarded by bounds tests before each plot, then the grid rows are printed with Put_Line. Floating point is avoided entirely. About 130 lines.

## Proof obligations to watch

- **overflow**: Scaled fixed-point integer geometry (ratio approximated as 1324718/1000000) is multiplied in loops, so every operand must be bounded by a range-limited subtype with clamping guards.
- **index**: Plotted pixel coordinates are loop-carried values, so each is guarded by an explicit in-bounds test before writing to the character grid, with out-of-range points skipped visibly as clipped.
- **termination**: Arc and subdivision traversal is done with bounded for loops over a fixed iteration depth and an explicit work stack array in a procedure, avoiding recursion.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, for loops, while loops, procedures, case statements, Put without a newline and string building.

## External effects

- **console output** (allowed): The spiral is rendered as text art written to standard output.

Assessed on 2026-10-15 against page revision 414654 of the [task](https://rosettacode.org/wiki/Harriss_Spiral) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
