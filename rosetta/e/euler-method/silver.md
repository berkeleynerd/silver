# Euler method

**Candidate: proofs plausibly discharge automatically.** Everything is bounded by static for-loop ranges and a range-constrained float subtype, so no annotation is needed, but proving float updates stay in range and relying on an admitted exp and float formatting makes discharge depend on careful program shape.

Position 1054 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Define a bounded float subtype for temperature, a Euler_Step function computing y + h*f(t,y) for the cooling law, and a procedure that loops over a step-size table (2, 5, 10) and over step counts 0..100/h with for loops. Each row prints the integer time, the Euler value and the analytical value via an admitted exponential, with Put_Line for output. Step counts and times are bounded integer ranges so all indexing and arithmetic follows from types. About 70 lines.

## Proof obligations to watch

- **floating point**: The temperature is a range-constrained float subtype (for example -1000.0 to 1000.0) so each Euler update y + h*(-k*(y-20)) is bounded by interval reasoning for h of 2, 5 and 10 without an invariant, though float provers may need that shape.
- **range**: The loop-carried temperature is known after the first iteration only by its subtype, so the update must provably land inside that subtype, which holds because the contraction factor (1 - h*k) has magnitude below 1 for the chosen steps.
- **floating point**: The analytical value T_R + (T_0 - T_R)*exp(-k*t) needs an admitted exponential with a verified contract and an argument bounded to -7.0..0.0 by the for-loop range of t.
- **overflow**: Time is an integer for-loop index from 0 to 100 stepping by the step size via a count loop (t = i*h with i bounded), so integer multiplication is bounded by static ranges.
- **length**: Float formatting into a fixed-capacity buffer needs a documented maximum width and a library routine with specified length behavior.

## Language surface recorded by this assessment

Floating point, ranged subtypes, integers, integer division, for loops, procedures, functions, 'Image of scalars, floating-point images, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints a table of time, Euler approximation and analytical value for each of the three step sizes.

Assessed on 2026-10-15 against page revision 415418 of the [task](https://rosettacode.org/wiki/Euler_method) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
