# Hofstadter Figure-Figure sequences

**Candidate: proofs plausibly discharge automatically.** All loops are bounded for loops with array indices and sums that can be guarded explicitly, so no invariant is needed, though several loop-carried counters require careful guard placement. The unbounded-n requirement is met by a documented resource limit with specified rejection.

Position 384 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

One for loop over k in 1..1000 classifies each integer as the next R value or an S value, filling fixed arrays R(1..40) and S(1..960) while tracking a next-R accumulator and two counters, each guarded before use. A second for loop marks a Boolean array of 1..1000 and rejects duplicates or gaps, then the program prints the first ten R values and a pass line. ffr and ffs become array lookups behind a documented limit of 1000, with n beyond the limit rejected visibly. About 70 lines.

## Proof obligations to watch

- **index**: The R-count and S-count indices into the fixed arrays are loop-carried, so each use needs an explicit guard just before it (for example r_count <= s_count and counts below capacity) with a visible failure outcome.
- **overflow**: The running next-R value is an accumulator, so it is held in a bounded integer subtype and guarded against the 1000 limit before each addition.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars, string building, Put without a newline and functions.

## External effects

- **console output** (allowed): Prints the first ten R values and a pass or fail line.

Assessed on 2026-10-15 against page revision 413492 of the [task](https://rosettacode.org/wiki/Hofstadter_Figure-Figure_sequences) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
