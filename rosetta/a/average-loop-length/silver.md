# Average loop length

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-bound loops over small ranges with typed integer and float data, but the float formatting and the loop-carried total and error computations need careful range guards.

Position 1077 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

A deterministic LCG with a ranged state picks f(x) as state mod N plus 1, and a Boolean array of size 20 records visited values over a fixed number of trials for each N from 1 to 20. The simulation uses for loops with a stop flag, the analytical value is accumulated as a running product term times (N-I+1)/N, and results are formatted into a bounded string with integer-scaled decimal text and printed with Put_Line and Put. Guards reject on any bound violation. About 90 lines.

## Proof obligations to watch

- **overflow**: The LCG state is a subtype below 2**31 and multiplied by a constant below 2**31 inside 64-bit integers, so the product and mod are bounded by types alone.
- **overflow**: The loop-carried repetition total has no invariant, so each addition is guarded by a bound check that rejects the run visibly, and the test count is a fixed small constant.
- **floating point**: The analytical term is a product of ratios at most 1 and the percent error divides by a value of at least 1.0, so a guard on the denominator and bounded operand ranges are needed for the float checks to discharge.
- **index**: The visited array is indexed by a random value mapped with mod into 1..N, whose range follows from a range-typed conversion after the mod.
- **termination**: All loops are for loops over fixed ranges with a Boolean stop flag instead of exit, so no variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, floating point, floating-point images, 'Image of scalars, string building, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The comparison table is printed to standard output.

Assessed on 2026-10-15 against page revision 414064 of the [task](https://rosettacode.org/wiki/Average_loop_length) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
