# Sleeping Beauty problem

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic over fixed loop bounds with ranged types and guards, but loop-carried counters need explicit guards because no invariant can be written, so discharge depends on program shape.

Position 162 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

The program keeps a ranged-subtype LCG state advanced by (state*A + C) mod M inside a for loop over a fixed one million tosses, adding one awakening for heads and two for tails while counting heads. After the loop it computes the heads percentage with integer arithmetic scaled to hundredths, guarding the divisor, and prints the counts and result as text built from integer images. About 45 lines.

## Proof obligations to watch

- **overflow**: The awakening and heads counters are loop-carried with no invariant, so each increment sits behind an explicit guard on a documented maximum that leads to a visible Reject rather than silent saturation.
- **overflow**: The linear congruential generator multiplies a state by a constant, which discharges because the state is a ranged subtype bounded so the product fits in 64 bits and the mod result restores the range.
- **division**: The percentage divides by the awakening count, which is guarded to be nonzero before the division.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the awakening count and the estimated percentage of heads to standard output.

Assessed on 2026-10-15 against page revision 413029 of the [task](https://rosettacode.org/wiki/Sleeping_Beauty_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
