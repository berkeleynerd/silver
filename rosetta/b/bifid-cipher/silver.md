# Bifid cipher

**Candidate: proofs likely to discharge automatically.** All loops are for loops over bounded ranges inside procedures with a length guard, so every index and range check follows from types and guards without invariants; the only mildly delicate part is coordinate index arithmetic over unconstrained strings.

Position 991 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Each Polybius square is a 25-character String constant; a lookup function scans it with a for loop to give a row/column pair in 0..4 (J mapped to I when the square lacks J). Encrypt writes all rows then all columns into a bounded 80-element Integer array, re-pairs consecutive entries to index back into the square, and decrypt reverses this, with messages up to 40 letters guarded and an unknown letter producing a printed rejection. Main embeds the four test messages and squares, uppercases the January sentence by hand, and prints plaintext, ciphertext and round-trip result. About 110 lines.

## Proof obligations to watch

- **index**: Coordinate indexes 2*I-1 and 2*I into a fixed 80-element buffer are safe because a guard rejects any message longer than 40 letters before the loop, and the offsets derive from the string's own range.
- **range**: Square lookup returns a 0..24 position from a for loop over the 25-letter key, with a Boolean found flag so unknown characters give a visible rejection instead of an unchecked index.
- **overflow**: Offset arithmetic on an unconstrained String's 'First is bounded by the 40-character length guard, so no sum can exceed Integer'Last.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, string building, for loops, procedures, functions and conditional expressions.

## External effects

- **console output** (allowed): Prints each message, its ciphertext and the decrypted text with Put_Line.

Assessed on 2026-10-15 against page revision 414074 of the [task](https://rosettacode.org/wiki/Bifid_cipher) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
