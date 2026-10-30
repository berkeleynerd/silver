# Rodrigues’ rotation formula

**Candidate: proofs plausibly discharge automatically.** The program is a short straight-line floating-point computation with no loops or recursion, so termination is trivial, but overflow, division, sqrt and arccos domain checks each need explicit guards and bounded component subtypes, plus an admitted elementary-functions library with verified contracts.

Position 1062 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A record of three bounded Float components with functions for dot product, cross product, norm, normalize and rotate, applied to embedded constant vectors. Guards check the norm is above epsilon before dividing and that the arccos argument lies in range before calling, otherwise printing a rejection message. Results are converted to scaled integers and printed with Put_Line. About 80 lines.

## Proof obligations to watch

- **floating point**: Sqrt, Arccos, Sin and Cos need bounded operands, so components use a constrained float subtype and a guard requires the norm to exceed a small epsilon, with rejection as a visible outcome.
- **overflow**: Products and sums of components stay in range only if components are a bounded float subtype such as -1000.0..1000.0.
- **division**: Normalize and Angle divide by norms, so each division is preceded by an explicit nonzero-norm guard that rejects degenerate axes.
- **range**: Arccos needs its argument within -1.0..1.0, which rounding can violate, so the ratio is checked or clamped before the call with a visible outcome.
- **other**: Output formatting converts floats to scaled integers printed as fixed decimals, which adds rounding and range checks.

## Language surface recorded by this assessment

Floating point, records, functions, ranged subtypes, floating-point images, string building, integers and integer division.

## External effects

- **console output** (allowed): Prints the source vector, target vector and rotated result as text lines.

Assessed on 2026-10-15 against page revision 391136 of the [task](https://rosettacode.org/wiki/Rodrigues%E2%80%99_rotation_formula) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
