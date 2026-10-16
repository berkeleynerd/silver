# Additive primes

**Candidate: proofs likely to discharge automatically.** All bounds are small and static (N below 500, digit sum at most 22), so the checks follow from ranged types and a guard before the sieve write, and no loop invariant is needed.

Position 209 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Use a Boolean array over 0..499 filled by a for-loop sieve (inner multiples advanced with a guarded while loop in the main procedure, or a for loop over N in 2..249 with an explicit N*P <= 499 guard). For each N, compute the digit sum by three fixed div/mod steps (hundreds, tens, units) into a ranged Sum, then if both Prime(N) and Prime(Sum) hold, increment a ranged Count and print N with Put and Put_Line using scalar-image, wrapping every 12 columns; finish with the count line. About 55 lines.

## Proof obligations to watch

- **index**: The sieve multiple N*P is guarded to be at most 499 before indexing, and the digit sum of a value in 2..499 is at most 22, so Prime(Sum) indexes safely when the array covers 0..499 or the sum is guarded.
- **overflow**: Loop-carried Count and digit-sum accumulators are declared with ranged subtypes (Count 0..499, Sum 0..27), and the sieve product is bounded by P<=499 and N<=499 in Integer.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, 'Image of scalars, Put without a newline, procedures and string building.

## External effects

- **console output** (allowed): Prints the heading, the additive primes below 500 in columns, and the count.

Assessed on 2026-10-15 against page revision 411689 of the [task](https://rosettacode.org/wiki/Additive_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
