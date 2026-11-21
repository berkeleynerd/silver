# Greatest element of a list

**Candidate: proofs likely to discharge automatically.** Every check is an array index inside a for loop over the array's own range, guarded by an explicit emptiness test, and the running maximum is always an element of integer type, so no overflow arises and no invariant is needed. The empty-list case has a specified visible outcome rather than an exception.

Position 1039 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Declare an integer array type over a bounded Positive index subtype, and a procedure Find_Max taking an unconstrained array that sets a Found flag and the maximum. It returns Found = False for an empty array, otherwise seeds the maximum with the first element and loops over Item'Range comparing each element. Main embeds a sample list and an empty list, printing the maximum or a clear "empty list" message for each. About 35 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, unconstrained arrays, procedures, for loops, 'Image of scalars and conditional expressions.

## External effects

- **console output** (allowed): The maximum (or an explicit empty-list message) is printed with Put_Line.

Assessed on 2026-10-15 against page revision 415509 of the [task](https://rosettacode.org/wiki/Greatest_element_of_a_list) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
