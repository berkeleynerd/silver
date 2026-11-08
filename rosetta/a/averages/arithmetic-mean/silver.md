# Averages/Arithmetic mean

**Candidate: proofs plausibly discharge automatically.** Everything follows from small declared ranges, a fixed capacity and an explicit zero-count guard, but the accumulating sum and the digit-by-digit fraction need carefully guarded loop-carried values, so discharge depends on program shape rather than being routine.

Position 182 in the [progression](../../../progression.md#stage-6), in stage 6.

## Approach

The vector is a fixed-capacity array of a bounded integer subtype plus a Count, with the task's sample data (3,1,4,1,5,9) and an empty vector embedded; a procedure sums with a for loop over 1..Count with a guard before each addition. If Count is 0 it prints 'undefined'; otherwise it prints the integer quotient and a few decimal digits from the remainder via long division in a bounded text buffer. About 55 lines.

## Proof obligations to watch

- **overflow**: The loop-carried sum is known only by its type after the first iteration, so the program declares a bounded sum subtype and guards each addition (rejecting out-of-range sums visibly) so the check discharges without an invariant.
- **division**: Division by the element count is guarded by an explicit Count = 0 branch that prints a specified 'undefined' outcome.
- **length**: The decimal text of the mean is built in a fixed-size buffer whose size is bounded by the declared value ranges and a fixed number of fraction digits.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The mean of the sample vector and the empty-vector outcome are printed as text lines.

Assessed on 2026-10-15 against page revision 413338 of the [task](https://rosettacode.org/wiki/Averages/Arithmetic_mean) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
