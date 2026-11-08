# Verify distribution uniformity/Naive

**Candidate: proofs plausibly discharge automatically.** All checks follow from ranged types, a fixed array of buckets and for loops in procedures with no recursion or while loops, but loop-carried counters and the LCG multiplication need careful typing to avoid overflow; no annotations are needed.

Position 180 in the [progression](../../../progression.md#stage-6), in stage 6.

## Approach

A deterministic Park-Miller generator advanced by a procedure with an in out state and a mode selector (a good 1..7 generator and a deliberately biased one) stands in for the function argument, since passing subprograms is avoided. A Check procedure takes the mode, call count and delta percent as constants, runs a for loop filling a fixed array of 7 bucket counters, then loops over the buckets printing each count with 'Image and a passed/failed tag against precomputed low/high bounds. Main runs it twice, once flat and once biased, printing the verdict and setting a nonzero exit status when a distribution fails. About 90 lines.

## Proof obligations to watch

- **overflow**: The Park-Miller multiplication state*48271 is discharged by declaring the state as a ranged type and computing in a 64-bit range type whose bounds make the product provably fit.
- **overflow**: Bucket counters incremented in a loop lose their bounds after the first iteration, so each uses a type with headroom beyond the fixed call count or is guarded by a visible comparison against its maximum.
- **range**: Mapping the generator value to a bucket index uses mod by a constant bucket count with the index subtype matching the array range, which is routine once the state type is bounded.
- **overflow**: Computing the low and high thresholds as percentage of expected count is nonlinear but bounded by fixed constants for expected count and delta.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the achieved distribution per bucket and the passed or failed verdict.
- **exit status** (allowed): The task's 'error' for a non-flat distribution is reported as a nonzero exit status.

Assessed on 2026-10-15 against page revision 413961 of the [task](https://rosettacode.org/wiki/Verify_distribution_uniformity/Naive) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
