# Knapsack problem/Continuous

**Candidate: proofs likely to discharge automatically.** Integer arithmetic in tenths with small declared ranges avoids floating point, and the sort and greedy fill are bounded loops over a fixed 9-element array with guards before each access, so checks follow from types and guards. Output formatting needs integer-to-text conversion but nothing needs an annotation.

Position 793 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

Represent the 9 items as parallel constant arrays of names, weights (in tenths of kg) and prices, plus a fixed-size order array of indices sorted by price per weight using cross-multiplied integer comparison in an insertion sort. A for loop then fills the knapsack greedily, tracking the remaining capacity as a bounded integer and taking either the whole item or the remaining weight, and a final loop prints each taken amount and the totals as fixed-point text built from integer tenths and hundredths. About 110 lines.

## Proof obligations to watch

- **overflow**: Weights in tenths of kg and prices as small ranged integers keep all products far below 2**31, so each multiplication discharges from type ranges.
- **division**: The value-per-weight ratio is avoided by comparing cross-products, and the partial-value division uses a constant positive weight type so the divisor is provably nonzero.
- **index**: Insertion sort over an array of 9 items uses a for loop for the outer index and a guarded while loop in a procedure for the inner index, with the index test placed before each access.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, records, string building, 'Image of scalars, case statements, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the total weight, total value and the taken portions of each item.

Assessed on 2026-10-15 against page revision 414289 of the [task](https://rosettacode.org/wiki/Knapsack_problem/Continuous) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
