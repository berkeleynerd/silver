# Welch's t-test

**Candidate: proofs plausibly discharge automatically.** Every check is in floating-point arithmetic over embedded data, so it depends on range guards and bounded subtypes plus admitted elementary-function contracts (Log, Exp, Sqrt, lgamma), but needs no annotation if loops are capped procedure loops. The main difficulty is bounding loop-carried floats and Float image formatting rather than any conflict with the Oracle.

Position 1100 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the two data sets as constant Float arrays of fixed size, compute means and unbiased variances with for loops, then t and the Welch-Satterthwaite degrees of freedom, guarding N-1 and the denominators against zero. Compute the regularized incomplete beta via the continued or power series in a capped while loop inside a procedure, with lgamma from a fixed-term Lanczos approximation, and print t, df and p as text. About 110 lines.

## Proof obligations to watch

- **floating point**: Mean, variance, t, nu and the incomplete beta need finite and non-overflow facts, which the program gets from Float range subtypes, a fixed small embedded data set and explicit guards before divisions and Sqrt/Log/Exp calls.
- **division**: Divisions by N-1, by the standard error and by the variance-term denominator are guarded by explicit nonzero checks with a visible Reject-style outcome.
- **termination**: The series loop for the incomplete beta is a while loop inside a procedure, so it needs no variant, and a fixed iteration cap guarantees it stops.
- **range**: Log, Sqrt and Exp arguments (including lgamma via Lanczos or Stirling) must be guarded to positive or bounded values, and the elementary-function library contracts must admit those ranges.
- **overflow**: Loop-carried float accumulators in the series term and value are only bounded by their subtype ranges, so range-checked clamps are needed and must not alter the result for the given data.

## Language surface beyond today's Silver

Integers, ranged subtypes, floating point, floating-point images, arrays, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints t, degrees of freedom and p-value.

Assessed on 2026-10-15 against page revision 411126 of the [task](https://rosettacode.org/wiki/Welch's_t-test) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
