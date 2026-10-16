# Remove duplicate elements

**Candidate: proofs likely to discharge automatically.** The quadratic scan uses only for loops, bounded arrays and a guarded counter, so every index and range check follows from types and one explicit guard with no annotations needed.

Position 204 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embed the example array (1,2,3,4,5,5,6,7,1) as a constant array of Integer in a small range, and use the O(n^2) approach: an outer for loop over the input's range, an inner for loop over the already-kept prefix with a Boolean Seen flag, and append to a fixed-capacity output array only when not seen. Finally a for loop over the kept prefix prints each element with Integer'Image through Put_Line, using a guarded Count variable for the output length. About 45 lines.

## Proof obligations to watch

- **index**: The output count is a loop-carried value, so it is declared with a range subtype equal to the array capacity and incremented only under an explicit guard that Count is below the capacity (the output array is as large as the input, so this guard always holds).
- **range**: The Count increment would not be provable from the type alone after the first iteration, so the guard Count < Capacity just before the increment discharges it.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, 'Image of scalars, string building, Put without a newline, procedures and Boolean objects.

## External effects

- **console output** (allowed): Prints the de-duplicated sequence with Put_Line, one element per line or as a built string.

Assessed on 2026-10-15 against page revision 414441 of the [task](https://rosettacode.org/wiki/Remove_duplicate_elements) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
