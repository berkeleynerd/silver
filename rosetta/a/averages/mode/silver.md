# Averages/Mode

**Candidate: proofs plausibly discharge automatically.** All indexes and counters follow from ranged subtypes and for loops over array ranges, with only the guarded counter increment needing care, so no annotation is required.

Position 81 in the [progression](../../../progression.md#stage-6), in stage 6.

## Approach

Embed the task's 14-element integer vector as a constant array of a ranged subtype 1..6, tally occurrences in a counts array indexed by that same subtype with a guarded increment, then find the maximum count in a second for loop. A final for loop over the value range prints each value whose count equals the maximum, so ties (non-unique mode) are all reported. About 35 lines.

## Proof obligations to watch

- **overflow**: Incrementing a per-value counter inside the loop is loop-carried, so counters use a small ranged subtype (0..100) and the increment is guarded by a visible test, which is safe because only 14 elements are counted.
- **range**: Indexing the counts array by a data element needs the element type to be the same ranged subtype as the index (1..6), which makes the index check follow from types.
- **length**: Concatenating image strings into an output line needs a fixed-size buffer or per-value Put_Line with a statically bounded length, since Integer'Image length is bounded by the subtype range.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the input list and each mode value as text lines.

Assessed on 2026-10-15 against page revision 414066 of the [task](https://rosettacode.org/wiki/Averages/Mode) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
