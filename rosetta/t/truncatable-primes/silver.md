# Truncatable primes

**Candidate: proofs likely to discharge automatically.** Every loop is a for loop over static ranges with all indexes bounded by subtypes or guards, so no invariants or variants are needed and the sieve and truncation checks should discharge routinely.

Position 171 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A Boolean sieve array over 0..999_999 is filled using nested for loops (I in 2..1000, K in I..Max/I marking I*K), and the program scans N downward with a reverse for loop. For each prime it checks left truncation using a constant table of powers of ten (N mod Power(K) must be prime and the digit must be nonzero) and right truncation via repeated N/10 in a bounded for loop, recording the first success and printing both results with Integer'Image. About 60 lines.

## Proof obligations to watch

- **overflow**: The sieve index I*K is bounded by the for-loop upper bound K in I..Max/I with I at most 1000, which provers should discharge though it is mildly nonlinear.
- **index**: Truncation arithmetic (N mod Power(K), N / 10) stays within 0..999_999 by subtype ranges, so Composite indexing is safe, with a guard to skip zero digits before use.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the largest left-truncatable and right-truncatable primes below one million.

Assessed on 2026-10-15 against page revision 414556 of the [task](https://rosettacode.org/wiki/Truncatable_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
