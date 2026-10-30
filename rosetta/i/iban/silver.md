# IBAN

**Candidate: proofs likely to discharge automatically.** Every check follows from a fixed-size buffer, a guarded count, a bounded remainder subtype and for-loop indexes, so no annotation is needed; the 34-character limit is a documented resource limit that rejects longer input visibly.

Position 780 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the sample IBANs as String constants, and a procedure copies the non-space characters, upper-cased through a case statement on Character ranges, into a 34-character buffer with a guarded count, rejecting any other character or overflow of 34. It then checks the country code and length against a constant table of two-letter codes and lengths, rotates the first four characters to the end by index arithmetic, and folds each character into a remainder in 0 .. 96 with a for loop, accepting when the remainder is 1; the result is printed with Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: The compacted buffer is a fixed 34-character array and the count is incremented only behind a guard Count < 34, with longer input rejected as invalid.
- **overflow**: The running remainder is a subtype 0 .. 96 so Num * 100 + 35 is bounded and the mod 97 result restores the range without any loop invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, for loops, case statements, procedures and functions.

## External effects

- **console output** (allowed): Prints a valid or not-valid line for each embedded IBAN via Put_Line.

Assessed on 2026-10-15 against page revision 414262 of the [task](https://rosettacode.org/wiki/IBAN) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
