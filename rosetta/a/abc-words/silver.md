# ABC words

**Candidate: proofs likely to discharge automatically.** Every check follows from the bounded buffer type, for-loop indexes over 1 .. Length and comparisons of stored positions with no arithmetic, so no loop-carried value needs an invariant. The only non-routine parts are the library read operation and the guard rejecting over-long lines.

Position 1339 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

A main procedure loops while a line-reading library procedure reports a line, filling a fixed-capacity buffer with a Natural length (words are under 40 characters, capacity 64) and rejecting over-long lines. For each word a for loop over 1 .. Length records the first position of 'a', 'b' and 'c' in Natural variables (0 meaning absent), guarded by "still zero" tests. The word is printed with Put_Line when all three positions are nonzero and strictly increasing. About 60 lines.

## Proof obligations to watch

- **index**: A for loop over 1 .. Length indexes a fixed-capacity line buffer whose Length subtype is bounded by the capacity, so every index is in range by type.
- **length**: A line longer than the buffer capacity is rejected with a specified outcome by an explicit guard, so no length check can fail.
- **termination**: The read-until-end-of-input while loop lives in a procedure, which gets no termination check.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, string building, for loops, while loops, procedures, standard input and exit status.

## External effects

- **standard input** (allowed): The dictionary words are read line by line from standard input until end of input.
- **console output** (allowed): Each ABC word is printed on its own line.
- **exit status** (allowed): An over-long line or invalid input is rejected with a nonzero exit status.

Assessed on 2026-10-15 against page revision 413627 of the [task](https://rosettacode.org/wiki/ABC_words) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
