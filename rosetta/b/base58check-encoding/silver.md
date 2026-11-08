# Base58Check encoding

**Candidate: proofs plausibly discharge automatically.** Base conversion by repeated division of a fixed-size byte array needs only range-typed carries and a guarded digit count, so no annotations are needed, though the nonlinear carry arithmetic and the while loop's buffer guard require careful shape.

Position 551 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed each example checksum as a fixed-size array of bytes (subtype 0 .. 255) with a length, copy it into a work array, and repeatedly divide the whole number by 58 in a for loop over the array, collecting each remainder as a digit index into the 58-character alphabet constant until the number is zero. Digits are stored least-significant first in a bounded buffer with a guard before each write that rejects on overflow, leading zero bytes are mapped to the first alphabet character, and the buffer is then reversed into a String for Put_Line. The outer repeat-until-zero loop lives in a procedure so it needs no termination proof, and all carried values are range-typed. About 80 lines.

## Proof obligations to watch

- **overflow**: The carry (remainder times 256 plus byte) is declared in a subtype 0 .. 14847 and the remainder in 0 .. 57, so range checks on the loop-carried values follow from types, but the prover must show the quotient fits a byte, which needs 14847/58 <= 255 and is a small nonlinear fact.
- **index**: The digit buffer is sized for the longest example (the 24-byte input needs at most 33 digits, so 40 slots) and a guard before each write rejects the input visibly if the count would exceed capacity.
- **length**: The output String is built in a fixed buffer by reversing digits with for-loop indexes over the buffer range, so slice lengths follow from the guarded count.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, while loops, string indexing, string building and procedures.

## External effects

- **console output** (allowed): Prints each example input and its base58 encoding with Put_Line.

Assessed on 2026-10-15 against page revision 405770 of the [task](https://rosettacode.org/wiki/Base58Check_encoding) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
