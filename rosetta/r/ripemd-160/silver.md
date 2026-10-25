# RIPEMD-160

**Candidate: proofs likely to discharge automatically.** The task is a single-block hash over a fixed 12-byte message, built entirely from wraparound 32-bit modular arithmetic and constant tables with static for-loop bounds, so no overflow, index or termination obligation needs an invariant.

Position 1287 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Embed the 12-character text "Rosetta Code", copy it into a fixed 64-byte block with the 0x80 pad byte and the 96-bit length in little-endian, pack it into sixteen 32-bit modular words, then run the 80-step left and right lines with constant tables (r, r', s, s', K, K') and a rotate built from modular multiply, divide and add. The five state words are combined, serialized little-endian into 20 bytes, and printed as 40 hex digits via a constant digit string indexed by nibble subtypes. All loops are for loops over static ranges and every table index is a subtype-bounded value. About 170 lines.

## Proof obligations to watch

- **index**: Message-word, rotation-amount and hex-digit lookups are indexed by array elements declared with subtypes 0..15 or 0..79, so the index checks follow from types.
- **range**: Padding the 12-byte text into a fixed 64-byte block and converting Character'Pos to a byte use static lengths and a 0..255 subtype, so no guard beyond the constant length is needed.

## Language surface recorded by this assessment

Modular types, ranged subtypes, arrays, for loops, procedures, functions, characters, integers, integer division, string indexing, string building and Boolean objects.

## External effects

- **console output** (allowed): The program prints the 40-hex-digit digest line to standard output.

Assessed on 2026-10-15 against page revision 414423 of the [task](https://rosettacode.org/wiki/RIPEMD-160) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
