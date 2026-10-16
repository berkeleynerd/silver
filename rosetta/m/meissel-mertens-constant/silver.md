# Meissel-Mertens constant

**Candidate: proofs plausibly discharge automatically.** Everything is bounded loops over a fixed array with no recursion or annotations needed, but the float accumulator and the Log call require careful range guards, so discharge is plausible rather than certain.

Position 1048 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Sieve of Eratosthenes over a fixed Boolean array of about one million entries using nested for loops, then a for loop over primes accumulating ln(1-1/p)+1/p in a Long_Float, adding Euler's constant as a literal and printing the result through Put_Line. The precision is fixed and documented as limited by the sieve bound, and the bound keeps every index and float term in range. About 45 lines.

## Proof obligations to watch

- **floating point**: The accumulator is loop-carried, so a float overflow check needs a guard such as adding a term only while the sum is below a small bound (never triggered since the series converges below 1), and each term ln(1-1/p)+1/p is bounded because 1-1/p lies in [0.5,1).
- **range**: The Log argument must be positive, which holds because p is at least 2 and the argument is computed from a range-typed Long_Float value.
- **overflow**: The sieve's inner index i*k is nonlinear, so it is guarded against the array limit before use.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, floating point, floating-point images, arrays and for loops.

## External effects

- **console output** (allowed): Prints the computed constant as text.

Assessed on 2026-10-15 against page revision 413782 of the [task](https://rosettacode.org/wiki/Meissel-Mertens_constant) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
