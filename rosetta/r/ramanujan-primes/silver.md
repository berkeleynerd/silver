# Ramanujan primes

**Candidate: proofs plausibly discharge automatically.** All arithmetic is on integers bounded by a fixed 500,000 limit, with array accesses guarded just before use and loops confined to procedures, so no annotation is needed, though the several loop-carried indexes require careful guard placement.

Position 269 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Sieve the primes up to a fixed bound of 500,000 (above the 10,000th Ramanujan prime, 242,057) into a Boolean array, then build a prefix-count array pi. For each x ascending, compute c = pi(x) - pi(x/2) and, when c+1 is within 1..10,000, record x+1 in a table slot; a prefix maximum over the table then yields the nth Ramanujan prime. Print the first 100 in rows of 20 and then the 1000th and 10,000th, using 'Image and Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: Sieve strides and pi(x/2) lookups are guarded with comparisons against the fixed limit just before each array access, since loop-carried indexes are known only by type.
- **overflow**: Prime counts and the running maximum are held in a subtype bounded by the sieve limit, so additions fit without an invariant.
- **range**: The slot index c+1 for the Ramanujan table is guarded to be at most 10,000 before use, so counts above that are simply skipped as irrelevant to the required outputs.
- **termination**: The sieve while loops live in procedures, which get no termination check, and each makes progress by a positive stride.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 100 Ramanujan primes, the 1000th and the 10,000th.

Assessed on 2026-10-15 against page revision 394242 of the [task](https://rosettacode.org/wiki/Ramanujan_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
