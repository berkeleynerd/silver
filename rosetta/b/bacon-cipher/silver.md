# Bacon cipher

**Candidate: proofs plausibly discharge automatically.** Every loop is a for loop over a constant or array range in the main procedure, and the only loop-carried values are bounded counters guarded by capacity comparisons, so the checks should discharge with careful program shape and no annotation.

Position 553 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The program embeds the 27-symbol Bacon table (a-z plus space) as a constant String of 5-character groups, the plaintext and a longer carrier message as constants, and a fixed-capacity Boolean or Character bit buffer sized from the plaintext length times 5. Encoding is a for loop over the plaintext that looks up each symbol's group and fills the buffer, then a for loop over the carrier that upper-cases letters where the bit is B, guarded by the buffer count and a capacity check that rejects a too-short carrier with a printed message. Decoding counts case bits over the cipher text, then for each 5-bit group scans the table with a bounded for loop to find the matching symbol, and both results are printed with Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: The bit-stream position counter is loop-carried, so each write into the fixed-capacity bit buffer and each read of a 5-bit group is guarded by an explicit comparison against the buffer capacity just before use.
- **overflow**: Counters are declared with bounded subtypes and incremented only after a guard, so the +1 and the 5*k+offset arithmetic cannot overflow.
- **length**: The output buffer is a fixed-length String assigned by element with a message length known as a constant, so no slice or concatenation length check depends on loop state.
- **other**: If the message holds fewer letters than 5 times the plaintext length, the program prints a specified rejection line instead of silently truncating, and a plaintext character outside a-z or space is encoded as a space.

## Language surface recorded by this assessment

Characters, ranged subtypes, integers, arrays, string indexing, string building, for loops, procedures, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): The program prints the cipher text and the decoded hidden text with Put_Line.

Assessed on 2026-10-15 against page revision 406138 of the [task](https://rosettacode.org/wiki/Bacon_cipher) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
