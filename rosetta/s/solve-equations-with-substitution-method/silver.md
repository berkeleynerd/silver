# Solve equations with substitution method

**Candidate: proofs likely to discharge automatically.** Exact singleton initialization gives denominator 11 and numerator -22, then x=-2 and y=5. The nonzero divisor and all intermediate ranges follow directly from those exact values; no declared subtype, guard narrowing or general solver procedure is required.

Position 40 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main embeds the task's fixed equations 3*x+y=-1 and 2*x-3*y=-19 as Integer constants. Ordered grouped constant expressions compute Denominator := (A2 - (B2 * A1)), Numerator := (R2 - (B2 * R1)), X := (Numerator / Denominator) and Y := (R1 - (A1 * X)). Put_Line prints X and Y with ordinary Integer'Image. This solves those equations, without claiming a general linear-system API. About 21 lines.

## Language surface recorded by this assessment

Immutable Integer arithmetic, interval-checked Integer division and Integer image.

## External effects

- **console output** (allowed): Prints the solved values of x and y as text lines.

Initially assessed on 2026-10-15 against page revision 407798 of the [task](https://rosettacode.org/wiki/Solve_equations_with_substitution_method) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-division-20261025.md).
