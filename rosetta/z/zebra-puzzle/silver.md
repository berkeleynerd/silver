# Zebra puzzle

**Candidate: proofs likely to discharge automatically.** Every check follows from subtype ranges, for-loop indexes over array ranges and one counter guard, with no recursion, no while loops and no annotations, so proofs should discharge automatically. The brute-force search cost is a run-time cost and not a proof obligation.

Position 682 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Houses are a subtype 1..5 and each of the five attributes (colour, nationality, drink, smoke, pet) is one row of a 120 by 5 permutation table, built once by five nested for loops that skip repeated values. Five nested for loops over table rows test each clue as early as its attributes are chosen, using integer comparisons and abs differences on house positions, and the solution is printed once found through fixed-length name strings. The search uses only for loops in a procedure, so the only loop-carried value is the table counter and there are no termination checks. About 130 lines.

## Proof obligations to watch

- **index**: The permutation table is filled by nested for loops with a loop-carried row counter, so each write is preceded by an explicit guard that the counter is below 120, and the later search indexes the table only with for-loop variables over its own range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops and procedures.

## External effects

- **console output** (allowed): Prints the five houses with their drink, nationality, colour, smoke and pet, ending with who owns the zebra, via Put_Line.

Assessed on 2026-10-15 against page revision 414998 of the [task](https://rosettacode.org/wiki/Zebra_puzzle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
