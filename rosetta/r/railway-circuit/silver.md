# Railway circuit

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded types, for-loop indexes and mod arithmetic, and the only loop-carried values needing guards are the four coordinate accumulators and the mask rotations, with no recursion, heap use or annotation needed. The brute-force enumeration of 2**20 masks is a runtime cost, not a proof burden, and the optional n >= 24 counts and straight-track variants are left out.

Position 943 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Each circuit is a bitmask of n turns (n = 12, 16, 20), enumerated by a for loop over all 2**n masks in a procedure. A mask is kept only if its turn sum is +12 (net 360 degrees) and its exactly-tracked position, held as integer coefficients of 1 and sqrt(3) from a constant 12-entry direction table, returns to the origin. It is then printed only if it is the minimum over all n rotations and reversals, so the duplicates are removed without a stored set; each kept mask is printed through a fixed-length character buffer and counted. About 130 lines.

## Proof obligations to watch

- **overflow**: The four exact-geometry coordinate accumulators (integer parts of a + b*sqrt(3), scaled by 2) are loop-carried, so each step is computed in a wide integer and assigned only after a visible range guard that rejects the candidate, since a loop-carried subtype alone would fail the range check.
- **range**: Rotation and reversal of the turn bitmask stay inside 0..2**20-1 by using mod 2**n and division before assignment, which the type range plus those operations make provable without an invariant.
- **index**: All array and output-string indexes come from for loops over the arrays' own ranges, or from the direction index kept in 0..11 by mod, so they discharge.
- **floating point**: Floating point is avoided by representing cos and sin of multiples of 30 degrees as exact integer pairs over {1, sqrt(3)}, so closure is an integer equality test.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, procedures, functions, Boolean objects, string indexing, string building, 'Image of scalars and conditional expressions.

## External effects

- **console output** (allowed): Prints each distinct circuit as a Right=1/Left=-1 turn list and the counts for n = 12, 16, 20.

Assessed on 2026-10-15 against page revision 408762 of the [task](https://rosettacode.org/wiki/Railway_circuit) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
