# Home primes

**Candidate: proofs plausibly discharge automatically.** Every check follows from subtype ranges and guards placed just before the multiplication, append or increment, and all unbounded loops live in procedures, but several loop-carried 19-digit values and nonlinear guards make discharge dependent on careful program shape. The stretch goal for 65 and the impossible HP49 goal are optional and omitted.

Position 421 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Values are held in a 64-bit signed range subtype (all required values stay below 3.4e18), and a procedure factors n by trial division with a guarded p <= n / p loop, appending each factor's digits via 'Image into a concatenated value with an overflow guard. A chain array of fixed capacity records each iteration until a trial-division primality procedure reports prime, then a bounded text buffer is assembled as "HPn(k) = ... = prime" and printed with Put_Line for n in 2 .. 20 using a for loop. About 140 lines.

## Proof obligations to watch

- **overflow**: Appending a prime factor's digits to the 19-digit running value is guarded by comparing the value against (Max - p) / 10**digits before multiplying, and a failed guard prints a visible 'exceeds limit' outcome for that chain.
- **overflow**: The trial-division candidate p is advanced only while p <= n / p, which with a subtype bounded by about 3.1e9 makes p + 2 and the comparison safe without an invariant.
- **index**: The chain array has a fixed capacity above the longest required chain (16 entries), and a guard before each append stops with a visible 'chain too long' outcome.
- **length**: The output line buffer is sized for the longest chain at about 30 characters per entry and each append is guarded by the remaining capacity.
- **termination**: All unbounded loops (trial division, chain iteration) sit in procedures, which get no termination check, though the trial-division run of up to about 4e8 steps is slow rather than unprovable.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints one chain line per integer from 2 to 20.

Assessed on 2026-10-15 against page revision 415077 of the [task](https://rosettacode.org/wiki/Home_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
