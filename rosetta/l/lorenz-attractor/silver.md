# Lorenz attractor

**Candidate: proofs plausibly discharge automatically.** Fixed-iteration for loops, fixed grid bounds and guarded float steps mean every check follows from types or a guard just before the use, but the floating-point Euler recurrence needs careful magnitude guards because no loop invariant can be written. No annotations or recursion are needed, so discharge is plausible rather than certain.

Position 911 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

The program holds X, Y, Z as Float and integrates the Lorenz equations (sigma 10, rho 28, beta 8/3) with a fixed-step Euler loop of a few thousand iterations in the main procedure, with a magnitude guard before each step. Each step projects (X, Z) onto a fixed-size character grid, marks the cell with a star only when the scaled coordinates are in range, and finally prints each grid row with Put_Line. Embedded constants set the start point, step size and grid dimensions. About 55 lines.

## Proof obligations to watch

- **floating point**: The Euler step state X, Y, Z is loop-carried with only its type known, so each step is preceded by a magnitude guard that stops the run with a visible message if any value leaves a bound, which lets the float overflow and finiteness checks on the products discharge.
- **range**: Converting the float position to a grid column or row needs a guard that the scaled value lies within the grid range, and out-of-range points are skipped without altering the plotted result of in-range points.
- **overflow**: Nonlinear products such as X*(Rho-Z) need the operand bounds from the guard to be strong enough that the provers show no float overflow.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, floating point, multidimensional arrays, string indexing, for loops, procedures and conditional expressions.

## External effects

- **console output** (allowed): The attractor is rendered as text art and printed line by line, which satisfies the task's image requirement without a display.

Assessed on 2026-10-15 against page revision 414966 of the [task](https://rosettacode.org/wiki/Lorenz_attractor) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
