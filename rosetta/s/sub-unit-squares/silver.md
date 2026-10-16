# Sub-unit squares

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded integer work with fixed-iteration for loops in functions and the only unbounded-looking loop in a procedure, so checks follow from range types and guards; the main care is keeping n*n and the repunit subtraction within 64 bits.

Position 389 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A procedure loops n from 1 with a while loop up to a documented bound, squares n in a 64-bit range type, and calls a function that walks the decimal digits with a bounded for loop, rejecting any square with a zero digit and accumulating the digit-reduced value by subtracting a repunit. A second function does a fixed-iteration bisection integer square root over a bounded range to test whether the reduced value is a perfect square, and the main procedure prints each hit with Integer'Image and Put_Line until five are found. About 70 lines.

## Proof obligations to watch

- **overflow**: n is bounded by a declared range (for example up to 10**9) so n*n fits in 64 bits, and the repunit is built over at most 18 digits so subtraction stays in range.
- **termination**: The search is a while loop inside a procedure (no termination check), and the digit and square-root loops are for loops with fixed bounds, so no function needs a variant.
- **range**: Loop-carried values (the shrinking quotient, the repunit, the bisection bounds) are typed with explicit ranges and guarded before each multiply or subtract, since no invariants can be written.
- **other**: Finding more than the required five terms depends on the search limit chosen; the program prints the first five and stops, with the bound being a documented limit.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the sub-unit squares found, one per line.

Assessed on 2026-10-15 against page revision 413932 of the [task](https://rosettacode.org/wiki/Sub-unit_squares) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
