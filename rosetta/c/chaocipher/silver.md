# Chaocipher

**Candidate: proofs likely to discharge automatically.** Every index and loop bound follows from fixed 26/28-length strings and a 1..26 position subtype with mod arithmetic, and all loops are for loops in procedures, so nothing needs an annotation.

Position 538 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Both alphabets and the 28-letter plaintext are fixed-length String variables or constants, with a subtype for 26-character alphabets and a Positive subtype 1..26 for positions. A step procedure finds the letter's position with a for loop and found flag (printing a rejection message if absent), maps it to the other alphabet, then rebuilds the left and right alphabets into temporary strings using for loops with mod-based rotation and a shift of the nadir-adjacent letter. The main procedure encrypts, prints each alphabet pair, then decrypts the ciphertext with the same procedure and prints both results. About 90 lines.

## Proof obligations to watch

- **index**: Rotation indexes are computed as ((I + Index - 2) mod 26) + 1 with Index in a 1..26 subtype, so the result is statically within 1..26 without any invariant.
- **initialization**: The output buffer and the found-index variable are initialized before their loops so no loop-carried uninitialized read remains.
- **range**: The letter lookup uses a found flag and an explicit rejection path for characters outside the alphabet, so the position never leaves 1..26 and the case is not silently altered.

## Language surface recorded by this assessment

Ranged subtypes, integers, integer division, Boolean objects, characters, arrays, string indexing, string building, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the plaintext, the alphabets after each step, the ciphertext and the recovered plaintext with Put_Line.

Assessed on 2026-10-15 against page revision 414638 of the [task](https://rosettacode.org/wiki/Chaocipher) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
