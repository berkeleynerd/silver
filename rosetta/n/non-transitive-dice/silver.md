# Non-transitive dice

**Candidate: proofs likely to discharge automatically.** Every die is a 4-element array over a 1..4 subtype and all loops are bounded for loops over fixed 35-entry ranges, so index and range checks follow from types and the only loop-carried values (counters) are guarded just before use.

Position 676 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Enumerate the 35 sorted dice with four nested for loops (b in a..4, c in b..4, d in c..4) into a 35x4 table of faces subtype 1..4, then fill a 35x35 comparison table of -1, 0, 1 by counting winning face pairs in a 4x4 loop with guarded increments. Search ordered triples and quadruples of die indices with nested for loops over the comparison table (S<T, T<U, S>U, and the four-dice analogue), storing matches in fixed-capacity index arrays behind capacity guards, then print the counts and each list using 'Image and Put. About 130 lines.

## Proof obligations to watch

- **overflow**: The face-win counters are loop-carried, so each increment is guarded by a test against the counter's maximum of 16 (never taken in practice), which lets the prover discharge the range check without an invariant.
- **index**: The die count and result counts are loop-carried, so each store into the 35-entry die table or the fixed-capacity result tables is guarded by a capacity test just before the write, and the capacities are sized for the known 35 dice, 3 triples and 4 quadruples with spare room.
- **termination**: All iteration is bounded for loops inside procedures (face enumeration with a <= b <= c <= d, the 4x4 comparison, and the 35^3 and 35^4 index loops), so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, procedures, functions, Put without a newline, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the die count and each ordered list of three and four non-transitive dice to standard output.

Assessed on 2026-10-15 against page revision 413805 of the [task](https://rosettacode.org/wiki/Non-transitive_dice) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
