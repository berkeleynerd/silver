# Deconvolution/1D

**Candidate: proofs plausibly discharge automatically.** Exact integer forward substitution replaces the floating-point approach, and every check follows from range subtypes, for-loop indexes and per-step magnitude guards, with no annotation required. The nonlinear multiply-accumulate in a loop and the text formatting need careful shape, hence plausible rather than likely.

Position 1099 in the [progression](../../../progression.md#stage-17), in stage 17.

## Approach

Use integer vectors (the task data are all integers) as constrained arrays of a ranged element subtype in a Long_Long_Integer-based type, with a deconv procedure taking g and f with lengths and producing h plus a status (ok, zero leading coefficient, inexact, magnitude limit). Forward substitution: for each n, start from g(n), subtract h(i)*f(n-i) over i from the guarded lower bound to n-1 with a magnitude guard each step, check f(0)/=0 and a zero remainder, then divide. Main embeds h, f and g, runs deconv(g,f) and deconv(g,h), compares with the originals, and prints each vector and the match result with Put/Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: The loop-carried accumulator is only known by its type, so each step guards its magnitude against a stated bound and rejects with a visible message, which keeps the product and subtraction in range.
- **division**: The divisor f(0) is checked nonzero immediately before dividing, with a visible rejection otherwise.
- **range**: Each computed h(n) is tested against the element subtype range before assignment, and a remainder not equal to zero yields a reported 'not exactly divisible' outcome instead of silent truncation.
- **index**: Indices n-i and n come from for-loop ranges over bounded constrained arrays, but the lower bound max(0, n-|f|+1) must be written as a guarded computation so the bounds are provable.
- **length**: Output lines are built in a bounded buffer sized for the largest vector, so Image concatenations need a fixed worst-case length bound.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, unconstrained arrays, for loops, procedures, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the f, g and h vectors and the verification results as text.

Assessed on 2026-10-15 against page revision 412008 of the [task](https://rosettacode.org/wiki/Deconvolution/1D) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
