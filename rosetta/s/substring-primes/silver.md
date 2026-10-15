# Substring primes

**Candidate: proofs likely to discharge automatically.** Every check follows from the Small subtype range, nonzero loop divisors and for loops, so no loop-carried values or annotations are needed, and the functions terminate because only for loops are used. The task needs only integer arithmetic, bounded for loops and number printing.

Position 317 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A subtype Small is range 0 .. 999 and a Boolean function Is_Prime(N) uses a for loop over 2 .. N - 1 with a test of N mod D = 0 (guarded so that N < 2 returns False first). A second function Is_Substring_Prime(N) checks N itself and, by guarded branches on N >= 10 and N >= 100, the substrings N mod 100, N mod 10, N / 10, N / 100 and (N mod 100) / 10 using Is_Prime. The Main procedure loops N over 2 .. 500 and prints each qualifying number with Put and an Integer image of N. About 40 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, 'Image of scalars, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints the nine qualifying primes (2 3 5 7 23 37 53 73 373) on one line or one per line.

Assessed on 2026-10-15 against page revision 405988 of the [task](https://rosettacode.org/wiki/Substring_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
