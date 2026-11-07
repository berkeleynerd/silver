# Averages/Simple moving average

**Candidate: proofs plausibly discharge automatically.** All checks follow from ranged subtypes, bounded arrays and guards, but the loop-carried window sum and the bounded-buffer decimal formatting require careful shaping because no invariants can be written.

Position 619 in the [progression](../../../progression.md#stage-11), in stage 11.

## Approach

Each moving-average state is a record holding a fixed-capacity ring-buffer array of small ranged integers, a count capped at the period and a next-write index, so two instances (periods 3 and 5) keep separate state without closures. A procedure with an in out state parameter inserts a value (wrapping the index with an explicit guard), then a function sums the filled window with a for loop and divides by the count (never zero after insertion, guarded anyway), and the main procedure runs the 1..5 then 5..1 sequence printing integer and fixed-point decimal text. About 110 lines.

## Proof obligations to watch

- **overflow**: The window sum is a loop-carried accumulator over at most 5 elements of a small ranged subtype, so it discharges only if the loop is short enough for GNATprove to unroll or the accumulator type is wide enough to hold the maximum, with no invariant available.
- **index**: The ring-buffer position is a modular-style index kept in a ranged subtype and wrapped by an explicit if guard (reset to first index at the end) rather than arithmetic, so indexing stays in bounds.
- **length**: Output lines are assembled in a fixed-size bounded buffer with decimal digits computed from scaled integer division, so each concatenation needs guards or statically sized pieces to keep lengths within the buffer.
- **floating point**: Floating point is avoided by using integer arithmetic scaled by 100000 for the five-decimal average, which is exact enough for the sample outputs but is a documented format choice rather than Float'Image output.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, records, for loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each insertion and its moving average line by line.

Assessed on 2026-10-15 against page revision 413649 of the [task](https://rosettacode.org/wiki/Averages/Simple_moving_average) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
