# Concatenate two primes is also prime

**Candidate: proofs likely to discharge automatically.** Every check follows from declared subtypes, for-loop ranges and a counter bounded by a visible guard, with no while loops or recursion, so proofs should discharge without annotations. The only extra surface is integer-to-text formatting for output.

Position 337 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed the bound 100 in subtypes (Low 2..99, Full 2..9999) and use a for-loop trial-division function Is_Prime for N in Full (divisors 2..99 with a mod check). Nested for loops over P1 and P2 test both for primality, compute the concatenation as P1*10 or P1*100 plus P2 depending on whether P2 < 10, mark a Boolean array indexed by Full, then a final for loop prints each marked value with 'Image trimmed via a small bounded digit buffer, and the guarded count, using Put_Line. About 55 lines.

## Proof obligations to watch

- **overflow**: The counter is a subtype ranging 0..625 incremented under an explicit Count < 625 guard, and the concatenation P1*100+P2 is bounded by the declared pair ranges, so both checks follow from types and guards.
- **range**: Trial division uses a function over N in 2..9999 with a for loop of divisors 2..99, so the mod operand is never zero and no loop-carried value needs an invariant.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, functions, for loops, 'Image of scalars, procedures and string building.

## External effects

- **console output** (allowed): Prints each concatenated prime and the final count as text lines.

Assessed on 2026-10-15 against page revision 406868 of the [task](https://rosettacode.org/wiki/Concatenate_two_primes_is_also_prime) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
