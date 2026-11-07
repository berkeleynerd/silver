# Bioinformatics/Subsequence

**Candidate: proofs likely to discharge automatically.** All checks follow from fixed array bounds, for-loop index ranges and a ranged generator state that bounds the one multiplication, so no invariant or variant is needed.

Position 512 in the [progression](../../../progression.md#stage-10), in stage 10.

## Approach

A 200-character String is filled in a for loop from a deterministic Lehmer generator whose state is a ranged subtype, mapping State mod 4 to one of A, C, G, T via a constant 4-character lookup string; a 4-character pattern is generated the same way. A for loop over start positions 1 .. 197 compares the four characters at each offset with and then, and every match prints "Found at position: N..N+3" with Put_Line, printing a "none found" line when the count is zero. About 55 lines.

## Proof obligations to watch

- **overflow**: The LCG step State * 48271 mod 2147483647 is discharged because State is declared in a subtype 0 .. 2147483646, so the product stays below 2**47 inside a 64-bit type even though State is loop-carried.
- **index**: The scan uses for I in 1 .. 197 with Sequence (I .. I + 3) and Sequence (I + k) accesses, which are in range of the 200-element string from the loop bounds alone.
- **length**: Output lines are built by concatenating fixed-width pieces with bounded Image text, so a static length bound must be visible, which needs the image of a bounded Natural range padded to a known width.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, string building, 'Image of scalars, for loops, procedures and arrays.

## External effects

- **console output** (allowed): Prints the generated sequence, the four-letter subsequence and each match position with Put_Line.

Assessed on 2026-10-15 against page revision 400882 of the [task](https://rosettacode.org/wiki/Bioinformatics/Subsequence) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
