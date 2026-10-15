# Primality by trial division

**Candidate: proofs likely to discharge automatically.** Every check (mod by a nonzero constant-range divisor, bounded arithmetic) follows from the subtype ranges and a for loop with a fixed upper bound, so no variant or invariant is needed; the only subtlety is replacing the Sqrt/float bound with an integer guard, which stays faithful to trial division.

Position 316 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Define a bounded subtype of Integer (for example 0 .. 1_000_000) for candidates and a Boolean function Is_Prime that returns False for N below 2, True for 2, False for even N, then runs a for loop over K in 1 .. 500 (or a bound derived from the subtype's maximum square root) testing divisor 2*K+1 and returning False when N mod divisor = 0 and the divisor squared exceeds nothing (checked via divisor <= N / divisor guard before testing). A main procedure loops over embedded sample values and prints each verdict with Put_Line, using Boolean-to-text via an if statement. About 40 lines.

## Proof obligations to watch

- **overflow**: The divisor loop is bounded by a Long_Long_Integer-range or small-range candidate, and the guard Test <= N / Test (never Test*Test) keeps all arithmetic in range.
- **termination**: The is-prime logic is a function, so it uses a for loop over a fixed range 1 .. 2**30 style bound (exit by early return) with Test = 3 + 2*K computed in range, avoiding a while loop that would need a variant.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the primality verdict for embedded test values with Put_Line.

Assessed on 2026-10-15 against page revision 414879 of the [task](https://rosettacode.org/wiki/Primality_by_trial_division) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
