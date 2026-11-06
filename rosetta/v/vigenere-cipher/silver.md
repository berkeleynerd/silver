# Vigenère cipher

**Candidate: proofs likely to discharge automatically.** Every check follows from bounded character arithmetic, for-loop indexes, and explicit guards on the output count and key length, so no invariant or variant is needed. Non-letters are discarded as the task specifies, with embedded data and no recursion or heap.

Position 889 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the sample text and key as String constants, then filter each into a fixed-capacity upper-case letters buffer plus a count, skipping non-letters and guarding the count against capacity. Encrypt and decrypt with a for loop over the filtered text, adding or subtracting the key letter (index taken as position mod key count, with a prior check that the key count is nonzero), using Character'Pos/'Val arithmetic with a mod 26, then print each result as a slice with Put_Line. A key with no letters is rejected with a visible message. About 70 lines.

## Proof obligations to watch

- **index**: The filtered output count is a loop-carried value, so each store is preceded by a guard that the count is below the buffer capacity, and the key index is computed as a mod of a key length that is checked nonzero first.
- **range**: Letter shifts are kept in 0..25 by subtype-bounded Character'Pos arithmetic and a mod 26 (or a conditional subtract), which the provers handle on bounded operands.
- **length**: The output strings are slices of a fixed-capacity buffer up to the checked count, and an empty or overlong key or text takes a visible rejection path.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, for loops, procedures, functions and conditional expressions.

## External effects

- **console output** (allowed): Prints the encrypted and decrypted text lines with Put_Line.

Assessed on 2026-10-15 against page revision 411838 of the [task](https://rosettacode.org/wiki/Vigen%C3%A8re_cipher) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
