# List rooted trees

**Candidate: proofs plausibly discharge automatically.** The task is plain deterministic enumeration with small fixed bounds and no annotations are needed since loops live in procedures, but the successor algorithm's loop-carried indexes and levels need careful guards to prove automatically.

Position 463 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Fix N (for example 5, with the 9-tree output) and enumerate rooted trees as canonical level sequences held in a constrained array of a ranged subtype, starting from the path and applying the Beyer-Hedetniemi successor in a while loop inside a procedure until no successor exists. Each sequence is rendered into a fixed 2*N character buffer by emitting the needed closing parentheses and then an opening one per node, and printed as one line. Every index and level update is preceded by an explicit bounds guard. About 75 lines.

## Proof obligations to watch

- **index**: The successor step searches for the last level greater than 1 and indexes the level array and parent position with loop-carried values, so each access needs an explicit guard (position at least 1 and at most N) just before use, with a visible stop when none exists.
- **range**: Level values are stored in a subtype 0..N-1 and the copy/increment steps are computed from neighbours, so each assignment is guarded by comparing against the bound before adding.
- **overflow**: The parenthesis buffer position advances in a loop, which is discharged by a buffer of fixed size 2*N and a guard before each write, with the per-tree close count bounded by the level subtype.
- **termination**: Enumeration uses a while loop with an exit when no successor exists, which is safe because it lives in a procedure and so gets no termination check.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, for loops, while loops, procedures, string building and Put without a newline.

## External effects

- **console output** (allowed): Each tree is printed as a parenthesis string on its own line.

Assessed on 2026-10-15 against page revision 414310 of the [task](https://rosettacode.org/wiki/List_rooted_trees) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
