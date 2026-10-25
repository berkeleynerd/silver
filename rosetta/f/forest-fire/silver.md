# Forest fire

**Candidate: proofs likely to discharge automatically.** All loops are for loops over constrained array ranges and the only loop-carried value is a ranged generator seed, so every index and overflow check follows from types and loop bounds without invariants.

Position 1166 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The forest is a constrained 10 by 40 array of an enumeration (Empty, Tree, Fire) whose border cells are never written and stay Empty, with a second array holding the next generation. A procedure advances a ranged-integer LCG seed, and probabilities p and f are integer percentages compared with the generator output; a nested for-loop over interior cells counts burning neighbours with a 3 by 3 offset loop and applies the four rules via a case statement, then copies the next grid back and prints rows with Put and Put_Line for a fixed number of generations. About 90 lines.

## Proof obligations to watch

- **index**: Moore-neighbour accesses use row and column offsets of plus or minus one, discharged because the loops run only over the interior range 2..Rows-1 and 2..Cols-1 of the constrained 2D array.
- **overflow**: The linear congruential generator state is a ranged subtype and each update multiplies a bounded value by a small constant before reducing with mod, so the intermediate stays within Integer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, enumerations, multidimensional arrays, for loops, case statements, procedures, Put without a newline and characters.

## External effects

- **console output** (allowed): Each generation of the forest is printed as text rows.

Assessed on 2026-10-15 against page revision 415027 of the [task](https://rosettacode.org/wiki/Forest_fire) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
