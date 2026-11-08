# Odd squarefree semiprimes

**Candidate: proofs likely to discharge automatically.** Everything is a small bounded for-loop computation over a declared range with no loop-carried accumulators and no termination checks needing variants, so all checks follow from types and static bounds.

Position 308 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A subtype Small_Natural range 0 .. 1000 and an Is_Prime function using a for loop over divisors 2 .. 31 with a guard d*d <= n (bounded so no overflow). The main procedure loops n over odd values 15 .. 999 and, for each smallest odd divisor p from 3 to 31 with p*p < n and n mod p = 0, checks that q = n / p is prime and differs from p, then prints n with Image via Put_Line. All arithmetic is on values bounded by 1000, so every check follows from types and for-loop ranges. About 35 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each odd squarefree semiprime below 1000, one per line.

Assessed on 2026-10-15 against page revision 404013 of the [task](https://rosettacode.org/wiki/Odd_squarefree_semiprimes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
