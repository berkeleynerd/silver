# Longest common subsequence

**Candidate: proofs plausibly discharge automatically.** The iterative table-based dynamic program uses only for-loop indexes, subtype-bounded indices and guards, so checks should discharge without annotations, but loop-carried counters in the traceback require careful guards.

Position 685 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the two example strings as constants, fill a (0..M)x(0..N) Natural-subtype dynamic-programming table with nested for loops (match gives diagonal+1 under a capacity guard, otherwise the max of left and up), then trace back iteratively in a procedure with a while loop into a fixed-capacity Character buffer. Print the collected characters with Put_Line, using guards before every decrement and buffer write and rejecting if a guard fails. About 60 lines.

## Proof obligations to watch

- **overflow**: The table cell increment L(I-1,J-1)+1 depends on array contents that no invariant describes, so it is guarded by an explicit comparison against the capacity limit with Reject as the visible outcome.
- **index**: Traceback indices I, J are subtype-ranged 0..Max and decremented only under I>0 and J>0 guards, and the result cursor K needs an explicit K<Capacity guard because only an invariant could relate it to the match count.
- **termination**: The traceback while loop lives in a procedure, which gets no termination check, while the table fill uses only for loops.
- **length**: The output slice of the result buffer must be proven within bounds from the guarded cursor, and the string lengths are fixed capacities checked against the embedded inputs.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the LCS of the embedded example strings with Put_Line.

Assessed on 2026-10-15 against page revision 415130 of the [task](https://rosettacode.org/wiki/Longest_common_subsequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
