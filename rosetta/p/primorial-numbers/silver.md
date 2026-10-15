# Primorial numbers

**Candidate: proofs plausibly discharge automatically.** Every arithmetic check follows from subtype ranges of limb, prime and carry, and the only loop-carried quantity needing a guard is the used-limb count, so no annotation is needed, though the roughly 3e9 limb operations and the big-number shape make careful program structure necessary.

Position 1391 in the [progression](../../progression.md#stage-25), in stage 25.

## Approach

Sieve of Eratosthenes over a fixed Boolean array up to 1,299,709 fills a 100,000-entry prime table, then the first ten primorials are computed in a 64-bit range type and printed with 'Image. A fixed-capacity big number stored as base-1e9 limbs in an array is multiplied in place by each successive prime in a procedure, with a guard on the used-limb count, and the decimal digit count (limbs times nine plus the top limb's digits) is printed at each power-of-ten index up to 100000; the optional millionth case is omitted. About 170 lines.

## Proof obligations to watch

- **overflow**: The limb-times-prime-plus-carry product is bounded by about 1.3e15 because limbs are a subtype below 1e9, primes are a subtype up to 1,299,709 and carry is a ranged subtype, so it fits in 64 bits from types alone.
- **range**: The new carry (product divided by 1e9) must be shown within its declared subtype after each iteration, which follows from the operand subtype bounds without any invariant.
- **index**: The count of used limbs is a loop-carried value, so a guard before each increment rejects with a visible outcome if the fixed capacity (about 70,000 limbs) would be exceeded, and limb indices run over the array's own range.
- **termination**: The sieve and prime-collection while loops live in procedures, which get no termination check, and the multiplication loops are for loops.
- **overflow**: The sieve's multiple stepping (x*x and x+step) is guarded against exceeding the fixed sieve limit before each use, and a prime count that stays within the prime table must be guarded before storing.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, big numbers and string building.

## External effects

- **console output** (allowed): Prints the first ten primorials and the digit counts for indices 10, 100, 1000, 10000 and 100000.

Assessed on 2026-10-15 against page revision 414010 of the [task](https://rosettacode.org/wiki/Primorial_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
