# Word break problem

**Candidate: proofs plausibly discharge automatically.** The task is small and bounded: all checks come from fixed array ranges, for-loop indexes, and guards on slice bounds and buffer room, with no recursion or annotations needed. The only care points are the loop-carried backtracking position and output buffer capacity, hence plausible rather than likely.

Position 1023 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the dictionary (a, bc, abc, cd, b) as one constant String plus a constant array of start and length records, and embed the five test strings. A procedure Break_Words does dynamic programming over prefix ends with for loops, comparing each dictionary word slice to the input slice ending at that position and recording a reachable flag and a predecessor/word index per prefix. If the full length is reachable, a while loop backtracks through guarded predecessors to collect word indices, then builds the space-separated result in a bounded buffer with capacity guards, and the main procedure prints it or "can't break". About 110 lines.

## Proof obligations to watch

- **index**: Slice bounds for dictionary words and for the input prefix are computed from loop-carried positions, so each slice is guarded by an explicit start and length check just before the comparison.
- **length**: The output buffer has fixed capacity, so before appending each word and separator the program checks the remaining room and reports a visible 'result too long' outcome otherwise.
- **range**: The backtracking loop reads a predecessor position from an array, so it checks that the predecessor is smaller than the current position before moving, which also ends the loop.
- **termination**: The backtracking while loop lives in a procedure, which gets no termination check, so no variant is needed.
- **initialization**: The reachability and predecessor arrays are fully initialized by aggregates before the loops read them.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, records, unconstrained arrays, string indexing, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Each test string and its segmentation (or a can't-break message) is printed with Put_Line.

Assessed on 2026-10-15 against page revision 409625 of the [task](https://rosettacode.org/wiki/Word_break_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
