# Find prime numbers of the form n\*n\*n+2

**Candidate: proofs likely to discharge automatically.** Every check follows from the declared subtype ranges and a for loop with static bounds, and the function has no while loop or recursion, so it needs no variant or invariant.

Position 303 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A function Is_Prime takes a value in a bounded subtype (2 .. 7_880_601), rejects evens, and runs a for loop over d in 3 .. 2807 that clears a Boolean flag when d*d is below the value and value mod d = 0 (no loop exit needed). The main procedure loops n over 1 .. 199 with a bounded subtype, computes p = n*n*n + 2 and prints the Integer'Image of n and p when Is_Prime holds. About 30 lines.

## Proof obligations to watch

- **overflow**: n is a subtype 1..199 so n*n*n+2 is at most 7,880,601 and d*d with d at most 2807 stays far below Integer'Last, so both discharge from declared ranges.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints a header and one line per n whose n*n*n+2 is prime.

Assessed on 2026-10-15 against page revision 406205 of the [task](https://rosettacode.org/wiki/Find_prime_numbers_of_the_form_n%2An%2An%2B2) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
