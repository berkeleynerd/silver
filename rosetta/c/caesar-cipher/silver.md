# Caesar cipher

**Candidate: proofs likely to discharge automatically.** Every check is an index over the loop's own range or a Character'Val/mod computation bounded by constant types, with no loop-carried values, recursion or reading of input, so proofs should discharge routinely.

Position 756 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

A constant message String and a constant Key (a subtype range 1..25) are embedded; a pure function Shift(C, K) uses case or if on 'A'..'Z' and 'a'..'z' to apply ((Pos(C) - Pos(Base) + K) mod 26) + Pos(Base) and leaves other characters unchanged. Two fixed-length String variables of the message's length are filled by for loops over their own index range, encrypting with Key and decrypting with 26 - Key, and the three results are printed with Put_Line and concatenation. About 45 lines.

## Proof obligations to watch

- **range**: Character'Val needs its argument in 0..255, which follows because (x mod 26) + 65 lies in 65..90 or (x mod 26) + 97 lies in 97..122.
- **overflow**: Character'Pos values are at most 255 and the key is a constant 1..25, so the sum before mod cannot overflow Integer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, for loops, functions and case statements.

## External effects

- **console output** (allowed): Prints the plaintext, ciphertext and decrypted text with Put_Line.

Assessed on 2026-10-15 against page revision 415303 of the [task](https://rosettacode.org/wiki/Caesar_cipher) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
