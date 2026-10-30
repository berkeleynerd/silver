# Verify distribution uniformity/Chi-squared test

**Candidate: proofs plausibly discharge automatically.** The task needs only bounded integer arithmetic if the statistic is computed by the exact integer identity and a scaled critical-value table, so all checks follow from type caps and pre-use guards. Loop-carried accumulators need explicit guards, which makes discharge plausible rather than routine.

Position 379 in the [progression](../../../progression.md#stage-8), in stage 8.

## Approach

Counts are held in a constant array of Natural subtype capped at 1_000_000 with at most 10 bins, and the 5% critical values for 1..9 degrees of freedom are an embedded table scaled by 100. A function computes the total and sum of squares in for loops with an explicit limit guard, rejects a zero total or too many bins under 5, and evaluates chi-squared as k*sum(O^2)/S - S in scaled integer arithmetic, returning a Boolean for the comparison against the table. A procedure prints the degrees of freedom, statistic and verdict for the embedded example data. About 70 lines.

## Proof obligations to watch

- **overflow**: The sum and sum-of-squares accumulators are loop-carried, so each addition is guarded against a documented limit (counts capped at 1_000_000 with at most 10 bins) and an over-limit input is visibly rejected.
- **division**: The divisor is the total count, and a guard rejecting a zero total (and bin counts below 5, as the task's expected-frequency rule implies) precedes the division.
- **range**: The statistic is computed in scaled integer arithmetic (hundredths) rather than floating point, and the scaled product of k, sum of squares and 100 is bounded under 2**63 by the count cap, so no float proof is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the degrees of freedom, the chi-squared statistic and the uniform or non-uniform verdict for the embedded example counts.

Assessed on 2026-10-15 against page revision 414573 of the [task](https://rosettacode.org/wiki/Verify_distribution_uniformity/Chi-squared_test) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
