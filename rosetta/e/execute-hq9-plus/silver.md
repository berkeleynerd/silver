# Execute HQ9+

**Candidate: proofs likely to discharge automatically.** Every loop is a for loop over a static range and all values are bounded by types, so the checks follow from declarations, with only the verse string building needing careful buffer sizing. No recursion, annotations or non-trivial effects are involved.

Position 770 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The HQ9+ program is an embedded String constant and the accumulator is an integer in a declared range. A for loop over the constant's own index range dispatches each character with a case statement (H prints Hello, world!; Q prints the source; 9 loops a count from 99 down to 1 via a reverse for loop printing verses built from 'Image; + increments the accumulator; other characters are ignored per the language definition). All output goes through Put_Line in a procedure. About 70 lines.

## Proof obligations to watch

- **overflow**: The accumulator is incremented at most once per instruction of a fixed-length embedded program, so a declared range sized to that length makes the + overflow check follow from the type bound.
- **length**: The 99 bottles verses are assembled from fixed phrases and the 'Image of a count in 1..99 into a bounded buffer, so every concatenation length is statically bounded.
- **index**: The interpreter uses a for loop over the program string's own range, so each character index is within bounds.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, string building, 'Image of scalars, for loops, case statements and procedures.

## External effects

- **console output** (allowed): H, Q and 9 instructions print text lines to standard output.

Assessed on 2026-10-15 against page revision 412777 of the [task](https://rosettacode.org/wiki/Execute_HQ9%2B) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
