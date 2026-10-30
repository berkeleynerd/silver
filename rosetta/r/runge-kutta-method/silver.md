# Runge-Kutta method

**Candidate: proofs plausibly discharge automatically.** The task needs only a bounded for-loop over 100 steps, so termination is easy, but proving the Sqrt precondition and absence of float overflow on the loop-carried y depends on guards before each stage and on float prover strength, with no invariant available.

Position 1063 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Nested for loops over 10 whole-t blocks of 10 steps with t derived from the integer index, a pure Derivative function using Sqrt on a guarded nonnegative argument, and an RK4 step procedure that updates y; after each block it prints t, y and the absolute error against (t^2+4)^2/16 via a float-formatting library operation. Every stage argument is guarded, with a specified rejection outcome if y leaves its documented range. About 80 lines.

## Proof obligations to watch

- **floating point**: The loop-carried y is known only by its type, so each step guards y within a documented range (for example 0.0 to 1.0E6) before use and rejects otherwise, which keeps the Sqrt precondition and every multiplication and addition within Float range.
- **overflow**: The four-stage RK4 arithmetic discharges only if the guard bounds y, t (computed from the integer loop index, at most 10.0) and the stage intermediates tightly enough for the float provers.
- **range**: The intermediate stage values y + dy/2 must be shown nonnegative before each Sqrt, requiring explicit guards on each stage that reject on failure rather than clamp.
- **other**: Float image formatting of t, y and error must be done with a fixed-capacity library or hand-built digit conversion whose own contracts must discharge.

## Language surface recorded by this assessment

Floating point, floating-point images, integers, integer division, ranged subtypes, for loops, functions, procedures, Boolean objects, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints eleven lines of t, y and error at whole-number t.

Assessed on 2026-10-15 against page revision 413895 of the [task](https://rosettacode.org/wiki/Runge-Kutta_method) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
