# Calmo numbers

**Candidate: proofs likely to discharge automatically.** All loops are bounded for loops with small ranged types and the divisor sums are recomputed from bounded array elements, so every check follows from types and local guards.

Position 148 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A single Main procedure loops n from 2 to 999 with a for loop, scans d from 2 to n-1 counting divisors, then rescans, storing each divisor in a 3-element array of range 0..999 and, when the third slot fills, summing the three elements and testing primality by trial division in a for loop (a Boolean flag, no accumulators). Calmo numbers are printed one per line with 'Image, and an n with zero eligible divisors or a count not divisible by 3 is simply skipped. About 55 lines.

## Proof obligations to watch

- **overflow**: Triple sums are computed fresh from three array elements each bounded to 0..999 (at most 2997), so no loop-carried accumulator exists and the addition discharges from types alone.
- **index**: The slot index is a subtype 0..2 that is reset by a guard just before it would pass 2, so indexing the three-element array is checked locally.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each Calmo number found below 1000.

Assessed on 2026-10-15 against page revision 396847 of the [task](https://rosettacode.org/wiki/Calmo_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
