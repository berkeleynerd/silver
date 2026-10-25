# Elliptic curve arithmetic

**Candidate: proofs plausibly discharge automatically.** No annotations are needed because all loops are fixed-count for loops and each float operation can be guarded by magnitude and epsilon checks, but the proof depends on careful per-operation range guards in floating-point code, and the integer-only route is unavailable because y^2 = x^3 + 7 has no nonzero rational torsion or integer points.

Position 1097 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A Point record holds bounded-float x, y and an Is_Infinity flag; Double, Add, Negate and an optional bounded Multiply (double-and-add over a for loop of fixed bit count) are functions guarded against zero denominators and out-of-range magnitudes. Two points on y^2 = x^3 + 7 are built from fixed y values with a fixed-iteration Newton cube root, then their sum, its reflection and the check that P+Q+reflection is the infinity point (within tolerance) are printed through Put_Line with float image formatting. About 130 lines.

## Proof obligations to watch

- **floating point**: Float results must stay finite, so every operation is on a bounded subtype with a guard before it, and an out-of-range result takes a visible 'out of range' outcome.
- **division**: The slope divisions are preceded by explicit checks that the denominator's magnitude exceeds a small epsilon, with the vertical-line case returning the infinity point.
- **overflow**: Repeated doubling in the optional multiply function squares coordinate size, so the program bounds n small and rejects with a visible message when a coordinate leaves the allowed magnitude.
- **termination**: The Newton iterations that find a starting point (cube root or square root) use fixed-count for loops in procedures or functions, so no variant is needed.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, records, Boolean objects, functions, procedures, for loops, integers, conditional expressions and Put without a newline.

## External effects

- **console output** (allowed): Prints the two points, their sum, its reflection and the alignment check as text lines.

Assessed on 2026-10-15 against page revision 414178 of the [task](https://rosettacode.org/wiki/Elliptic_curve_arithmetic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
