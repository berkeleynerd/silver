# Factors of a Mersenne number

**Candidate: proofs likely to discharge automatically.** Every operation is bounded integer arithmetic inside static-range for loops with small declared subtypes, so overflow, range and division checks follow from types and guards without annotations. The only integer-to-text conversion and no recursion or while loops make it plain for the provers.

Position 352 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A fixed exponent constant 929 with K ranging over 1..17 forms candidates q = 2*K*929+1 in a bounded 64-bit subtype, keeping only q mod 8 = 1 or 7. A function tests primality by a for loop over divisors 2..1500 guarded by d*d <= q, and a function does modular exponentiation by a for loop reverse over the 11 exponent bits using a bounded Square subtype. The main procedure prints the first factor found via Image-style text building, or a no-factor message. About 70 lines.

## Proof obligations to watch

- **overflow**: Square is a loop-carried value, but its declared subtype 0..2**30 and candidate q bounded below 2**21 make Square*Square*2 fit in 64 bits without any invariant.
- **range**: The result of mod q is assigned back to the bounded Square subtype, which discharges because q is a bounded loop-derived value and mod gives 0..q-1.
- **termination**: All loops are for loops over static ranges (K 1..17, 11 exponent bits, trial divisors 2..1500 guarded by d*d <= q), so no variant is needed inside the functions.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the line reporting that 2**929-1 has factor 13007.

Assessed on 2026-10-15 against page revision 413611 of the [task](https://rosettacode.org/wiki/Factors_of_a_Mersenne_number) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
