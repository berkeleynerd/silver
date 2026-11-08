# Honaker primes

**Candidate: proofs plausibly discharge automatically.** All checks follow from declared ranges and guards just before use, with no annotations needed, but the large sieve and the guarded loop-carried counters make discharge depend on careful program shape.

Position 406 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A Boolean sieve array over 2..4_100_000 is filled in a procedure using a for loop over I and a guarded while loop for multiples, and then a for loop over the array counts primes by position. Each prime's position and value are compared via a non-looping seven-digit digit-sum function, and the first fifty matches are printed using 'Image text assembled in a bounded String buffer, then the ten thousandth match is printed. Guards before every counter increment reject on overflow with a visible outcome. About 95 lines.

## Proof obligations to watch

- **index**: The sieve's inner marking loop advances J by I in a while loop, so each step is guarded by J <= Limit - I, which keeps both the index and the addition in range.
- **overflow**: Loop-carried counters such as the prime position and the Honaker count get a guard before each increment (an else branch rejects), since without invariants only their type ranges are known.
- **overflow**: The digit sum is computed without a loop as a sum of seven (N / 10**k) mod 10 terms over a value typed 0..9_999_999, so no accumulator is carried.
- **stack**: A sieve of about 4.1 million Booleans is a large fixed-size object whose storage is an unchecked environmental premise.
- **termination**: The sieve and search loops are written in a procedure with for loops or bounded while loops, so no termination check applies.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first fifty Honaker positions and primes plus the ten thousandth one as text lines.

Assessed on 2026-10-15 against page revision 414252 of the [task](https://rosettacode.org/wiki/Honaker_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
