# Gradient descent

**Candidate: proofs plausibly discharge automatically.** Nothing needs an annotation, but proof depends on floating-point Exp and Sqrt having bounded results and on guards that keep the iterates in a box, which makes discharge plausible rather than routine.

Position 1055 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Keep x, y and the step size alfa as bounded Float variables inside a procedure; a loop capped at a fixed iteration count computes the analytic gradient, its norm and the step, exiting when the norm is within tolerance. Each step is guarded on the norm being nonzero and the new x and y staying within a declared box, otherwise it prints a divergence message; alfa is halved whenever f increases, as in the reference. Finally it prints x, y and f(x, y) using float image. About 70 lines.

## Proof obligations to watch

- **floating point**: Exp, Sqrt and the products in f and its gradient need bounded operands and a bounded Exp result, so x and y live in a bounded float subtype and an admitted library Exp must carry a range contract for the overflow checks to discharge.
- **range**: The loop-carried x and y are updated each step, so a guard before each assignment checks the new value stays in the allowed box and otherwise stops with a visible 'diverged' message.
- **division**: The step alfa/norm divides by the gradient norm, which is guarded by testing norm is above a small positive epsilon (norm at or below tolerance means converged) just before the division.
- **termination**: The descent runs in a procedure with an explicit iteration cap, so no termination check applies and non-convergence has a specified outcome.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, Boolean objects, functions, procedures, for loops, while loops and integers.

## External effects

- **console output** (allowed): Prints the located minimum x, y and f(x, y) as text lines.

Assessed on 2026-10-15 against page revision 415205 of the [task](https://rosettacode.org/wiki/Gradient_descent) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
