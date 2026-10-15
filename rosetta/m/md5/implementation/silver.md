# MD5/Implementation

**Candidate: proofs plausibly discharge automatically.** Every check follows from modular wraparound, declared ranges and a length guard on a fixed buffer, with no loop-carried value needing an invariant, but the long unrolled-or-looped arithmetic with table indexing needs careful shape to discharge reliably.

Position 1318 in the [progression](../../../progression.md#stage-22), in stage 22.

## Approach

A 32-bit modular word type, constant tables for the 64 sine constants, shifts and powers of two, and a fixed 128-byte buffer holding the padded message (rejecting inputs over 119 bytes with a visible outcome). A Digest procedure loops over blocks and over the 64 steps with a case on step/16 choosing the mixing function, rotating with a power-of-two table, then writes the little-endian hex digest into a 32-character string. Main runs the seven RFC 1321 strings embedded as constants and prints each digest next to the expected value. About 210 lines.

## Proof obligations to watch

- **index**: Padding copy and 16-word block extraction index a 128-byte buffer, which discharges because messages longer than 119 bytes are rejected up front and loop indexes derive from for-loop ranges over the buffer's own bounds.
- **index**: Per-step message index (5*i+1) mod 16 and table lookups for K, S and powers of two are bounded by mod and declared subtype ranges, but the provers must handle the small nonlinear expression.
- **overflow**: All 32-bit word arithmetic uses a modular type so wraparound is by definition, and rotate uses a power-of-two table indexed by a ranged shift amount so no variable exponent is needed.
- **length**: Block count and total padded length are computed from the guarded input length, and the hex output buffer is a fixed 32-character string filled by index.
- **range**: Character'Pos to byte and nibble to hex-digit conversions are bounded by types (0..255, 0..15), and 64-bit length bytes come from the guarded length times 8.

## Language surface beyond today's Silver

Modular types, integers, integer division, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, string building, for loops, case statements, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): Prints each test string with its computed digest and the expected RFC 1321 digest using Put_Line.

Assessed on 2026-10-15 against page revision 415180 of the [task](https://rosettacode.org/wiki/MD5/Implementation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
