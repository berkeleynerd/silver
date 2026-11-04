# Cuban primes

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic in for loops with guards just before each use, so no annotation is needed, but loop-carried counters, the table index and the comma-formatting buffer need careful guarding and the nonlinear products rely on subtype ranges.

Position 390 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Use Long_Long_Integer values with ranged subtypes for n and the trial divisor; a for-loop Is_Prime function tries divisors 2 and odd d up to 2_000_000 and exits when d*d exceeds the candidate. A for loop over n in 1 .. 1_000_000 computes 3n(n+1)+1, counts primes with a guard before each increment, stores the first 200 in a constant-size array, and stops at the 100,000th. A procedure formats each value with thousands commas into a bounded buffer and prints it with Put, using Put_Line for row ends. About 90 lines.

## Proof obligations to watch

- **overflow**: The candidate 3n^2+3n+1 and d*d are computed in a 64-bit type with n and d declared as subtypes (n up to 1_000_000, d up to 2_000_000), so the maxima of about 3e12 and 4e12 are bounded by types alone.
- **termination**: Trial division and the main search are for loops with exit when, in functions, so termination needs no variant; the search range is sized so the 100,000th prime (n of about 773,000) is reached, else a visible not-found message is printed.
- **index**: The 200-entry table is written only under an explicit guard that the stored count is below 200, and the running count is bounded by a guard before each increment since no invariant can be supplied.
- **length**: Comma-formatted numbers are built in a fixed 20-character buffer filled from the right using a digit loop over a bounded value, with a guard on the position before each write.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 200 cuban primes in 14-column rows with commas, then the 100,000th cuban prime with commas.

Assessed on 2026-10-15 against page revision 414139 of the [task](https://rosettacode.org/wiki/Cuban_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
