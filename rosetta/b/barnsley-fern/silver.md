# Barnsley fern

**Candidate: proofs plausibly discharge automatically.** Every check follows from a closed float subtype range, a modular generator and explicit index guards, with no annotations, but floating-point range reasoning and float-to-integer conversion make discharge depend on careful program shape.

Position 1294 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

The program keeps a fixed grid of rows (for example 40 by 60 characters) initialised to spaces, iterates a fixed 100000 times with a modular linear congruential generator choosing one of the four affine maps by percentage thresholds in an if/elsif chain, and marks the grid cell for each point after guarding the scaled indexes against the grid bounds. Coordinates are floats in a bounded subtype closed under all four maps. Afterwards a for loop prints each row with Put_Line. About 70 lines.

## Proof obligations to watch

- **floating point**: X and Y are loop-carried, so they are declared with a subtype range of -100.0 .. 100.0 which the four affine maps provably map into itself (largest result about 90.6), letting range and overflow checks discharge without an invariant.
- **range**: Converting scaled coordinates to grid column and row indexes needs a guard that tests the computed values against the grid bounds just before indexing, so a point outside the grid is visibly skipped rather than checked by proof.
- **overflow**: The pseudo-random generator uses a 32-bit modular type so wraparound is defined behavior, and the percentage is derived by mod 100 on the modular value.

## Language surface recorded by this assessment

Floating point, ranged subtypes, modular types, integer division, integers, characters, arrays, multidimensional arrays, string building, string indexing, for loops and procedures.

## External effects

- **console output** (allowed): The fern is rendered as text art rows written with Put_Line, which meets the task without a display.

Assessed on 2026-10-15 against page revision 415040 of the [task](https://rosettacode.org/wiki/Barnsley_fern) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
