# Special divisors

**Candidate: proofs likely to discharge automatically.** All values are bounded by small declared ranges, the reverse function needs no loop or recursion so it has no termination obligation, and the only loops are for loops with static bounds, so every check follows from types and one visible guard.

Position 331 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A loop-free function reverses a number in 1..199 by branching on one, two or three digits using / and mod, with the result type bounded to 1..991. Nested for loops over n in 1..199 and d in 1..n test n mod d = 0, guard the reverse(d) divisor against zero, clear a Boolean flag when reverse(n) mod reverse(d) is nonzero, and print each qualifying n with Put and a bounded image string. About 45 lines.

## Proof obligations to watch

- **division**: The reversed divisor is the divisor of a reverse(d) mod, but reverse is written with if branches on ranged inputs so its result is provably at least 1 for d in 1..199, and an explicit nonzero guard rejects otherwise.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, functions, procedures, 'Image of scalars, string building, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints the qualifying numbers below 200 to standard output.

Assessed on 2026-10-15 against page revision 406177 of the [task](https://rosettacode.org/wiki/Special_divisors) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
