# Carmichael lambda function

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic in procedures with explicit guards and no recursion or annotations, but loop-carried lcm and counter values need careful subtype bounds and guards, so discharge depends on program shape.

Position 834 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Use subtype-bounded Integer/Long_Long_Integer values (n up to 5,000,000) with procedures: factor by trial division using a for loop over candidate primes with an inner while dividing out each prime, combine lambda of prime powers via a Euclid gcd while-loop procedure and lcm, and count iterations in a bounded while loop with an explicit cap. A single for loop over n from 1 to 5,000,000 records the first n for each iteration count 0..15 in a fixed array guarded by index checks, and results print through Put_Line with 'Image concatenation; the stretch part (i 16 to 25, n near 3^24) is left out as optional. About 130 lines.

## Proof obligations to watch

- **overflow**: The lcm product of two lambda values and the (p-1)*p**(k-1) totient term are nonlinear, and are discharged by computing in a 64-bit type with subtype bounds on n (at most 5,000,000) plus a visible reject guard if a result exceeds the bound.
- **range**: Loop-carried values such as the running lcm, the remaining cofactor and the iteration counter have only their type range after the first iteration, so each is bounded by a subtype and a guard just before assignment.
- **termination**: The gcd, prime-dividing and iteration-counting while loops are placed in procedures, which get no termination check, and the lambda and iteration helpers are procedures rather than functions.
- **index**: The first-occurrence array is indexed by the iteration count, which is guarded by a comparison against the array bound before each use.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and case statements.

## External effects

- **console output** (allowed): Prints the lambda and iteration table for 1 to 25 and the lowest n for each iteration count.

Assessed on 2026-10-15 against page revision 387146 of the [task](https://rosettacode.org/wiki/Carmichael_lambda_function) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
