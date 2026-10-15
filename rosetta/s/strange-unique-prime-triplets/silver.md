# Strange unique prime triplets

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static or loop-bounded ranges and every index and divisor is bounded by types and loop ranges, so only the counter needs a guard.

Position 359 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Fill a Boolean primality table over 0..2999 using trial division in a for loop with divisors starting at 2 (no division by zero), then use three nested for loops over p < m < n up to 999 with the primality table lookups. Count qualifying triplets in a bounded integer and print those with n below 30 as text built from 'Image concatenation, then print the final count. About 70 lines.

## Proof obligations to watch

- **overflow**: The loop-carried triplet counter has no invariant, so it is guarded by an explicit check against its type's upper bound with a visible Reject outcome before each increment.
- **index**: The sum of three loop indexes, each at most 999, is at most 2997, which interval reasoning on for-loop ranges shows fits a prime table indexed 0..2999.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars, string building and functions.

## External effects

- **console output** (allowed): Prints the 41 triplets below 30 and the count of triplets below 1000 to standard output.

Assessed on 2026-10-15 against page revision 387224 of the [task](https://rosettacode.org/wiki/Strange_unique_prime_triplets) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
