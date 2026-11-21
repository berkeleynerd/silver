# Statistics/Chi-squared distribution

**Candidate: proofs plausibly discharge automatically.** Everything is bounded and loop counts are fixed, so there is no recursion or variant need, but the proof depends on floating-point library contracts for Exp and power, and on range guards for the float series. This makes it plausible rather than likely.

Position 1012 in the [progression](../../../progression.md#stage-16), in stage 16.

## Approach

Embed the airport table as a constant 4x2 integer array and compute gamma at half-integer and integer arguments with a Lanczos-style fixed-size coefficient array, or by recurrence from Gamma(1/2) and Gamma(1). The incomplete-gamma series uses a for loop with a fixed term count, and the pdf and cdf functions are guarded on x and k ranges. Main loops over k = 1..5 and x = 0..10, prints the pdf table, the cdf and p values for 1, 2, 4, 8, 16 and 32, and the airport statistic with p value, formatting the floats into fixed-decimal text through bounded integer scaling. About 110 lines.

## Proof obligations to watch

- **floating point**: Exp, power and gamma on Double need operand-range guards (x in 0..32, k in 1..5) so no overflow or domain check fails, and float provers are weak.
- **termination**: The incomplete-gamma series is written as a for loop with a fixed term count (for example 200 terms) inside a function, avoiding a while loop that would need a variant.
- **overflow**: Loop-carried accumulators and running terms lose bounds after the first iteration, so each must be clamped by an explicit guard before use, and the guard must not change the result.
- **range**: Float-to-integer conversions used for fixed-decimal printing need guards on magnitude, and the elementary-function library must supply verified contracts for Exp, Log and Sqrt.
- **division**: Divisions by x, k or the gamma value need explicit nonzero guards, with pdf at x = 0 returning a specified 0.0.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, floating point, floating-point images, arrays, multidimensional arrays, for loops, while loops, procedures, functions, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the pdf table, the cumulative and p-value table, and the airport chi-squared result.

Assessed on 2026-10-15 against page revision 394372 of the [task](https://rosettacode.org/wiki/Statistics/Chi-squared_distribution) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
