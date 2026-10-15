# Find squares n where n+1 is prime

**Candidate: proofs likely to discharge automatically.** Every check follows from small declared ranges (K*K at most 961, divisors within the value's range, Count at most 31) and for-loops over static ranges, so no invariant is needed.

Position 306 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A function Is_Prime takes a value in a subtype 2..1000 and uses a for loop over divisors 2..Value-1 with mod and an early return of False, so termination is automatic and no while loop is needed. The main procedure loops K over 1..31 with N = K*K held in a 1..961 subtype, calls Is_Prime (N+1), and prints N via 'Image concatenated into a Put_Line, with a Count of type 0..31 incremented only on hits and printed at the end. About 35 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each qualifying square and a final count with Put_Line.

Assessed on 2026-10-15 against page revision 415480 of the [task](https://rosettacode.org/wiki/Find_squares_n_where_n%2B1_is_prime) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
