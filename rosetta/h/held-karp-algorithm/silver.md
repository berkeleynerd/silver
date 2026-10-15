# Held–Karp algorithm

**Candidate: proofs plausibly discharge automatically.** Everything is bounded by a fixed city count and small integer ranges, using only for loops and a procedure, so checks follow from types and guards without any variant or invariant; the main risk is the loop-carried mask and city in path reconstruction.

Position 717 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the 4-city cost matrix as a constant 2D array of a ranged cost subtype, and hold subset masks as Integer 0..15 with a constant array of powers of two for bit tests via / and mod. Fill dp and parent tables with nested for loops in increasing mask order (submasks are numerically smaller), then take the minimum closing cost, reconstruct the tour with a fixed-count for loop with guards, and print with Put and Integer'Image. About 95 lines.

## Proof obligations to watch

- **overflow**: Costs are a ranged subtype (0..1_000_000 with a sentinel) and edge weights are capped at 1000, so dp plus edge always fits Integer and the update is guarded by a comparison against the stored value.
- **index**: Subset masks are subtype 0..15 and bit tests use division by a constant power-of-two array, so indexes into the 16x4 tables follow from declared ranges, but clearing a bit needs an explicit guard that the bit is set to avoid a negative mask.
- **range**: Loop-carried values in path reconstruction (current mask, current city, parent index) have no invariant, so each is a ranged subtype with a guard before use and the loop is a bounded for loop of N steps.
- **initialization**: The dp and parent tables must be fully initialized by nested for loops before reads, which GNATprove usually accepts for whole-array loops over the array's own ranges but sometimes needs care for 2D arrays.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the minimum tour cost and the tour of city indices.

Assessed on 2026-10-15 against page revision 413741 of the [task](https://rosettacode.org/wiki/Held%E2%80%93Karp_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
