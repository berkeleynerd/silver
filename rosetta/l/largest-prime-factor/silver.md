# Largest prime factor

**Candidate: proofs likely to discharge automatically.** Trial division fits in a procedure's while loop (so no termination check) with only an overflow-safe guard and a P >= 2 subtype needed, and the 64-bit range covers 600851475143. The only non-routine point is loop-carried P and N bounds, which declared ranges and the guard supply without annotations.

Position 185 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Hold N and the candidate divisor P in 64-bit ranged integer subtypes, with N starting at the constant 600851475143 and P in a subtype starting at 2. A while loop in the Main procedure repeats while P <= N / P, dividing N by P when N mod P = 0 and otherwise incrementing P; the remaining N is the largest prime factor and is printed with 'Image text conversion. About 25 lines.

## Proof obligations to watch

- **overflow**: The loop uses the guard P <= N / P instead of P * P <= N and increments P only under that guard, so P + 1 stays within a 64-bit integer type without any invariant.
- **division**: P is declared in a subtype with lower bound 2, so N / P and N mod P cannot divide by zero even though P is loop-carried.
- **range**: Assigning N := N / P and P := P + 1 to range-typed variables needs the provers to see P stays at most the type's upper bound, which holds because P <= N / P implies P <= sqrt N and N is at most 600851475143.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, while loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the single result line 6857 to standard output.

Assessed on 2026-10-15 against page revision 409051 of the [task](https://rosettacode.org/wiki/Largest_prime_factor) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
