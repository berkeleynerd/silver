# Shortest common supersequence

**Candidate: proofs plausibly discharge automatically.** The task is a plain dynamic-programming problem on small fixed strings that needs only bounded arrays, nested for loops and one guarded while loop in a procedure, so all checks follow from subtype ranges and local guards without annotations. It is plausible rather than likely because the backtrack's loop-carried indices and output position each need explicit guards.

Position 697 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the two strings as constants, fill a 0..7 by 0..6 LCS length table with nested for loops, then walk back from the corner in a while loop inside a procedure, writing characters from the end of a 13-character buffer (taking the shared character once, otherwise the character from the side with the larger table value, then any leftover prefix). Print the final slice with Put_Line; every index is guarded before use. About 70 lines.

## Proof obligations to watch

- **index**: Backtracking indices i, j and output position k are loop-carried in a while loop, so each use of U(i), V(j) or Buf(k) is preceded by an explicit guard (i > 0, j > 0, k > 0) with a visible Reject otherwise.
- **range**: The DP table values and decrements of i, j, k are bounded by the declared subtype ranges, with guards placed just before each decrement.
- **termination**: The backtrack while loop lives in a procedure, which gets no termination check, and each iteration decrements i or j anyway.
- **length**: The output slice Buf(k+1 .. 13) is taken only after a guard that k is within the buffer bounds, and the 13-character buffer is sized for the maximum supersequence length of 7+6.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the resulting supersequence with Put_Line.

Assessed on 2026-10-15 against page revision 413019 of the [task](https://rosettacode.org/wiki/Shortest_common_supersequence) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
