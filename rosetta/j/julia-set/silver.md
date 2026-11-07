# Julia set

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded subtypes, constant loop bounds and an explicit escape guard placed before each store, so no annotation is needed, but the loop-carried fixed-point arithmetic needs careful shaping, hence plausible rather than likely.

Position 461 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The program uses scaled integer fixed-point (scale 4096) with a bounded subtype for the z components, and nested for loops over a fixed 64 by 32 grid of pixel coordinates mapped to the complex plane by integer arithmetic. An inner iteration loop (up to 50 steps) computes z squared plus the constant c in a wide integer type, guards the result against the bounded range and the escape radius, and exits when the point escapes. Each row is built in a fixed-length String buffer of characters chosen by escape iteration count and printed with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: Fixed-point squaring and the constant addition are computed in a wide integer type from operands held in a bounded subtype, and the new value is range-guarded before being stored, so the check discharges from types and guards.
- **range**: The loop-carried z components are held in a bounded subtype and a point whose next value would leave that range is classified as escaped by an explicit guard just before the assignment, which does not change the rendered result.
- **floating point**: Scaled integer arithmetic replaces floating point so the provers deal only with bounded integer multiplication and division by a constant.
- **index**: Row buffer positions are for-loop indexes over the buffer's own range and the iteration count maps to a character through a clamped table index, so the check is routine.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The Julia set is rendered as text art lines on standard output, which meets the draw requirement without a window.

Assessed on 2026-10-15 against page revision 415466 of the [task](https://rosettacode.org/wiki/Julia_set) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
