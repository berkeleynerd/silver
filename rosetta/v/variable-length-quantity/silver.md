# Variable-length quantity

**Candidate: proofs likely to discharge automatically.** All arithmetic is on small bounded subtypes with fixed-trip for loops and an explicit pre-multiply guard in decoding, so every check follows from types and guards without invariants.

Position 1510 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

Represent the quantity as a subtype 0..2**28-1 and the encoding as a 4-element array of octet values (0..255) plus a length in 1..4, with the two example numbers embedded as constants. An Encode procedure fills the octets from least significant 7-bit group using mod/div in a for loop, setting the continuation bit on all but the last, and a Decode procedure accumulates with a guard that rejects overlong or overflowing sequences; a Hex procedure prints each octet via a constant digit string and Put, then Main compares decoded to original and prints the outcome. About 70 lines.

## Proof obligations to watch

- **overflow**: The decode accumulator times 128 is guarded by an explicit test that it is below 2**21 before each multiply-add, so the result stays within the 28-bit subtype.
- **index**: Octet buffer indexes come from for loops over the array's own range or a length variable constrained by its subtype to 1..4, so index checks follow from types.
- **range**: Encoding a 28-bit value peels 7 bits per step with mod and / on a loop-carried value whose subtype is fixed, so the octet value always lies in 0..127 and the count stays within 4.

## Language surface beyond today's Silver

Integers, integer division, exponentiation, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures, Put without a newline and case statements.

## External effects

- **console output** (allowed): The program prints each octet sequence and the round-trip check result to the console.

Assessed on 2026-10-15 against page revision 413112 of the [task](https://rosettacode.org/wiki/Variable-length_quantity) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
