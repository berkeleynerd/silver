# McNuggets problem

**Candidate: proofs likely to discharge automatically.** Every check follows from fixed for-loop ranges, a static array bound and one explicit guard before the indexed store, and no loop-carried value needs an invariant. The only new work is arrays, for loops, integer arithmetic and integer-to-text conversion.

Position 120 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A Boolean array indexed 0..100 starts all False, and three nested for loops over 0..16, 0..11 and 0..5 mark each reachable total, guarded by if N <= 100. A final forward for loop over 1..100 records the largest index still False in an Integer variable, which is then printed through Put_Line with a concatenated Integer'Image. About 28 lines.

## Proof obligations to watch

- **index**: The array index N = 6x+9y+20z is guarded by an explicit N <= 100 test just before the store, and its lower bound of 0 follows from the nonnegative for-loop ranges.
- **overflow**: The loop ranges 0..16, 0..11 and 0..5 bound the sum to at most 295, which is trivially within Integer.

## Language surface beyond today's Silver

Integers, integer division, Boolean objects, arrays, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the largest non-McNugget number as one line.

Assessed on 2026-10-15 against page revision 414907 of the [task](https://rosettacode.org/wiki/McNuggets_problem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
