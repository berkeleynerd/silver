# Palindromic primes

**Candidate: proofs likely to discharge automatically.** All values are bounded to 0..999 and every loop is a for loop over a static range, so overflow, range and division checks follow from types and no loop-carried value needs an invariant.

Position 319 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Loop N over 2 .. 999 with a for loop; a function computes the reversed digits using a bounded for loop of three digit steps, so N is a palindrome when its reverse equals N. A trial-division primality test divides by D over a for loop from 2 to 31 (since 32*32 > 999), guarding D < N, and each hit is printed with Put and a space after its image. About 45 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 20 palindromic primes below 1000 to standard output.

Assessed on 2026-10-15 against page revision 406217 of the [task](https://rosettacode.org/wiki/Palindromic_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
