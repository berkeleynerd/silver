# Particle swarm optimization

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-bound for loops over constant array ranges with no recursion, so only the floating-point range bounds and elementary-function contracts are non-routine, making discharge plausible but dependent on careful float subtypes.

Position 1519 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

Use fixed-size constrained arrays (1000 particles by 2 dimensions) of a bounded float subtype for positions, velocities and personal bests, with a modular LCG supplying deterministic pseudo-random numbers. Two pure objective functions (McCormick and Michalewicz) take a two-element array, and one swarm-iteration procedure runs for loops over particles and dimensions, reseeding any particle that leaves the bounds. Main runs 40 and 30 iterations respectively and prints the best position and value for each case. About 170 lines.

## Proof obligations to watch

- **floating point**: Velocity and position updates accumulate in loop-carried floats with no invariant, so they must be clamped to declared finite float subtypes with a visible reset to avoid overflow checks failing.
- **floating point**: Sin from an admitted elementary-functions library and the 20th power in Michalewicz need bounded arguments, which holds only if the library's contract bounds Sin to [-1,1] or a guard is added.
- **overflow**: The deterministic generator is a modular LCG whose wraparound is by type, with a bounded division to a float in [0,1), which is routine.
- **index**: All loops run over constant particle and dimension ranges, so indexing is by the arrays' own ranges and is routine.

## Language surface beyond today's Silver

Floating point, arrays, multidimensional arrays, records, for loops, procedures, functions, ranged subtypes, integers, integer division, modular types, exponentiation, floating-point images, 'Image of scalars, string building, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints the test function name, iteration count, global best position and value for each of the two test cases.

Assessed on 2026-10-15 against page revision 414383 of the [task](https://rosettacode.org/wiki/Particle_swarm_optimization) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
