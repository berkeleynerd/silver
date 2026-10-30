# Catenoid surface

**Candidate: proofs plausibly discharge automatically.** The task asks only to draw a catenoid and the text-art rendering meets it, so there is no Oracle conflict. The floating-point trigonometry and hyperbolic functions are the only non-routine proof burden, which a range-limited library or series keeps dischargeable without annotations.

Position 868 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The program fixes an angle grid (41 by 41) over u in -2..2 and v in 0..2*pi, computes each surface point with a bounded cosh and table-driven or series sin and cos, and projects it with a fixed rotation onto a 60x30 constrained character grid. Each point is written to the grid only after an explicit bounds guard, using a depth character chosen by height, then the grid rows are printed with Put_Line in a procedure. All loops are for loops over constants, so no loop-carried invariant is needed. About 90 lines.

## Proof obligations to watch

- **floating point**: cosh(u), Cos(v) and Sin(v) need an admitted bounded math library, or a hand-written Taylor series over a range-limited Float (u in -2..2), so that no overflow or NaN check can fail.
- **range**: Projected coordinates are converted to grid indices only after explicit guards that skip points falling outside the fixed 60x30 character grid, so the index checks discharge.
- **overflow**: Every float operand is bounded by the range of its subtype, so products and sums stay finite without needing a loop invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, floating point, arrays, multidimensional arrays, for loops, procedures, functions, Put without a newline, string building and case statements.

## External effects

- **console output** (allowed): The surface is rendered as a text-art depth map printed line by line to the console.

Assessed on 2026-10-15 against page revision 413975 of the [task](https://rosettacode.org/wiki/Catenoid_surface) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
