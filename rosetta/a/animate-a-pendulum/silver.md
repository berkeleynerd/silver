# Animate a pendulum

**Candidate: proofs plausibly discharge automatically.** Nothing in the task conflicts with the Oracle, because a text trace of a simulated pendulum meets the animation requirement, and the scaled-integer loop-carried state discharges only if each update is clamped or guarded, hence plausible rather than likely.

Position 164 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

The program holds the angle and angular velocity as scaled integers in ranged subtypes and runs a fixed number of Euler steps in a for loop, with the sine and cosine values taken from an embedded lookup table instead of floating-point functions. Each step updates velocity and angle, computes X and Y positions as scaled integers with explicit range guards, and prints one text line of positions as the animation frame. The animation is a fixed number of frames printed without real-time delay, since the task does not require wall-clock pacing. About 70 lines.

## Proof obligations to watch

- **overflow**: Use scaled-integer state (angle and velocity in milli-units) in ranged subtypes, and clamp each update step to the subtype range with a visible saturation rule.
- **range**: The Euler update carries angle and velocity through a fixed-count for loop, so each new value is computed in a wider intermediate type and guarded before narrowing.
- **index**: Sine and cosine are read from a precomputed, embedded lookup table indexed by an angle reduced into the table's range by a guard just before the access.
- **length**: Each output line is built in a fixed-capacity buffer sized for the largest scaled X and Y values, so the concatenation length is bounded.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, Put without a newline, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Each simulation step prints the pendulum's X and Y position as a line of text, which serves as the animation.

Assessed on 2026-10-15 against page revision 415044 of the [task](https://rosettacode.org/wiki/Animate_a_pendulum) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
