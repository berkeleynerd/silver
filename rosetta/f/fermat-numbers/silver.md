# Fermat numbers

**Candidate: proofs plausibly discharge automatically.** Fixed-capacity decimal big-number arithmetic with for loops and range-typed accumulators lets every check follow from types and guards, but nested loop-carried sums and carries require careful shaping, so discharge is plausible rather than routine.

Position 1386 in the [progression](../../progression.md#stage-26), in stage 26.

## Approach

Represent each Fermat number as a fixed-capacity array of 160 decimal digits with a length, computing F(n) from F(n-1) by subtracting one, squaring with schoolbook multiplication with bounded carries, and adding one, then printing digits through a bounded String buffer with Put_Line. For the factor part, embed the known prime factors of F5 to F9 as 64-bit constants, verify each divides the big number by a digit-wise remainder loop, and print those that divide, with an explicit capacity guard that rejects overflow visibly. About 170 lines.

## Proof obligations to watch

- **overflow**: Schoolbook squaring of a 160-digit decimal array accumulates loop-carried column sums, which are discharged by giving the accumulator a range type wide enough for 160*81 plus carry and by guarding the capacity before each step.
- **index**: Digit positions in the product are computed from two loop indexes, so each index sum is guarded against the fixed capacity (and a result that would not fit is rejected visibly) rather than relying on an invariant.
- **overflow**: Remainder checks against embedded known factors up to about 6e16 compute rem*10+digit in a 64-bit loop-carried value, which is safe only because the divisor is a constant below 10^17 and the remainder is reduced each step with a guard.
- **termination**: All loops are for loops or live in procedures, so no variant is needed.
- **other**: Factoring beyond the embedded known factors is out of reach, so the program verifies and prints known factors of F5 to F9 by divisibility rather than searching for them.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, string building, 'Image of scalars, for loops, while loops, procedures, functions, big numbers and Put without a newline.

## External effects

- **console output** (allowed): Prints F0 through F9 and their prime factors line by line.

Assessed on 2026-10-15 against page revision 414201 of the [task](https://rosettacode.org/wiki/Fermat_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
