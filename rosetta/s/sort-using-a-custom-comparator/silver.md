# Sort using a custom comparator

**Candidate: proofs likely to discharge automatically.** Every loop is a for loop over a range bounded by declared constants, and every index and length is bounded by ranged subtypes, so all checks follow from types and static bounds without invariants. Using a hand-written sort with a callback-style comparison function rather than a library sort keeps it free of generics and while loops.

Position 887 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Each string is a record with a ranged Length (0..16) and a fixed 16-character buffer, and the sixteen example strings sit in a constant-sized array of such records copied into a variable array. A pure Before function orders by descending length, then compares characters pairwise case-insensitively in a for loop over the common length, and a nested for-loop bubble sort in a procedure swaps neighbours when Before holds for the pair. Output prints the array before and after the sort with Put_Line on slices of each buffer. About 70 lines.

## Proof obligations to watch

- **index**: Bubble-sort neighbours at J and J+1 are discharged because J ranges over 1 .. Count-I within a Count-element array, and character slices use a stored length bounded by the buffer capacity via a ranged subtype.
- **range**: Case folding is done by Character'Pos arithmetic that is guarded by a test that the character is in 'a'..'z', so the offset result stays within Character.

## Language surface recorded by this assessment

Ranged subtypes, characters, arrays, records, string indexing, string building, for loops, procedures, functions, Boolean objects, integers and conditional expressions.

## External effects

- **console output** (allowed): The unsorted and sorted lists are printed one string per line with Put_Line.

Assessed on 2026-10-15 against page revision 413525 of the [task](https://rosettacode.org/wiki/Sort_using_a_custom_comparator) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
