# Hickerson series of almost integers

**Candidate: proofs plausibly discharge automatically.** The program needs more than 64-bit precision, so it uses fixed-capacity big numbers with a rapidly convergent integer series that avoids floating point, recursion and annotations; every operation is a bounded for loop over limbs, but carry-propagating loops make proof discharge depend on careful program shape.

Position 1384 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent numbers as a constrained array of base-10**9 limbs in a fixed-capacity record (around 16 limbs, about 140 digits) with procedures for multiply-by-small, add, double and extracting integer and first fractional digits. For each n in 1..17, compute S as the Horner sum over k from 1 to K of k**n * 2**(K-k) using a power built by repeated multiply-by-small, then divide by 2**(K+1) (a halving or shifting step) to get h(n) integer part and fraction. Print each row built into a bounded String buffer, with the almost-integer flag from whether the first fractional digit is '0' or '9'. About 190 lines.

## Proof obligations to watch

- **overflow**: Fixed-capacity digit-array big-number multiply-by-small, add and halve loops carry values through loop iterations, so each limb operation needs limb types and guards that bound carry (for example base 10**9 limbs with 64-bit products) and a capacity guard that rejects overflow of the array.
- **floating point**: Floating point is avoided entirely: h(n) is computed as the truncated series (1/2) * sum of k**n / 2**k in scaled integer big numbers, because 64-bit floats cannot give the first fractional digit at n=17 (h is about 1.3e17).
- **range**: The series is truncated at a fixed K (about 200 terms) whose tail is below 1e-3 for n up to 17, a documented constant resource limit, so the truncation is a visible fixed bound and the first decimal digit is taken from the truncated value, which is only safe if the tail never crosses a digit boundary (checked against the known output values).
- **index**: Limb and digit indexes come from for loops over the arrays' own ranges, and carry propagation uses a bounded for loop with an explicit overflow guard instead of an open-ended while loop.
- **termination**: All loops are for loops with fixed bounds or while loops inside procedures, so no termination check arises.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, string building, 'Image of scalars and big numbers.

## External effects

- **console output** (allowed): Prints one table row per n from 1 to 17 stating h(n) and whether it is an almost integer.

Assessed on 2026-10-15 against page revision 413743 of the [task](https://rosettacode.org/wiki/Hickerson_series_of_almost_integers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
