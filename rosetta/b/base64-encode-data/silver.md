# Base64 encode data

**Candidate: proofs likely to discharge automatically.** All arithmetic is on bounded byte values with mod and division by literals and a for loop over a static array range, so every check follows from types and static bounds with no loop-carried unbounded values.

Position 454 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed a fixed-length constant array of byte values (type 0..255) as the data, since the favicon download is not required to be fetched live, and a constant 64-character alphabet string. A for loop over full 3-byte groups computes the 24-bit value and writes four alphabet characters into a fixed-size output String buffer at offsets derived from the loop index, then a guarded tail handles the 1- or 2-byte remainder with '=' padding, and Put_Line prints the buffer. About 70 lines.

## Proof obligations to watch

- **index**: Each 6-bit group is computed with mod and / on a Natural byte value, giving 0..63 that indexes a constant 64-character alphabet string, so the index check follows from the arithmetic bounds.
- **range**: Combining up to three bytes into a 24-bit Natural and the output position (3-byte group index times 4) are bounded by the fixed embedded array length, so the loop-carried output offset is a for-loop index expression with static bounds.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, for loops, string building, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the base64 text with Put_Line.

Assessed on 2026-10-15 against page revision 407345 of the [task](https://rosettacode.org/wiki/Base64_encode_data) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
