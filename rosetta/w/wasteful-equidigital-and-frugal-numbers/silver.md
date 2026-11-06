# Wasteful, equidigital and frugal numbers

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic on bounded ranges inside procedures with loops and guards, so no annotations are needed, but proofs depend on carefully ranged subtypes and guards for loop-carried trial-division and counter values.

Position 287 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A procedure Analyze factorizes n by trial division in a while loop over a ranged divisor, accumulating digit counts of each prime and its exponent (when above 1) via a digit-counting procedure that divides by the base, then compares with the digit count of n. A driver loops over bases 10 and 11 and over n up to a fixed ceiling (3,000,000), keeping three category counters, three arrays of 50 first values (stores guarded by count < 50), the 10,000th value, and counts below 1,000,000, then prints with Put and Integer'Image in rows of ten. About 130 lines.

## Proof obligations to watch

- **overflow**: The trial-division loop-carried values d, n and the three category counters need ranged subtypes (n up to about 3,000,000, counters up to 10,000,000) plus an explicit guard before each increment, with d*d computed in a wider range type, since no invariant can be written.
- **index**: Stores into the 50-element result arrays are guarded by a test that the category count is below 50 just before the store, and the 10,000th value is kept in a scalar variable rather than an array.
- **termination**: All while loops (outer search, trial division, digit counting) sit in procedures, which get no termination check, and the outer search is bounded by a fixed upper limit on n so the program terminates visibly.
- **range**: The exponent and digit-count sums are bounded by small ranged subtypes (at most a few dozen), so the additions are safe from types alone.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 50 and 10,000th numbers of each category and the counts below 1,000,000, for bases 10 and 11.

Assessed on 2026-10-15 against page revision 414579 of the [task](https://rosettacode.org/wiki/Wasteful,_equidigital_and_frugal_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
