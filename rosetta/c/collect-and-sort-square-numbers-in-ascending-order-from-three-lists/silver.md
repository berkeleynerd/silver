# Collect and sort square numbers in ascending order from three lists

**Candidate: proofs likely to discharge automatically.** Every check follows from declared ranges, for-loop indexes and one capacity guard before appending, so no loop invariant is needed and the proofs should discharge. The only new surface is arrays, ranged subtypes, for loops, integer Image and unterminated output.

Position 653 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the three lists as constant arrays of subtype-ranged Integers, and in a main procedure append each element that equals r*r for some r in 0..13 (found by a nested for loop) to a 26-slot result array with a guarded count. Then selection-sort the collected prefix with nested for loops and swaps, and print the values with Image and Put, separated by spaces. No while loops, recursion or contracts are needed. About 55 lines.

## Proof obligations to watch

- **index**: The collected count is loop-carried, so the append is guarded by an explicit capacity test (count below 26) with a Reject outcome, and the selection-sort for loops index within the count subtype's range.
- **overflow**: Image conversion of values up to 169 and the r*r square test with r in 0..13 stay far inside Integer, so they are routine.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, 'Image of scalars, Put without a newline, Boolean objects and string building.

## External effects

- **console output** (allowed): Prints the sorted squares, one per line or on one line.

Assessed on 2026-10-15 against page revision 394674 of the [task](https://rosettacode.org/wiki/Collect_and_sort_square_numbers_in_ascending_order_from_three_lists) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
