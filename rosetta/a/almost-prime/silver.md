# Almost prime

**Candidate: proofs likely to discharge automatically.** All values are small (at most 176), every divisor is a for-loop index of at least 2, and the only loop-carried arithmetic needs simple guards, with no annotation needed because loops live in procedures.

Position 199 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A procedure counts prime factors with multiplicity by trial division, using a for loop over divisors 2 to 200 with an inner while loop that divides out each divisor, on a remaining-value variable. The main loop runs k from 1 to 5, scans candidates from 2 up to a fixed bound of 200 (the largest needed value is 176), counts matches until ten are found, and prints each with Put and the Image attribute then ends the line. Candidate and match counters are guarded against exceeding their bounds before incrementing. About 45 lines.

## Proof obligations to watch

- **overflow**: The loop-carried prime-factor count is only known by its type after the first iteration, so the increment is guarded by a test that the count is below a small limit or uses a subtype whose range is large enough.
- **division**: The divisor is a for-loop index over a range starting at 2, so mod and division by it are never by zero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the table of the first ten k-almost primes for each k from 1 to 5.

Assessed on 2026-10-15 against page revision 415332 of the [task](https://rosettacode.org/wiki/Almost_prime) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
