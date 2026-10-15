# Subset sum problem

**Candidate: proofs plausibly discharge automatically.** The dynamic-programming formulation avoids subset enumeration and needs only bounded 2D Boolean tables and for loops, so index and range checks follow from ranged types plus explicit guards; the risk is only the guarded loop-carried sums and table size.

Position 714 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the 31 words (fixed-width padded strings) and weights in constant arrays, then run a pseudo-polynomial dynamic program filling reach(i, s) = some non-empty subset of the first i words sums to s over sums -31000..31000. If reach(31, 0) holds, backtrack with a reverse for loop carrying the remaining sum, preferring exclusion, and print each chosen word with its weight and the total; otherwise print a specified no-subset message. About 90 lines.

## Proof obligations to watch

- **index**: The reach lookup at s-w and the backtracking sum index must stay inside the sum range, which is discharged by an explicit range guard before each lookup and a ranged subtype for sums.
- **overflow**: Running sums are loop-carried, so they are kept in a ranged subtype and each update is guarded, with out-of-range cases skipped because no reachable sum can lie outside the bound.
- **initialization**: The roughly 2M-entry Boolean table must be fully initialized by an aggregate or nested for loops over its own ranges before use.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The chosen words and their weights are printed as lines of text.

Assessed on 2026-10-15 against page revision 382425 of the [task](https://rosettacode.org/wiki/Subset_sum_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
