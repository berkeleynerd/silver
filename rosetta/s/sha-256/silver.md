# SHA-256

**Candidate: proofs likely to discharge automatically.** Every check follows from fixed array ranges, for-loop indexes and modular 32-bit arithmetic, so no loop-carried value needs an invariant, and the algorithm uses no recursion, allocation or while loops.

Position 1292 in the [progression](../../progression.md#stage-23), in stage 23.

## Approach

Hash the embedded 12-byte string 'Rosetta code' as a single padded 64-byte block held in a fixed byte array: copy the characters via Character'Pos, append 16#80#, zeros, and the 64-bit length as constant bytes. Compute the 64-word schedule and 64 rounds with for loops over fixed array ranges using a 32-bit modular word type, with the round constants and initial values as constant arrays. Convert the eight result words to 64 hex characters in a fixed String via a hex-digit table and print them with Put_Line; the input is fixed so no validation is needed. About 130 lines.

## Proof obligations to watch

- **index**: Message schedule and round-constant indices come from for loops over the arrays' own ranges, and the padded block is built in a fixed 64-byte array with literal offsets, so checks discharge from static bounds.
- **overflow**: All word arithmetic uses a 32-bit modular type where addition wraps by definition, and shifts and rotates use literal amounts, so no overflow check arises.
- **range**: Hex digit extraction indexes a 16-character constant string with a nibble value (0..15) obtained by mod 16 or masking, which provers handle with the type range.

## Language surface beyond today's Silver

Modular types, ranged subtypes, arrays, characters, for loops, procedures, functions, string indexing, string building, integers, integer division and Boolean objects.

## External effects

- **console output** (allowed): Prints the quoted text and its 64-hex-digit digest with Put_Line.

Assessed on 2026-10-15 against page revision 414454 of the [task](https://rosettacode.org/wiki/SHA-256) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
