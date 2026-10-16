# Maximum difference between adjacent elements of list

**Candidate: proofs likely to discharge automatically.** All data is embedded and bounded, the loops are for loops over the array's own index range, and the scaled-integer differences are bounded by the declared subtype range, so no loop invariant is needed.

Position 145 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Store the 17 sample values as an embedded constant array of integers in tenths (a ranged subtype, e.g. -100_000 .. 100_000), so -2.3 and 5.5 are exact. One for loop computes the maximum absolute adjacent difference into a variable of a wider ranged type, and a second for loop prints each pair whose difference equals it, formatting tenths as text via 'Image, / and mod and bounded concatenation. Indexes are I and I+1 within the loop range 1 .. 16, so every check follows from declared types. About 45 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each adjacent pair and its difference with Put_Line.

Assessed on 2026-10-15 against page revision 406162 of the [task](https://rosettacode.org/wiki/Maximum_difference_between_adjacent_elements_of_list) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
