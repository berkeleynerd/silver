# Particle fountain

**Candidate: proofs plausibly discharge automatically.** Everything is integer fixed-point arithmetic over declared ranges with bounds guards before each array index and only for loops in procedures, so no annotation is needed. Plausible rather than likely because many loop-carried position and velocity values each need a clamp or guard to stay in range.

Position 1305 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

The program keeps 2000 particles in fixed-size arrays of integer fixed-point x, y, vx and vy components, using a modular-type linear congruential generator for the spread of launch velocities. A bounded for loop runs a few dozen frames, each emitting a batch of particles at a wrapping index, applying gravity to the velocities, advancing positions, and respawning particles that leave a bounded grid. At selected frames it renders the particles to a 2D Character grid, guarding each coordinate before indexing, and prints the rows with Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: Position and velocity updates carry values through loops, so they use integer subtypes with clamping or respawn guards such as resetting a particle that leaves the grid.
- **range**: The deterministic generator state and its scaled outputs use a modular type or a bounded modulo so every derived velocity stays within the declared subtype.
- **index**: Particle coordinates index the text-art grid only after explicit bounds guards, and the emit index wraps with mod over the array length.
- **termination**: All loops are for loops or live in procedures, so the frame loop is a bounded for loop and no function carries a while loop.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, for loops, while loops, procedures, string building, 'Image of scalars, Put without a newline and modular types.

## External effects

- **console output** (allowed): The program prints a text-art frame or a coordinate listing of the fountain's particles.

Assessed on 2026-10-15 against page revision 414975 of the [task](https://rosettacode.org/wiki/Particle_fountain) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
