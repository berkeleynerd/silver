# Piprimes

**Candidate: proofs likely to discharge automatically.** Everything is small bounded integer arithmetic with static for-loop ranges and a guarded counter, so every check follows from types and guards. The main new needs are integers, mod, for loops, 'Image and Put without a line terminator.

Position 1521 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

A Main procedure runs a for loop over N in 2 .. 100 (after printing pi(1) = 0) and tests primality with an inner for loop over divisors 2 .. N-1 setting a Boolean when N mod D = 0. A bounded Count (subtype 0 .. 100) is incremented under a guard when N is prime, and only while Count < 22 is its 'Image written with Put, followed by a final Put_Line to end the line. All loops are for loops with static bounds, so no variants or invariants are needed. About 28 lines.

## Proof obligations to watch

- **overflow**: The running prime count is a loop-carried value, so it is a subtype 0 .. 100 and the increment is guarded by a test that it is below 100, which the type range alone makes safe.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, 'Image of scalars, Put without a newline and block statements.

## External effects

- **console output** (allowed): Prints the pi(n) values for n = 1 up to 78 on one line.

Assessed on 2026-10-15 against page revision 414661 of the [task](https://rosettacode.org/wiki/Piprimes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
