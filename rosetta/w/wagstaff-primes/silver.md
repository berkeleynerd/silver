# Wagstaff primes

**Candidate: proofs likely to discharge automatically.** The first 10 Wagstaff primes need p up to 61 and m below 2^63, so plain bounded integers and for-loop trial division suffice with all checks following from subtype ranges and guards. No annotations are needed, though the trial division runs roughly a billion iterations worst case at runtime.

Position 336 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Loop p over the range 3..61, test p prime by trial division and compute m = (2^p + 1)/3 in a 63-bit ranged integer type by repeated doubling in a for loop. Test m prime in a function using a for loop over odd divisors up to a fixed bound covering the subtype (sqrt of 2^62), exiting when the divisor exceeds N / divisor or divides N. Print each hit with Put_Line using 'Image concatenation; the 14-exponent stretch is omitted as optional. About 45 lines.

## Proof obligations to watch

- **overflow**: 2^p+1 with p at most 61 fits a 63-bit subtype, discharged by declaring p as a range 3..61 and computing the power by a bounded for-loop doubling guarded by the subtype range (or ** with that range).
- **termination**: The trial-division function uses only a for loop over a fixed range (with exit), so it terminates without a variant.
- **range**: The divisor 2*D+3 over a fixed D range stays inside the number subtype, and N / Divisor is guarded by Divisor being at least 3.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each of the first 10 exponents p and its Wagstaff prime, one line each.

Assessed on 2026-10-15 against page revision 414023 of the [task](https://rosettacode.org/wiki/Wagstaff_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
