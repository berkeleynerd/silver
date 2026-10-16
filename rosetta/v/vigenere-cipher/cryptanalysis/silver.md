# Vigenère cipher/Cryptanalysis

**Candidate: proofs plausibly discharge automatically.** Everything uses for loops over fixed bounds in a procedure with integer-scaled frequencies, so the checks follow from ranged subtypes and mod 26 or key-length indexing, but the nested loops with loop-carried score sums need carefully sized subtypes and no annotation is required.

Position 846 in the [progression](../../../progression.md#stage-15), in stage 15.

## Approach

The ciphertext (about 830 letters, whitespace pre-removed) is embedded as a String constant and the English letter frequencies as an integer table scaled by 10000, so no floating point is used. A procedure tries each key length from 1 to a fixed maximum with for loops, counts letters per column in a 2D integer array, picks for each column the Caesar shift with the smallest integer squared-difference score, and keeps the smallest key length whose total score is under a fixed threshold. It then builds the key and plaintext in fixed-size String buffers with Character'Val and mod 26, and prints both with Put_Line. About 130 lines.

## Proof obligations to watch

- **overflow**: The chi-squared style score sums squared differences over loop-carried accumulators, so counts, scaled frequencies and the sum must use ranged integer subtypes sized from the fixed ciphertext length (about 830 letters) so the squares and sums stay within 64 bits without an invariant.
- **index**: Column and key indexes are computed as (position mod key length) and shift lookups as (letter + shift) mod 26, which are provably in range only with guards or subtypes just before each use, and the nested key-length, column, shift and letter loops need these written carefully.
- **range**: Loop-carried running minimums and the best key length and shift need declared subtypes wide enough to hold their initial sentinel values, since no invariant can narrow them.
- **division**: Mod by the key length and any normalisation by column size are safe only if the key length loop variable is a positive subtype and column counts are guarded against zero before dividing.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, for loops, procedures, functions and case statements.

## External effects

- **console output** (allowed): Prints the recovered key and the decrypted plaintext with Put_Line.

Assessed on 2026-10-15 against page revision 414575 of the [task](https://rosettacode.org/wiki/Vigen%C3%A8re_cipher/Cryptanalysis) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
