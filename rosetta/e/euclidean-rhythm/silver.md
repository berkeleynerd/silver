# Euclidean rhythm

**Candidate: proofs plausibly discharge automatically.** All arithmetic and indexing is over small ranged integers and fixed-capacity buffers, so each check can be discharged by types and guards placed before the use, but the loop-carried group indices and lengths make it depend on careful program shape rather than being routine.

Position 623 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The program stores each group as a fixed-capacity Character buffer plus a length in a record array, sized for n up to a documented limit such as 32. A procedure Euclidean_Rhythm (M, N) rejects M not in 1 .. N-1 or N above the limit with a visible message, then fills m groups with '1' and the rest with '0', and repeatedly appends the second groups onto the first groups with guarded while loops until either side has fewer than two groups. It finally concatenates the groups into a bounded output string and prints it with Put_Line for the embedded (5,13) and (3,8) cases. About 90 lines.

## Proof obligations to watch

- **index**: The group-start and group-end indices and pairing cursors are loop-carried, so they get ranged subtypes and an explicit guard before each array access, with an else-branch that stops the loop.
- **length**: Each group is a fixed-capacity buffer with a length field, and every append is guarded by a check that the combined length fits, as the total output length is n, which is at most the capacity.
- **overflow**: Index increments like a_pos + 1 and b_pos + 1 are discharged by ranged subtype bounds plus a guard against the capacity limit, since only the types are known after the first iteration.
- **termination**: The nested while loops live in a procedure, so no termination check is generated.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, records, for loops, while loops, procedures, string building and string indexing.

## External effects

- **console output** (allowed): Prints each rhythm string (for the embedded cases (5,13) and (3,8)) with Put_Line.

Assessed on 2026-10-15 against page revision 411959 of the [task](https://rosettacode.org/wiki/Euclidean_rhythm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
