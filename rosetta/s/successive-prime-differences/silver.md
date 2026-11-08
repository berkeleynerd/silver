# Successive prime differences

**Candidate: proofs plausibly discharge automatically.** All arrays and ranges are static and every loop-carried value (strike index, counters) can be guarded just before use, with no recursion or functions needing variants, but several loop-carried guards and a large Boolean array make careful shape necessary.

Position 294 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Sieve of Eratosthenes over a Boolean array 2..999999 using for loops for candidates and a guarded while loop for strikes, then compact the primes into an array of capacity 78498 with a guarded count. A procedure taking a difference table and its length scans consecutive primes with for loops, tracking first, last and a guarded count, and prints each result line from scalar images in a bounded string buffer. About 170 lines.

## Proof obligations to watch

- **index**: Sieve strike index j is loop-carried in a while loop, so the loop condition j <= Limit is tested just before each array access and the increment j + i is bounded by that guard.
- **overflow**: Group counters and the prime count are loop-carried and known only by type, so each increment is preceded by a guard against a declared maximum with a visible Reject outcome, and the 78498 prime count fits a declared capacity.
- **index**: Pattern scan reads P(i+k) for k up to 3, so the for-loop upper bound is the prime count minus the pattern length, with an explicit guard that the count is at least the pattern length.
- **length**: Group lines are assembled from scalar images of up to four 6-digit numbers into a bounded buffer sized for the worst case, so concatenation lengths are static.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first group, last group and count for each of the six difference patterns.

Assessed on 2026-10-15 against page revision 415240 of the [task](https://rosettacode.org/wiki/Successive_prime_differences) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
