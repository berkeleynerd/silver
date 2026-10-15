# Knuth's algorithm S

**Candidate: proofs likely to discharge automatically.** All loops are for loops with static bounds and every array index comes from a mod expression or a for index, so checks follow from types without annotations; the only subtlety is the modular LCG and the count bounds.

Position 1281 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

Represent the generator as a modular 32-bit LCG state in a record with the 3-element sample array and item count, and implement the creator and s_of_n as a procedure Update on that state record (the closure being replaced by the explicit state, which the task allows as a class-like form). Main loops 1 .. 100_000 with nested for loops over digits 0 .. 9, uses N/I keep probability via (rand mod I) < N, replaces index (rand mod N) + 1, tallies a ten-element count array, then prints each digit's frequency with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The LCG state is a modular type so multiplication wraps by definition, and the counts are bounded by a Natural range of at most 300,000 so increments are guarded by the type range.
- **range**: The random index is computed as state mod 3 + 1 and the keep test as state mod I < N, both bounded by the divisor so no guard beyond I > 0 is needed.
- **overflow**: The item counter I runs only over a for loop of 1 .. 10 so I and its division are statically bounded.

## Language surface beyond today's Silver

Integers, integer division, modular types, ranged subtypes, arrays, for loops, while loops, procedures, records, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the ten digit frequencies after 100,000 repetitions.

Assessed on 2026-10-15 against page revision 414292 of the [task](https://rosettacode.org/wiki/Knuth's_algorithm_S) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
