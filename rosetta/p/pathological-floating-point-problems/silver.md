# Pathological floating point problems

**Candidate: proofs plausibly discharge automatically.** The loops are fixed-count for loops and the arithmetic is simple, but floating-point division by loop-carried values and range-bounded intermediates need guards that the provers must handle, and float formatting needs an admitted library operation, so discharge is plausible rather than routine.

Position 1577 in the [progression](../../progression.md#stage-38), in stage 38.

## Approach

Use a range-constrained long float subtype for the recurrence (Task 1), the bank balance (Task 2) and Rump's formula (Task 3), with for loops over fixed counts and a rolling pair of previous values. Guard each division with an explicit nonzero test that prints a rejection, and guard each result against the subtype's bounds before assignment. Print selected rows via an admitted float formatting operation into bounded strings with Put_Line. About 90 lines.

## Proof obligations to watch

- **floating point**: The recurrence divides by Old and by Old*Very_Old, so each iteration needs an explicit guard on a nonzero divisor that rejects the run visibly, since the loop-carried values only have the type range.
- **overflow**: Unbounded Float values cannot be shown finite after loop iterations without invariants, so the program must use a range-constrained float subtype and guard each result so the product, difference and sum stay within the range.
- **overflow**: The bank balance is multiplied by the year each step, so the balance must be guarded against a declared bound before multiplying, which is feasible for 25 years but only with a bounded subtype.
- **floating point**: Rump's expression needs b**8 near 1.4e36 and cancellation, so it is computed in a bounded float subtype with ranges wide enough for the intermediates, and the provers must bound each nonlinear term.
- **other**: Printing 16 decimal places needs a float-to-text routine with computed-length buffers, which Silver would have to supply as an admitted library operation since 'Image on floats is not provable to bound length by itself.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, floating point, fixed point, arrays, records, for loops, case statements, procedures, functions, 'Image of scalars, floating-point images, string building, Put without a newline and big numbers.

## External effects

- **console output** (allowed): Prints the sequence values and yearly balances as text lines.

Assessed on 2026-10-15 against page revision 413840 of the [task](https://rosettacode.org/wiki/Pathological_floating_point_problems) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
