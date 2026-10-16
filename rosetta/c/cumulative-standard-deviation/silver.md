# Cumulative standard deviation

**Candidate: proofs plausibly discharge automatically.** Everything follows from bounded integer element types, a for loop over a constant array and a guard before Sqrt, with no recursion or while loops. The only non-routine parts are the Float arithmetic bounds and a Float-to-text formatting operation that Silver does not yet offer.

Position 1054 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the eight samples in a constant array of a bounded integer subtype and keep a record of count, sum and sum of squares as Float, updated by a procedure Add (the stateful object style) inside a for loop over the array's own range. A function computes the population deviation as Sqrt of the mean of squares minus the squared mean, with a guard clamping a negative result to zero before Sqrt, and the main procedure prints each running result with Put and Put_Line. About 55 lines.

## Proof obligations to watch

- **floating point**: Sqrt requires a non-negative argument and the Float variance may round slightly negative, so the program guards the value with an explicit if before calling Sqrt and treats a negative value as zero.
- **overflow**: Running sum and sum of squares are loop-carried, so they use a ranged subtype or Float with the input type bounded (for example 0 to 1000 with at most eight samples) to keep the totals within range after each addition.
- **range**: The Float result needs to be formatted to fixed decimals, which is done by scaling to an integer after a range guard so the conversion cannot fail.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, arrays, for loops, records, procedures, functions, 'Image of scalars, floating-point images and Put without a newline.

## External effects

- **console output** (allowed): Prints the running count, item, mean and standard deviation for each of the eight values.

Assessed on 2026-10-15 against page revision 412733 of the [task](https://rosettacode.org/wiki/Cumulative_standard_deviation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
