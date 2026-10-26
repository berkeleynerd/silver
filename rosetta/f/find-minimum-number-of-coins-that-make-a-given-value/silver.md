# Find minimum number of coins that make a given value

**Candidate: proofs likely to discharge automatically.** Greedy change with fixed coins uses only a for loop over a constant array, with division by constants that are provably nonzero and ranged accumulators, so every check follows from types and no annotation is needed. Nothing recursive, heap-based or input-dependent is involved.

Position 121 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Embed the eight denominations in a constant array of a ranged subtype (1..200) and the amount 988 as a constant; a for loop over the array's own range computes count = Owing / Coin and Owing = Owing mod Coin, with the counts accumulated in a ranged total. Each nonzero count prints a line built from 'Image text, followed by a final total line, all in the main procedure. About 35 lines.

## Proof obligations to watch

- **overflow**: The loop-carried remaining amount and coin total are declared with ranged subtypes (0..988 and 0..988) so additions and subtractions need no invariant.
- **length**: Output lines are built from fixed literals plus bounded integer images, so concatenation lengths are statically bounded by the subtype ranges.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints the total value, each coin count line and the coin total with Put_Line.

Assessed on 2026-10-15 against page revision 409680 of the [task](https://rosettacode.org/wiki/Find_minimum_number_of_coins_that_make_a_given_value) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
