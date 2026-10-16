# Find prime n such that reversed n is also prime

**Candidate: proofs likely to discharge automatically.** All values are bounded by a declared 0..999 subtype and fixed-range for loops, so overflow, range and termination checks follow from types and no invariants are needed.

Position 884 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Declare subtype Small is Integer range 0 .. 999 and write a function Is_Prime that returns False below 2 and otherwise loops D in 2 .. 31 rejecting when D*D < A and A mod D = 0, and a function Reverse3 that takes the hundreds, tens and units digits by / and mod and recombines them as units*100+tens*10+hundreds. A for loop over N in 1 .. 499 prints each N (via 'Image) whose Is_Prime and Is_Prime(Reverse3(N)) hold, counts them in a Natural bounded by 499, and finally prints the count line. Palindromic primes are kept, as the listed expected output includes 2, 11 and 101. About 45 lines.

## Proof obligations to watch

- **overflow**: The reversed value is computed with a fixed three-digit formula on a subtype 0..999, so every product and sum is bounded by the types and no loop-carried accumulator exists.
- **termination**: Primality is tested by a for loop over the fixed range 2..31 inside a function, which terminates by itself and needs no variant.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, 'Image of scalars, Put without a newline, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the qualifying primes and a count to standard output.

Assessed on 2026-10-15 against page revision 406204 of the [task](https://rosettacode.org/wiki/Find_prime_n_such_that_reversed_n_is_also_prime) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
