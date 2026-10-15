# Consecutive primes with ascending or descending differences

**Candidate: proofs likely to discharge automatically.** All arrays have static bounds, all loops are in a procedure, and every index and counter is bounded by a subtype or a guard just before use, so no annotation is needed. The only non-routine parts are the sieve step index and the counters, which are handled by guards and bounded subtypes.

Position 218 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Sieve of Eratosthenes over a constant-bounded Boolean array up to 999,999, then collect primes into a fixed-capacity array of 78,498 entries with a guarded append. A single linear pass tracks the current ascending and descending run lengths from consecutive differences, records the first longest run of each, and then prints each prime and its difference with one Put_Line per element using Integer'Image. About 90 lines.

## Proof obligations to watch

- **index**: The sieve's inner while loop and the prime-list append rely on a guard before each write (j <= 999_999 and Count < capacity), with a visible rejection if capacity were exceeded.
- **overflow**: Loop-carried streak, best-length and start-index counters are bounded by subtypes limited to the prime-list capacity, and differences of values below 10**6 fit in Integer.
- **termination**: The while loops live in the Main procedure, which has no termination check, and every loop advances a bounded counter.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the two longest prime sequences and their differences.

Assessed on 2026-10-15 against page revision 414126 of the [task](https://rosettacode.org/wiki/Consecutive_primes_with_ascending_or_descending_differences) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
