# Steffensen's method

**Candidate: proofs plausibly discharge automatically.** Everything is bounded floating-point arithmetic in a procedure-driven loop with explicit guards for the Aitken denominator and divergence, so no annotation is needed, but proving float overflow and division freedom through the loop-carried iterate depends on careful guard placement and float provers.

Position 1101 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Use a bounded Long_Float subtype for the iterate, small functions for de Casteljau, the implicit equation, f(t) and one guarded Aitken step, and a procedure with a while loop (counter up to 1000, tolerance 1e-8) that returns a found flag and the value, treating a zero or tiny denominator or a diverged iterate as no answer. A for loop over 0..10 computes t0 = I/10, then prints no answer, spurious solution (implicit residual above 1e-6) or the point (x, y) formatted by scaling to integers and building the decimal text by hand. About 120 lines.

## Proof obligations to watch

- **floating point**: Every float operation in de Casteljau, the implicit equation and Aitken's step must be proved free of overflow, so the iterate is held in a bounded float subtype and the Aitken step is only taken when it is guarded to stay within that bound.
- **division**: The Aitken denominator p2 - 2*p1 + p0 can be zero or tiny, so the program guards on its magnitude before dividing and reports no answer for that start, a visible specified outcome.
- **overflow**: The loop-carried iterate p has only its subtype range after the first iteration, so a divergence guard (magnitude above a fixed bound reports no answer) keeps the cubic and quartic terms within float range, and the provers must handle the nonlinear products.
- **termination**: The Steffensen iteration is a while loop with an iteration counter, which is acceptable only because it lives in a procedure (no termination check), with the Aitken step as a function containing no loops.
- **floating point**: Float-to-integer conversion for printing needs the scaled value range-guarded, and the tolerance comparisons must not hide NaN or infinity, which the bounded subtype and guards exclude.

## Language surface beyond today's Silver

Floating point, ranged subtypes, integers, Boolean objects, for loops, while loops, procedures, functions, conditional expressions, floating-point images, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints one result line per initial estimate: no answer, spurious answer, or the intersection point.

Assessed on 2026-10-15 against page revision 414739 of the [task](https://rosettacode.org/wiki/Steffensen's_method) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
