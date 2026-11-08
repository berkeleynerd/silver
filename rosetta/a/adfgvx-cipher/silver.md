# ADFGVX cipher

**Candidate: proofs plausibly discharge automatically.** All arithmetic and indexes are bounded by small fixed ranges and guards, and loops are in procedures, so no annotation is needed, but the transposition index bookkeeping needs careful guard placement.

Position 738 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The program embeds a fixed list of 9-letter repeat-free words and a fixed seed for an LCG that drives a Fisher-Yates shuffle of the 36-character alphabet into a 6x6 array and picks the key word. Encryption maps each plaintext character to a row/column letter pair in a bounded buffer, then reads columns in the alphabetical order of the key letters (ranks computed by comparing key characters); decryption rebuilds column lengths from the ciphertext length and inverts the transposition, then the lookup. Input characters are validated as upper-case letters or digits before use, and invalid input has a specified rejection message. About 170 lines.

## Proof obligations to watch

- **overflow**: The deterministic LCG state is kept in a bounded range type and reduced with mod before each multiply, so the product stays within Integer.
- **index**: Shuffle swaps, Polybius lookups and the column-by-column transposition indexes are computed from loop-carried values, so each is guarded or reduced with mod into the array range just before use.
- **range**: Ragged final-row column lengths and the ciphertext length are bounded by the fixed buffer capacity, with a visible rejection if plaintext exceeds it.
- **initialization**: All arrays and buffers are fully initialized by aggregates or loops before reading.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, procedures, functions, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): Prints the Polybius square, the key, the plaintext, the cipher text and the decrypted text.

Assessed on 2026-10-15 against page revision 414043 of the [task](https://rosettacode.org/wiki/ADFGVX_cipher) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
