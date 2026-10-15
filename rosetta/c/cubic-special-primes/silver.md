# Cubic special primes

**Candidate: proofs likely to discharge automatically.** Every check follows from small bounded integer ranges and a for-loop primality test, and the only while loop sits in the Main procedure, so no annotation is needed. The program needs only integer arithmetic, mod, a function, loops and number-to-text output, which are all routine.

Position 319 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A function Is_Prime(V : Integer) tests primality with a for loop over divisors 2..122 (122*122 < 15000 <= 123*123), returning False when V < 2 or when a divisor D with D*D <= V and D < V divides V. Main keeps P (starting at 2) and N (starting at 1) in a while loop that runs while P < 15000: it forms C = N*N*N, exits if P + C >= 15000, adds C and resets N if P + C is prime, and otherwise increments N, with the guard N < 25 before the increment. Each term is printed with Integer'Image through Put and Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: P stays below 15000 and N is capped at 25 by a guard before each increment, so P + N*N*N is at most about 30000 and fits in Integer.
- **termination**: Is_Prime uses only a for loop over a fixed divisor range 2..122, so the function needs no variant, and the while loop lives in the Main procedure, which gets no termination check.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, while loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 23 primes found, separated by spaces or one per line.

Assessed on 2026-10-15 against page revision 394720 of the [task](https://rosettacode.org/wiki/Cubic_special_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
