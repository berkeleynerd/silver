# Nested function

**Candidate: proofs likely to discharge automatically.** The nested-scope counter modification is expressible with nested procedures (functions cannot have side effects), and all checks follow from a ranged counter, a guard before the increment and bounded string lengths.

Position 952 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Main declares a Counter of small ranged subtype and a nested procedure Make_List taking the separator ". "; inside it a nested procedure Make_Item (not a function, since it modifies the outer counter) guards and increments Counter, then builds a bounded item string from the counter image, separator and name. Make_List calls Make_Item for "first", "second", "third" and prints each with Put_Line. About 35 lines.

## Proof obligations to watch

- **overflow**: The counter increment is guarded by a test against the subtype's upper bound just before the addition, so it discharges.
- **length**: Concatenated item text has a statically bounded length from the 'Image of a small ranged subtype plus fixed literals, so assignment to the fixed-length buffer is checkable.

## Language surface recorded by this assessment

Integers, ranged subtypes, 'Image of scalars, string building, unconstrained arrays, procedures and for loops.

## External effects

- **console output** (allowed): Prints the three list lines with Put_Line.

Assessed on 2026-10-15 against page revision 414357 of the [task](https://rosettacode.org/wiki/Nested_function) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
