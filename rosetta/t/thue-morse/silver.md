# Thue-Morse

**Candidate: proofs likely to discharge automatically.** The task only needs seven short rows built by iterative doubling in a fixed buffer, so every index and range check follows from subtypes and a guard placed just before use, with no recursion or while loops.

Position 952 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A 64-character String buffer holds the current row, starting as "0" with length 1; each row is printed as the digit prefix plus the slice of the buffer, then doubled by a for loop copying the complement of Buf(J) into Buf(Len+J). The row length is a subtype 1..32 variable and the doubling is guarded by an explicit Len < 32 test, so all indexes stay within 1..64; the outer loop is a for loop over 0..6. About 35 lines.

## Proof obligations to watch

- **index**: The doubling step indexes a 64-character buffer with a loop-carried length, discharged by declaring the length as a subtype 1..32 and guarding the doubling with if Len < 32.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, string building, unconstrained arrays and for loops.

## External effects

- **console output** (allowed): Seven rows of the sequence are printed with Put_Line.

Assessed on 2026-10-15 against page revision 413086 of the [task](https://rosettacode.org/wiki/Thue-Morse) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
