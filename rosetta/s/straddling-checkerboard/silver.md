# Straddling checkerboard

**Candidate: proofs plausibly discharge automatically.** Every access is into fixed arrays indexed by guarded or ranged values and the only loop-carried cursor is guarded before each use, so no annotation is needed, but the decrypt cursor and buffer lengths make the program shape-sensitive.

Position 846 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Represent the board as constant arrays: a 10-entry digit row for the first row, two 10-entry rows for the other two blanks, and a lookup table from Character to a code string held in a small fixed record-free pair of arrays (digit count and up to two digits). Encrypt walks the embedded plaintext with a for loop, upcases letters, emits the escape code plus the digit for numerals, and appends to a bounded buffer after a capacity guard; Decrypt walks the ciphertext with a while loop in a procedure, reads one digit or a blank digit plus a second digit, handles the escape by taking the next digit literally, and sets a rejected flag on any malformed or truncated sequence. Main encrypts the example message, prints it and the digits, decrypts, and prints the result, or prints a rejection message. About 130 lines.

## Proof obligations to watch

- **index**: Decrypt's cursor into the ciphertext advances by one or two inside a while loop, so each read is preceded by an explicit bound guard and a truncated escape sequence takes a visible reject path.
- **length**: Output buffers are fixed-capacity with an explicit used-length, and each append is guarded by a capacity check that rejects over-long input rather than truncating.
- **range**: Mapping characters and digits to board positions needs the lookup tables typed as ranged subtypes and a guard that the character or digit is in the board, with unmapped input producing a specified rejection.
- **termination**: Decrypt's while loop sits in a procedure, which gets no termination check, and the cursor strictly advances anyway.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures and case statements.

## External effects

- **console output** (allowed): Prints the plaintext, the ciphertext digits and the decrypted text with Put_Line.

Assessed on 2026-10-15 against page revision 413929 of the [task](https://rosettacode.org/wiki/Straddling_checkerboard) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
