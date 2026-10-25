# Shift list elements to left by 3

**Candidate: proofs likely to discharge automatically.** All indexes are for-loop indexes over static constant bounds and the element values are small embedded literals, so every check follows from types and static ranges with no loop-carried state.

Position 48 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Store the nine integers in a constrained array indexed 1..9 with a constant shift of 3, and build the result array with a for loop assigning Result(I) := Source(((I - 1 + 3) mod 9) + 1) (or two for loops copying 4..9 then 1..3 to avoid mod). A Print procedure loops over the array range, emitting each element with Put of its image, followed by a line terminator via Put_Line. About 35 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the list before and after the shift to standard output.

Assessed on 2026-10-15 against page revision 406577 of the [task](https://rosettacode.org/wiki/Shift_list_elements_to_left_by_3) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
