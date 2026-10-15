# Prime numbers p for which the sum of primes less than or equal to p is prime

**Candidate: proofs likely to discharge automatically.** Everything is bounded for-loop trial division over small declared ranges with the only loop-carried values being a guarded sum and two small counters, so all checks follow from types and guards without annotations.

Position 356 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A function Is_Prime(N : Natural range 0..100000) tests divisors with a for loop over 2..316 and a guard d*d <= N, then a main for loop over 2..999 accumulates a guarded ranged sum of primes and tests whether the sum is prime. Qualifying primes are printed with Put of their Image padded by hand, with a Put_Line after every seventh, followed by a final count line. About 70 lines.

## Proof obligations to watch

- **overflow**: The running prime sum is loop-carried, so it is a ranged subtype (0 .. 100000) and a guard before each addition rejects the unreachable case where it would exceed the bound, since the true total 76127 is not provable without an invariant.
- **range**: The count and the column counter are loop-carried and are kept in small ranged subtypes with guards before increment, with the count at most 168 by type.
- **division**: The mod divisors are loop constants from a for loop starting at 2, so the nonzero check follows from the loop range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars, Put without a newline, string building and procedures.

## External effects

- **console output** (allowed): Prints the qualifying primes, in rows of seven, and a count to standard output.

Assessed on 2026-10-15 against page revision 391967 of the [task](https://rosettacode.org/wiki/Prime_numbers_p_for_which_the_sum_of_primes_less_than_or_equal_to_p_is_prime) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
