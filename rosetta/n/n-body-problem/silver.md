# N-body problem

**Candidate: proofs plausibly discharge automatically.** Every array index follows from for loops over the arrays' own ranges, but the float arithmetic carried across steps needs a guard before each loop-carried operation, so the proofs hinge on careful program shape rather than annotations.

Position 1110 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Three bodies are held in fixed-size arrays of records with mass, position and velocity in bounded float subtypes, initialised from embedded data with 20 time steps. A for loop over steps calls procedures that compute accelerations with nested for loops over the array indexes, guard the squared distance before dividing, then update velocities and positions after checking the new values stay within the declared bounds. Each step prints the rounded values as text, and an out-of-bounds state ends the run with a visible rejection message. About 150 lines.

## Proof obligations to watch

- **floating point**: Accelerations, positions and velocities are floating-point values carried across steps, so each addition needs operands bounded by a ranged float subtype and a guard just before it, rejecting the run visibly if a bound would be exceeded.
- **division**: Dividing by distance cubed needs a guard that the squared distance is above a small positive minimum, with coincident bodies given the task's specified collision handling (swap velocities) rather than skipped silently.
- **overflow**: Squaring and cubing coordinate differences is nonlinear, so the provers need position bounds tight enough that the cube of the distance stays within the float range, which the guarded ranges supply.
- **floating point**: Square root must come from an admitted library operation with a contract on its input range, otherwise its result bound cannot be proved.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, floating point, floating-point images, 'Image of scalars, string building, Put without a newline, arrays, records, for loops, procedures, functions and conditional expressions.

## External effects

- **console output** (allowed): Prints each body's position and velocity for every time step.

Assessed on 2026-10-15 against page revision 409033 of the [task](https://rosettacode.org/wiki/N-body_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
