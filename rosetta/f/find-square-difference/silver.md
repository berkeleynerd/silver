# Find square difference

**Candidate: proofs likely to discharge automatically.** N is bounded by the loop range 1 .. 1000, so N*N stays under 1,000,000 and nothing can overflow, and Answer is only ever assigned N, which is within its declared range. The for loop terminates by itself and no check depends on a loop-carried value.

Position 38 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

An Answer variable of type Integer range 0 .. 1000 starts at 0, and a for loop over N in 1 .. 1000 tests Answer = 0 and then N*N - (N-1)*(N-1) > 1000, recording the first N that satisfies it. After the loop it prints Integer'Image (Answer) with Put_Line. The loop has no accumulator, so there is no loop-carried arithmetic and no exit statement is needed. About 12 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the single result line 501 via Put_Line.

Assessed on 2026-10-15 against page revision 412795 of the [task](https://rosettacode.org/wiki/Find_square_difference) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
