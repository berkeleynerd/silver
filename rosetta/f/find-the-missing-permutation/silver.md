# Find the missing permutation

**Candidate: proofs likely to discharge automatically.** All indices come from for-loop ranges over a constant String, and the only loop-carried values are small column sums protected by explicit guards, with the final letter conversion guarded before use. No loop invariant, recursion or while loop is needed, so every check should discharge from types and guards.

Position 878 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The 23 given permutations are embedded as one 92-character String constant, and a nested for loop over rows 0..22 and columns 1..4 adds each letter's value (Character'Pos minus Character'Pos of 'A' plus 1) to a four-element Integer sum array. Each full column would total 60, so the missing letter for a column is the letter whose value is 60 minus the column sum; a guard checks that value is 1..4 before Character'Val builds each letter into a 4-character String, and an out-of-range value prints a rejection message instead. The result is printed with Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The four column sums are loop-carried, so each addition is guarded by a bound test just before it, or the sums use a type whose range makes the addition safe.
- **range**: The expression 60 minus the column sum is only converted to a letter after an if guard checks it lies in 1..4, with a rejection message otherwise.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, string building, arrays, for loops and conditional expressions.

## External effects

- **console output** (allowed): The program prints the missing permutation with Put_Line.

Assessed on 2026-10-15 against page revision 413721 of the [task](https://rosettacode.org/wiki/Find_the_missing_permutation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
