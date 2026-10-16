# Duffinian numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic is small and bounded by declared ranges, and the only loop-carried values (sigma sum, gcd pair, counters) can be tamed with simple guards or type ranges, so no annotation is needed. The work is mostly new surface (integers, loops, arrays, image-based string building), hence plausible rather than likely.

Position 924 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A procedure computes for each n in 4..8451 the divisor sum and count by a for loop over 1..n testing n mod d = 0, then a procedure-based Euclid gcd decides coprimality, storing results in a Boolean array indexed by a declared range. Two scans of that array output the first 50 Duffinian numbers and the first 15 runs of three consecutive true entries, with each output line built in a bounded String buffer from 'Image values. About 90 lines.

## Proof obligations to watch

- **overflow**: The divisor-sum accumulator is loop-carried, so each addition is guarded by a comparison against a bound far above any reachable sum (limit 8500, sigma below 100000), which never alters results.
- **termination**: The Euclid gcd loop is a while loop, so it lives in a procedure (no termination check) and its mod is guarded by the loop condition b /= 0.
- **length**: Output lines are assembled from Image of integers in fixed-size buffers, which requires bounded-length string building with explicit length guards.
- **range**: Candidate counters and triplet scanning are for-loops over a declared subtype with N+2 kept inside the range by limiting the scan to the declared maximum minus 2.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, procedures, functions, for loops, while loops, 'Image of scalars, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the first 50 Duffinian numbers and the first 15 triplets as text lines.

Assessed on 2026-10-15 against page revision 414171 of the [task](https://rosettacode.org/wiki/Duffinian_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
