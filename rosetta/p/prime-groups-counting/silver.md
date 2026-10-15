# Prime groups, counting

**Candidate: proofs plausibly discharge automatically.** All checks follow from fixed bounds, a 0..255 prime table and guards before each loop-carried update, and the search is a while loop confined to a procedure so no variant is needed, but the explicit-stack search and counter guards need careful shape.

Position 1360 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Read one line into a bounded buffer of at most 32 characters (rejecting longer input), build a constant Boolean prime table for 0..255, and precompute a pairwise-compatibility matrix from absolute differences of character codes. Count every subset of two or more positions that is pairwise compatible using an iterative depth-first search in a procedure with an explicit fixed-size stack of positions, guarding stack depth and the counter before each update, then print the count. About 90 lines.

## Proof obligations to watch

- **overflow**: The group counter is loop-carried, so each increment is guarded against its type maximum with a visible reject outcome, and the length limit of 32 keeps real counts far below it.
- **index**: The explicit DFS stack and character positions are loop-carried, so each push and read is guarded by a test on the depth and position just before use.
- **range**: Character'Pos differences are computed in a wider integer subtype so they fit the 0..255 prime table index.
- **termination**: The search uses while loops only inside a procedure, which gets no termination check.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, 'Image of scalars, for loops, while loops, procedures, standard input, exit status, string building and conditional expressions.

## External effects

- **standard input** (allowed): Reads one line of text from standard input.
- **console output** (allowed): Prints the final count, or a rejection message for invalid input.
- **exit status** (allowed): Rejected input (an over-long line) needs a specified non-zero exit outcome.

Assessed on 2026-10-15 against page revision 406976 of the [task](https://rosettacode.org/wiki/Prime_groups,_counting) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
