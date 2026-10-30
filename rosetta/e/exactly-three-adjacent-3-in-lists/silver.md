# Exactly three adjacent 3 in lists

**Candidate: proofs likely to discharge automatically.** All indexes come from for-loop ranges over the array bounds (I+2 is at most 9 because I is at most 7), and loop-carried state is only Boolean, so every check follows from static bounds and no invariant or variant is needed.

Position 1536 in the [progression](../../progression.md#stage-32), in stage 32.

## Approach

The five lists are embedded as a constant 5 by 9 Integer array aggregate, and a procedure loops over rows with for loops. For each row, a for loop over run starts 1..7 checks that the three cells at I, I+1, I+2 equal 3, then an inner for loop over 1..9 clears an Ok flag if any cell outside that window equals 3, and the row prints true if any window passes. Only Boolean flags are carried through loops, with no counters or accumulators. About 45 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, procedures and membership tests.

## External effects

- **console output** (allowed): Prints true or false for each of the five lists with Put_Line.

Assessed on 2026-10-15 against page revision 415475 of the [task](https://rosettacode.org/wiki/Exactly_three_adjacent_3_in_lists) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
