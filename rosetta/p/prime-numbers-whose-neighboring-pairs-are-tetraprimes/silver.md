# Prime numbers whose neighboring pairs are tetraprimes

**Candidate: proofs plausibly discharge automatically.** All checks come from ranged types, for-loop indexes and guards before neighbor indexing and counter increments, with no annotation-only facts, but nested sieve index arithmetic and loop-carried counters need careful shaping.

Position 429 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Use fixed-bound arrays indexed to 1,000,000: a sieve with for loops fills each number's count of distinct prime factors and a square-free flag, so a tetraprime is count 4 and square-free, and primality is count 1 with the number itself prime. A procedure scans primes for each limit (100,000 and 1 million) and each direction (preceding, following), guarding neighbor indices, collecting hits into a bounded array, counting those where a neighbor is divisible by 7, and recording gaps. Gaps are insertion-sorted in a procedure for the minimum, median and maximum, and results print through Put_Line with Image conversions and 10-per-line formatting for the 100,000 lists only. About 170 lines.

## Proof obligations to watch

- **overflow**: The per-number distinct-prime counter is loop-carried through array elements so it is guarded (increment only below a small cap) and counters are ranged types bounded by the sieve limit.
- **index**: Sieve multiples m = k*p are indexed with k in 1..Limit/p, which needs a guard or nonlinear reasoning that k*p stays within the array bound.
- **termination**: The insertion sort for the median uses a while loop, so it lives in a procedure (no termination check) and the sieve uses only for loops.
- **stack**: Million-element arrays are fixed-size static objects, though stack or static storage for them is an environmental premise and the 10 million stretch makes it larger.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the prime lists, counts and min/median/max gaps.

Assessed on 2026-10-15 against page revision 413855 of the [task](https://rosettacode.org/wiki/Prime_numbers_whose_neighboring_pairs_are_tetraprimes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
