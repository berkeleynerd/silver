# Last list item

**Candidate: proofs plausibly discharge automatically.** All checks follow from ranged subtypes, for-loops over the array's own range and one explicit sum guard, with the outer while loop in a procedure, but the text-building of each step line is the fiddly part. Nothing needs an annotation, so discharge is plausible rather than certain.

Position 262 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Keep the list in a nine-element array of a ranged integer subtype with a separate length variable, initialised from the task's data. While the length is at least 2, print the list, find the index of the smallest item by a for loop, remove it by shifting, repeat for the second smallest, guard the sum against the subtype's upper bound (rejecting on overflow), append it, and finally print the single remaining item. Output lines are built from integer images into a bounded buffer and written with Put_Line. About 90 lines.

## Proof obligations to watch

- **overflow**: The sum of the two smallest items is checked against the element subtype's upper bound with a guard that rejects with a visible message, so the stored value and the addition both discharge from declared ranges.
- **index**: The smallest-item search and the shift-down removal use for loops over the current length, with the length a ranged subtype of 0 .. 9, so every index stays within the array bounds.
- **termination**: The outer while loop sits in a procedure, which gets no termination check, and it strictly shrinks the length each pass.
- **length**: Each printed line is assembled in a bounded buffer sized for nine items of the maximum digit width, and the line-building code needs guards before each append.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints each step (the list, the two smallest items and their sum) and the final list as text lines.

Assessed on 2026-10-15 against page revision 414786 of the [task](https://rosettacode.org/wiki/Last_list_item) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
