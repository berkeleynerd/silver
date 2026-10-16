# Range consolidation

**Candidate: proofs plausibly discharge automatically.** All task data fit a scaled-integer representation, so every check follows from ranged types, for-loop indexes and capacity guards without needing loop invariants. Floating point is avoided, leaving only the loop-carried write index and text buffer length as guard-dependent obligations.

Position 944 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Represent each bound as an integer count of tenths (the task data all have one decimal place) in a record of two bounds, with five embedded sets held in fixed arrays of capacity 5 plus a count. A procedure normalizes each pair by swapping bounds, insertion- or bubble-sorts by lower bound using for loops, then makes one pass merging each range into the current one when its lower bound is at most the current upper bound, writing results to an output array with a guarded write index. Output formatting converts tenths to decimal text with / and mod and 'Image into a bounded buffer, then prints one line per set with Put_Line. About 130 lines.

## Proof obligations to watch

- **overflow**: Bounds are stored as tenths in a ranged subtype (about -1000..1000) and only compared, min/max'd and printed, so no arithmetic can overflow.
- **index**: The output write position grows in a loop, so each increment is guarded by a comparison with the array capacity that rejects visibly, since no invariant can show output count never exceeds input count.
- **range**: The count of ranges is a bounded subtype (0..5) and the sort and merge loops use for-loop indexes over the array's own range, with the neighbour index guarded just before use.
- **length**: Output text is built in a fixed-size buffer sized for the largest line (up to 5 ranges of about 12 characters), with each append guarded by the remaining capacity.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, string building, 'Image of scalars, for loops, procedures, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints each input range set and its normalized consolidated result as text lines.

Assessed on 2026-10-15 against page revision 414011 of the [task](https://rosettacode.org/wiki/Range_consolidation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
