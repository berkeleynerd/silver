# MD4

**Candidate: proofs likely to discharge automatically.** The single-block MD4 of a fixed 12-byte message is straight-line modular arithmetic inside for loops with constant tables, so every check follows from types and loop ranges and no annotation is needed.

Position 1290 in the [progression](../../progression.md#stage-23), in stage 23.

## Approach

Embed "Rosetta Code" as a constant String, copy its 12 bytes into a 64-byte padded block array (0x80 terminator, bit length 96 in the final little-endian length word), and decode it into sixteen 32-bit modular words. Run the three MD4 rounds as for loops over 16 steps, using constant index and shift tables and F, G and H functions on modular words, with four state words updated in the loop, then add them to the initial state. Write the little-endian bytes as 32 hex characters into a fixed String buffer via a digit table and print it with Put_Line. About 120 lines.

## Proof obligations to watch

- **index**: Message bytes, word indices and per-step shift and index tables are all indexed by for-loop variables over the arrays' own ranges or by constants of a ranged subtype, so index checks follow from types.
- **range**: Hex digit selection uses a nibble value obtained by mod 16 and converted to a Character through a constant 16-entry digit table, so the index range holds by type.
- **overflow**: All 32-bit word arithmetic uses a modular type where wraparound is defined and rotation is done by shifting with multiplication and division by powers of two, so no overflow check arises; only the rotate amounts need to be in a small subtype range.

## Language surface beyond today's Silver

Modular types, ranged subtypes, characters, arrays, for loops, procedures, functions, string building, integers, integer division and Boolean objects.

## External effects

- **console output** (allowed): Prints the quoted text and its 32-hex-digit MD4 digest with Put_Line.

Assessed on 2026-10-15 against page revision 415179 of the [task](https://rosettacode.org/wiki/MD4) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
