# Dice game probabilities

**Candidate: proofs plausibly discharge automatically.** Exact integer DP replaces the Monte Carlo of the existing solution, so there is no randomness or floating point, and all arithmetic stays well under 64 bits with guards just before each operation; the only non-routine parts are the loop-carried count accumulations and decimal formatting.

Position 931 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Compute the exact distribution of dice sums by dynamic programming over a bounded array of counts (one convolution per die with for loops), then compute cumulative counts and sum over player-one totals the product of its count and the count of player-two totals below it. Print the exact win count scaled by 10^7 and divided by the total outcomes as a decimal string, with guards on every accumulation, product and index that reject on exceeding the limits. Both scenarios run through one procedure with fixed constants for the dice. About 110 lines.

## Proof obligations to watch

- **overflow**: Count additions in the sum-distribution loops and the products of the two distributions carry loop-carried values, so each is guarded by an explicit comparison against a documented limit that rejects instead of altering results (never triggered for the task's data).
- **index**: The target index sum plus face in the convolution is checked against the array's last index just before each use, which is a plain guard.
- **division**: The divisor (total outcomes) is guarded non-zero before computing the scaled probability, and the product guard uses division by a count checked non-zero.
- **length**: Decimal text is assembled in a fixed-size buffer whose length follows from the bounded digit count, with guards before each write.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the two win probabilities as decimal text lines.

Assessed on 2026-10-15 against page revision 414156 of the [task](https://rosettacode.org/wiki/Dice_game_probabilities) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
