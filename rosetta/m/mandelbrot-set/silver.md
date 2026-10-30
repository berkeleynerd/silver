# Mandelbrot set

**Candidate: proofs plausibly discharge automatically.** The task only asks for the set to be generated and drawn, so text art satisfies it, and an integer fixed-point iteration with an escape guard and a constant iteration cap keeps every check dischargeable without annotations. The nonlinear arithmetic on loop-carried values makes it plausible rather than likely.

Position 450 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Render a fixed-size (for example 60x24) text-art picture of the set into console output using scaled-integer fixed-point arithmetic in place of Float, so that the overflow checks follow from bounded subtypes. For each pixel a procedure runs a bounded while loop (iteration count at most a constant maximum) that squares the complex value, exits as soon as the squared magnitude exceeds 4.0 scaled, and then selects '*' or ' ' for the pixel. Each row is built in a fixed-length String buffer and written with Put_Line, so no unbounded structures are needed. About 60 lines.

## Proof obligations to watch

- **overflow**: Fixed-point integer arithmetic (scaled by 2**12 or similar) on loop-carried x and y is discharged by escape-test guards that stop iteration once x*x+y*y exceeds 4 and by operand types bounded to roughly +-4.0 scaled, so the products fit in 64 bits.
- **range**: The new x and y values assigned inside the while loop must be proven within their subtype after each update, which needs a guard or clamp placed immediately before the assignment, and the clamp is safe because it only applies after escape, where the pixel is already classified as outside.
- **division**: The scaling divisions use only positive constant divisors, so they discharge trivially.
- **termination**: The iteration loop is a while loop with an iteration counter bounded by a constant, which is allowed in a procedure since procedures get no termination check, and it is kept out of functions.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, for loops, while loops, procedures, string building and Put without a newline.

## External effects

- **console output** (allowed): The program emits the rendered set as lines of text art on standard output.

Assessed on 2026-10-15 against page revision 415498 of the [task](https://rosettacode.org/wiki/Mandelbrot_set) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
