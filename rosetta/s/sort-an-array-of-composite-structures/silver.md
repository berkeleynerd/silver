# Sort an array of composite structures

**Candidate: proofs likely to discharge automatically.** Every index is a for-loop variable whose range (1 .. N - Pass, with Pass at least 1) keeps I + 1 inside the array, there are no while loops or loop-carried accumulators, and equal-length fixed Strings make the comparison length-safe, so all checks follow from types and loop bounds.

Position 1469 in the [progression](../../progression.md#stage-28), in stage 28.

## Approach

A record type holds a Name and a Value as equal-length fixed Strings (space-padded), and a constrained array of five such records is initialised from an aggregate holding the task's example data. A procedure sorts it with a bubble sort made of two nested for loops (outer pass count, inner index 1 .. N - Pass) that compare the Name fields with String "<" or ">" and swap the whole records through a temporary. A final for loop prints each pair with Put_Line. About 45 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, records, string ordering, for loops and procedures.

## External effects

- **console output** (allowed): Prints the sorted name-value pairs with Put_Line.

Assessed on 2026-10-15 against page revision 411827 of the [task](https://rosettacode.org/wiki/Sort_an_array_of_composite_structures) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
