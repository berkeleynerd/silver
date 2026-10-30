# English cardinal anagrams

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded types, array ranges and capacity guards, but the quadratic grouping with loop-carried counters and the buffer-append guards demand careful program shape, and no annotation is needed.

Position 854 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Each number 0..10000 is spelled into a bounded 64-character buffer by a non-recursive procedure using divisions by 10, 100 and 1000 and case statements that append word literals, then letters are tallied into a 26-entry count signature per number. Anagram groups are found by comparing signatures in nested for loops, recording each number's group leader and group sizes, then the first thirty members, the count and the largest groups are collected into bounded arrays and printed with Put_Line on lines built from the integer images. About 230 lines.

## Proof obligations to watch

- **index**: Appending words to the fixed 64-character name buffer is guarded by a remaining-capacity check before each append, and the longest name (about 42 characters) fits well within the bound.
- **range**: Letter counts per number and group sizes are held in subtypes bounded by 64 and 10001, so loop-carried increments need a guard just before each increment.
- **overflow**: The ten-thousand-by-twenty-six signature table and the quadratic pairwise grouping use only for loops over the arrays' own ranges, so index and counter checks follow from types.
- **termination**: All loops are for loops or while loops inside procedures, and the number-to-words logic uses case and division on bounded values with no recursion.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the first thirty anagram numbers, the counts and the largest groups as text lines.

Assessed on 2026-10-15 against page revision 394388 of the [task](https://rosettacode.org/wiki/English_cardinal_anagrams) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
