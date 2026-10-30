# Wave function collapse

**Candidate: proofs plausibly discharge automatically.** All arrays, tile indices and the LCG are bounded by declared ranges and explicit guards, and the collapse loop can be a fixed-count for loop in a procedure, so no annotation is needed, but the many loop-carried counters and computed indices make discharge depend on careful program shape.

Position 742 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the five 3x3 blocks as a constant 3-D array of 0/1 pixels, precompute horizontal and vertical compatibility tables between block pairs, and keep an 8x8 array of ranged assigned-block indices with 5 meaning unassigned. A for loop runs 64 times, each time computing every unassigned cell's allowed set from its four wrapped neighbours (indices via ranged mod arithmetic), choosing minimum entropy, and picking among candidates with a bounded LCG; zero entropy prints a specified failure message and stops. Finally the 17x17 tile is assembled into a fixed 2-D array of characters (overlapping border pixels) and printed row by row. About 170 lines.

## Proof obligations to watch

- **index**: Computed indices such as neighbour cells, the random pick among minimum-entropy candidates and the tile output position are loop-carried, so each is kept in a ranged subtype and clamped or guarded by a comparison against its count just before use.
- **overflow**: The deterministic LCG multiplies a state by a constant, which discharges only if the state is a bounded subtype (for example 0 .. 2**31-1) so the product fits in 64 bits before the mod.
- **division**: Taking the random value mod the candidate count needs a guard that the count is nonzero, which is naturally provided by the zero-entropy failure branch that prints a failure message.
- **termination**: The collapse loop is a for loop over the 64 cells, so no while loop or variant is needed, and every helper is a non-recursive procedure.
- **range**: Entropy and candidate counters accumulate in loops, so they are declared with ranges covering their maximum (5 tiles, 64 cells) and incremented only under an explicit bound guard.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, procedures, functions, Put without a newline, string building and 'Image of scalars.

## External effects

- **console output** (allowed): The 17x17 tile is printed as text art of '#' and ' ' characters, or a failure message if a cell has zero entropy.

Assessed on 2026-10-15 against page revision 414581 of the [task](https://rosettacode.org/wiki/Wave_function_collapse) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
