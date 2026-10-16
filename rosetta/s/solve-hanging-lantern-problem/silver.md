# Solve hanging lantern problem

**Candidate: proofs plausibly discharge automatically.** The answer is a product of binomial coefficients over bounded arrays with for loops, so checks follow from types and guards, but the loop-carried accumulator needs an explicit overflow guard and the input must be parsed and validated, which makes discharge depend on careful program shape.

Position 1360 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The columns are chains, so the answer is the multinomial N!/(n1!...nk!), computed as a product of binomial coefficients C(prefix sum, n_i) taken from a Pascal triangle table of Long_Long_Integer built with for loops up to a documented total limit (for example 60 lanterns and 20 columns). Input is read line by line in a procedure, parsed with validation, and rejected visibly if malformed, over the column or total limit, or if a guarded multiplication would overflow; otherwise the product is printed. The optional sequence listing is omitted. About 100 lines.

## Proof obligations to watch

- **overflow**: The running product of binomial coefficients is loop-carried, so each multiplication is guarded by comparing the accumulator against Long_Long_Integer'Last divided by the coefficient, with a visible rejection when the result is too large.
- **index**: Pascal triangle and column arrays are indexed by subtypes bounded by a documented total-lantern limit, and parsed counts are validated against that limit before use.
- **range**: The running prefix sum of lanterns is loop-carried and is kept within the limit by a guard before each addition, rejecting inputs whose total exceeds it.
- **termination**: Input reading uses for loops over the validated column count in a procedure, so no variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, text parsing, standard input, 'Image of scalars, Boolean objects and exit status.

## External effects

- **standard input** (allowed): The column count and per-column lantern counts are read as integers from standard input.
- **console output** (allowed): The number of legal removal sequences is printed as a single integer.
- **exit status** (allowed): Rejected input (malformed, out of limits, or result too large) should end with a specified failure status.

Assessed on 2026-10-15 against page revision 407974 of the [task](https://rosettacode.org/wiki/Solve_hanging_lantern_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
