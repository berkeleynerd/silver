# Long literals, with continuations

**Candidate: proofs likely to discharge automatically.** Every check comes from a static constant string, a for-loop index over that string's own range, and one guard placed just before the counter increment, so no annotation is needed. The only new surface is integers, characters, string indexing and slicing, for loops and 'Image.

Position 512 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Elements is a constant String built from about 16 string literals joined with &, each under 81 columns, with a comment explaining that & is the continuation mechanism; Revision is a constant String holding an ISO date. A single for loop over Elements'Range tests each character against ' ', adds one to a guarded Natural counter and records Start := I + 1 at each blank. Three Put_Line calls then print the date, Count'Image and the slice from Start to Elements'Last. About 45 lines.

## Proof obligations to watch

- **overflow**: The loop-carried word counter is not bounded without an invariant, so the increment is guarded by a test just before it (Count < Natural'Last), with an else branch that prints a specified, visible error that can never be reached.
- **index**: The start of the last word is kept as Start := I + 1, with I drawn from Elements'Range, so Start is Positive and at most Elements'Last + 1, and the slice Elements (Start .. Elements'Last) is either within bounds or empty.

## Language surface beyond today's Silver

Integers, characters, string indexing, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the revision date, the element count and the last element name with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413293 of the [task](https://rosettacode.org/wiki/Long_literals,_with_continuations) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
