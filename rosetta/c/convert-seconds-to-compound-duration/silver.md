# Convert seconds to compound duration

**Candidate: proofs likely to discharge automatically.** Every division is by a non-zero literal, quantities are bounded by the ranged input subtype so no overflow can occur, and the only loop-carried value (buffer length) is guarded by capacity tests before each append, so no annotation is needed.

Position 519 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A ranged Seconds subtype holds each embedded test value (7259, 86400, 6000000), and a procedure splits it with mod and / into a five-element array of quantities (weeks, days, hours, minutes, seconds). A for loop over the array index appends, for each non-zero quantity, a separator, the trimmed 'Image digits and the unit suffix into a fixed 64-character buffer with a length counter, guarded before each append, and the main procedure prints the buffer slice with Put_Line. About 70 lines.

## Proof obligations to watch

- **length**: The output buffer length is loop-carried through appends, so each append is guarded by a capacity test against a 64-character buffer sized well above the longest possible output, with a visible truncation-free reject path otherwise.
- **range**: The 'Image of the quantities is bounded by a ranged Seconds subtype (for example up to 100_000_000), so the digit count and the slice bounds are statically small.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, 'Image of scalars, string building, string indexing, arrays, for loops and procedures.

## External effects

- **console output** (allowed): Prints one formatted duration line per embedded test case with Put_Line.

Assessed on 2026-10-15 against page revision 414131 of the [task](https://rosettacode.org/wiki/Convert_seconds_to_compound_duration) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
