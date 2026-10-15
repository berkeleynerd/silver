# Long stairs

**Candidate: proofs plausibly discharge automatically.** Everything is simple integer simulation whose checks follow from subtype ranges and a length-cap guard, and no annotation is needed because the while loop lives in a procedure; the work is in keeping the many loop-carried values bounded by guards.

Position 1303 in the [progression](../../progression.md#stage-23), in stage 23.

## Approach

A procedure-only program keeps the generator state, steps behind, staircase length and totals as ranged or modular scalars, with a deterministic linear congruential generator supplying the random step position. An outer for loop runs 10000 trials, an inner while loop advances one step per second and adds five steps, each counted as behind when the random index is below steps behind, with a cap guard before every increment. The first trial prints seconds 600 to 609 and the end prints integer averages built from 'Image text. About 90 lines.

## Proof obligations to watch

- **overflow**: Staircase length, steps behind and the running totals are loop-carried, so each increment is guarded by an explicit length cap that stops the trial with a visible 'limit exceeded' report instead of altering results.
- **division**: The random index is taken modulo the staircase length, which is declared as a subtype starting at 100 so the divisor is provably nonzero.
- **range**: Steps-behind must stay within the staircase length type, which needs a guard before each increment since no invariant can relate the two loop-carried values.
- **overflow**: The linear congruential generator state is a modular type so wraparound is the defined arithmetic and the reduction to an index uses a bounded unsigned value.
- **termination**: The escape loop is a while loop inside a procedure, so no termination check is generated, but the run is only bounded by the length cap.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, modular types, Boolean objects, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the seconds 600 to 609 table and the average time and average final staircase length.

Assessed on 2026-10-15 against page revision 400965 of the [task](https://rosettacode.org/wiki/Long_stairs) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
