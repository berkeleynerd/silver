# Wolstenholme numbers

**Candidate: proofs plausibly discharge automatically.** The first 20 numbers fit in 64 bits when the sum is kept over the fixed common denominator, so every arithmetic check follows from ranged subtypes and one guard per addition, with while loops confined to procedures. The beyond-64-bit stretch parts are optional and left out.

Position 273 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

The program uses a ranged 64-bit subtype, the constant common denominator lcm(1..20)^2, and a for loop over k = 1..20 that adds D/(k*k) to a guarded running sum, then reduces by a gcd procedure (while loop) to print each Wolstenholme number via 'Image padded into a fixed String. A primality procedure with an out Boolean uses odd trial division with the guard Div <= Value / Div, and the first 4 primes (5, 266681, 40799043101, 86364397717734821) are starred; the stretch digit counts are omitted. About 90 lines.

## Proof obligations to watch

- **overflow**: The program sums terms over the constant common denominator lcm(1..20)^2 (about 5.4e16) so that the running sum stays below 2^62, and guards each addition against a ranged-subtype limit with a visible rejection.
- **overflow**: Trial division would overflow computing Div*Div for a number near 1e17, so the loop tests Div <= Value / Div instead.
- **termination**: The gcd and primality loops are while loops, so they live in procedures with out parameters (no termination check) rather than in functions.
- **division**: Every divisor (k*k, gcd result, Div) is shown nonzero by its subtype range or by a guard just before the division.
- **other**: A trial-division loop of about 4.6e8 iterations is slow at run time but not a proof concern since it needs no invariant for its checks.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The program prints the first 20 Wolstenholme numbers and marks the first 4 prime ones.

Assessed on 2026-10-15 against page revision 414024 of the [task](https://rosettacode.org/wiki/Wolstenholme_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
