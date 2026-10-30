# Number names

**Candidate: proofs plausibly discharge automatically.** All arithmetic is div/mod by literals on declared subtypes and the buffer appends are guarded, so checks follow from types and guards with no recursion or annotations, though careful loop shape is needed for the buffer length.

Position 1017 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Words are returned by non-recursive functions using case statements over small ranged subtypes (0..19 and 2..9), and a procedure splits the number (range 0..999_999_999, covering the required one million) into three-digit groups with a for loop from the millions group down. It appends each group's words, the scale name and the separators to a fixed 300-character buffer with an explicit length, using an Append procedure that guards capacity and sets an overflow flag, then prints the number image and the buffer slice for an embedded list of sample values including zero. Negative numbers are left out as optional, and an out-of-range sample prints a visible rejection. About 170 lines.

## Proof obligations to watch

- **length**: Appending words to a fixed 300-character buffer in a loop has a loop-carried length, so every Append guards Length + Word'Length against capacity and sets a visible overflow flag that makes the caller print a rejection line instead of a silent truncation.
- **range**: Dividing a number in 0..999_999_999 into triplets and tens/units uses div and mod by literals on a ranged subtype, so each quotient and remainder is bounded by its subtype and discharges, but the loop-carried remainder must stay in a declared subtype rather than Integer.
- **index**: Converting a digit value 0..19 or 2..9 into a word relies on case statements covering the whole subtype range, so no table indexing by a computed value is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, case statements, for loops, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): Each embedded sample number and its spelled-out English name is printed with Put_Line.

Assessed on 2026-10-15 against page revision 414361 of the [task](https://rosettacode.org/wiki/Number_names) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
