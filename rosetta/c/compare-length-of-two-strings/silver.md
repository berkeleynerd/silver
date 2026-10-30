# Compare length of two strings

**Candidate: proofs likely to discharge automatically.** All checks follow from fixed-size arrays, for-loop indexes and a length guard before concatenation, and there are no while loops, recursion or annotations needed, so proofs should discharge.

Position 964 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the four example strings as String constants of differing lengths plus a two-string comparison, with a Show procedure that prints the length image, a separator and the string. For the descending order, keep a fixed array of the four lengths and an index permutation, sort it by selection sort with for loops, and print through a case statement that maps each index to its constant. A guard on string length before concatenation rejects over-long input with a visible outcome. About 55 lines.

## Proof obligations to watch

- **length**: The line built from the image of the length, a separator and the string is bounded by a guard on the string's length (or a bounded subtype) so the concatenation cannot exceed the index range.
- **index**: The selection sort over a fixed 4-element permutation array uses for-loop indexes over the array's own range, so every index check follows from the types.

## Language surface recorded by this assessment

'Image of scalars, string building, arrays, ranged subtypes, integers, for loops, case statements, procedures and unconstrained arrays.

## External effects

- **console output** (allowed): Prints each string with its length, longest first, via Put_Line.

Assessed on 2026-10-15 against page revision 415297 of the [task](https://rosettacode.org/wiki/Compare_length_of_two_strings) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
