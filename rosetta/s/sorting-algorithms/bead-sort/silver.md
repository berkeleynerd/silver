# Sorting algorithms/Bead sort

**Candidate: proofs likely to discharge automatically.** All loops are for loops over array ranges with small declared subtypes, so index and overflow checks follow from types and local guards, and no variant or invariant is needed.

Position 96 in the [progression](../../../progression.md#stage-4), in stage 4.

## Approach

Embed the 8-element example as a constant array of a Value subtype (1..20), then run bead sort in a procedure using a Poles array indexed 1..20 and an array of 8 elements, with for loops only. Beads are dropped by counting per pole (guarded increment), and the sorted output is rebuilt by a second for loop comparing each row index against the pole counts, then printed with Put_Line using Image conversions in a bounded buffer or per-element Put. About 45 lines.

## Proof obligations to watch

- **index**: Pole counts are indexed by bead value, which a declared Value subtype of 1..20 keeps within the poles array range.
- **overflow**: Pole counters are bounded by the element count of 8 via a subtype range, and each increment is guarded by a comparison before the add since loop-carried values lose their bounds.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the unsorted and sorted embedded arrays.

Assessed on 2026-10-15 against page revision 414489 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Bead_sort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
