# Combinations with repetitions/Square digit chain

**Candidate: proofs plausibly discharge automatically.** All loop bounds and values are small and typed (counts at most 17, sums at most 1377, totals below 10^17), so most checks follow from types, with guards needed only on the accumulating total and multinomial product and on the odometer's carried state.

Position 287 in the [progression](../../../progression.md#stage-9), in stage 9.

## Approach

Enumerate all multisets of k items from the ten squares as count vectors (ten counts summing to k) with an odometer-style while loop in a procedure, skipping the all-zero collection. For each, compute the sum of squares, look up a precomputed table (size 1378) saying whether the digit-square chain ends in 1, and if so add the multinomial count k!/(prod c_i!) computed from a Pascal binomial table with guarded multiplication into a bounded 64-bit total, then print each total with Put_Line. About 130 lines.

## Proof obligations to watch

- **overflow**: The running total and the product of binomials are loop-carried 64-bit values that types cannot bound, so each addition and multiplication is preceded by an explicit guard that rejects with a visible outcome if a limit were exceeded.
- **index**: The odometer enumeration of digit counts (ten counts summing to k) is carried across while-loop iterations, so every array index and count update needs a guard just before use, and counts are typed with the range 0..17.
- **termination**: The enumeration and the chain-to-1-or-89 loops are while loops, which is acceptable only because they sit in procedures, which get no termination check.
- **range**: The sum of squared values (at most 1377) is accumulated in a loop, so it is kept in a Natural subtype with a guard before indexing the precomputed 1-or-89 table.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, procedures, for loops, while loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the count of ordered arrangements reaching 1 for each of k=7, 8, 11, 14 and 17.

Assessed on 2026-10-15 against page revision 395332 of the [task](https://rosettacode.org/wiki/Combinations_with_repetitions/Square_digit_chain) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
