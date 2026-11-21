# Arithmetic-geometric mean/Calculate Pi

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic on fixed-capacity limb arrays in procedures with for loops and capped while loops, so checks follow from types and bounds, but multi-limb carries and big square root and division make the shape delicate.

Position 1397 in the [progression](../../../progression.md#stage-24), in stage 24.

## Approach

Represent numbers as fixed-point values in a fixed-capacity array of base-10000 limbs (for example 1000 decimals), with procedures for add, subtract, multiply, divide by a small integer, full division and an integer-Newton square root. Run the AGM recurrence a, g, and the running sum of 2^(k+1)(a_k^2-g_k^2) in a bounded for loop of N steps (N about 10), computing pi = 4 a_N^2 / (1 - sum) each step and printing it as decimal text limb by limb. All sizes are constants, with the sum kept positive by the algorithm and guards ensuring the divisor is nonzero. About 260 lines.

## Proof obligations to watch

- **overflow**: Digit-wise multiply, divide and add use base 10**4 limbs in 64-bit accumulators whose carries are bounded by the limb type, so each limb operation is range-guarded, but the loop-carried carry needs a subtype whose range alone gives the bound.
- **index**: All limb loops are for loops over the fixed array range, with shifted indexes guarded just before use, so indexing discharges without invariants.
- **termination**: The AGM iteration and the Newton integer square root use while loops inside procedures only, with a fixed iteration cap (about 8 AGM steps for 1000 digits), so no function carries a loop needing a variant.
- **overflow**: Fixed-point scaling of a_n^2-g_n^2 times 2^(n+1) needs a bounded step count and a limb capacity with headroom, which fixed capacity and the iteration cap guarantee.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, big numbers, Put without a newline, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the successive approximations of pi, one per line, with Put_Line and Put.

Assessed on 2026-10-15 against page revision 413642 of the [task](https://rosettacode.org/wiki/Arithmetic-geometric_mean/Calculate_Pi) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
