# Data Encryption Standard

**Candidate: proofs likely to discharge automatically.** DES is a fixed-size, loop-over-constant-tables computation in which every index and arithmetic result is bounded by ranged subtypes and for-loop ranges, so no loop invariant or recursion is needed. The main cost is the large amount of constant table data and index-heavy but statically bounded code.

Position 682 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The key and plaintext are embedded as constant arrays of bits (a subtype 0..1) and the standard DES tables (PC-1, PC-2, IP, IP inverse, E, P, shift schedule, 8x64 S-boxes) are constant arrays whose elements are ranged subtypes matching the indexed array bounds. A procedure computes the 16 subkeys into a 16x48 bit array using for loops and mod-based rotation of the 28-bit halves, then runs 16 Feistel rounds with for loops, and finally a for loop converts each nibble to a hex Character in a fixed 16-character String printed with Put_Line. The task needs only the encryption of the one given block, so no decryption, padding or input is included. About 170 lines.

## Proof obligations to watch

- **index**: Every permutation lookup indexes a bit array by a table whose elements are a ranged subtype equal to the array's index range, and rotation indexes use for-loop variables with mod, so each index check follows from types.
- **range**: The S-box index is row (0..3) times 16 plus column (0..15) over ranged bit and nibble subtypes, and XOR is written as (a + b) mod 2, so the results stay within the declared subtypes.
- **other**: The key, plaintext and expected output are embedded as constant bit or hex tables, so no parsing is required and the only size concern is roughly 400 constant table entries.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, for loops, procedures and functions.

## External effects

- **console output** (allowed): The program prints the 16-hex-digit ciphertext with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 387544 of the [task](https://rosettacode.org/wiki/Data_Encryption_Standard) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
