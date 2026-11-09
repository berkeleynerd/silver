# Powerful numbers

**Candidate: proofs plausibly discharge automatically.** Only four primes can contribute, so the generation is a small bounded enumeration whose arithmetic is protected by ranged subtypes and division guards, and the only loop-carried index work is the array fill and the insertion sort in procedures.

Position 293 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

For each k in 2..10 the limit is 10**k, and since p**k <= 10**k forces p <= 10 only the primes 2, 3, 5 and 7 can occur, so nested loops enumerate exponents (0 or at least k) for these four primes, multiplying with a division guard against the limit and storing each product in a fixed array of 128 ranged values (unique factorization means no duplicates). A procedure with an insertion sort orders the array, then a procedure builds each output line from the count and the first and last five entries using 'Image and bounded concatenation. The optional counting part is omitted. About 130 lines.

## Proof obligations to watch

- **overflow**: Values live in a subtype bounded by 10**10 and every multiplication is guarded by a division test (cur <= limit / p) just before it, so products stay within 64 bits.
- **index**: The result array is filled through a loop-carried count that is guarded by count < capacity just before each store, with Reject as the visible outcome if full, and the capacity of 128 exceeds the 68 terms needed.
- **index**: Insertion sort uses a while loop with a loop-carried index that needs a guard (j > first and then compare) before each array access, which is routine only if written carefully.
- **termination**: All while loops sit in procedures, which get no termination check, and the exponent enumeration is nested for loops over fixed ranges.
- **range**: Image conversions of values up to 10**10 into bounded line buffers need declared maximum lengths large enough for 11-digit numbers, which static type ranges provide.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Boolean objects.

## External effects

- **console output** (allowed): Prints one line per k=2..10 with the count and the first five and last five terms.

Assessed on 2026-10-15 against page revision 413969 of the [task](https://rosettacode.org/wiki/Powerful_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
