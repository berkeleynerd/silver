# Bitcoin/public point to address

**Candidate: proofs likely to discharge automatically.** Every hash operation uses modular arithmetic that cannot overflow, and every index comes from a for-loop range or a constant table with a ranged element type. The only non-routine check is the Base-58 division bound, which follows from the declared 0..57 remainder subtype. No annotation is needed.

Position 1298 in the [progression](../../../progression.md#stage-22), in stage 22.

## Approach

The public point is embedded as a constant 65-byte array (prefix 4, then X and Y) of a mod-256 byte type. SHA-256 and RIPEMD-160 run as procedures over a 32-bit modular word type, using rotations built from modular shifts, fixed padding into a 128-byte buffer and for loops over static block, round and schedule ranges. The 25-byte payload is version 0, then the RIPEMD-160 digest, then the first four bytes of a double SHA-256. It is Base-58 encoded by 34 passes of byte-wise long division into a fixed 34-character String indexed from the alphabet constant, then printed. About 260 lines.

## Proof obligations to watch

- **range**: In the Base-58 long division the remainder is held in a 0..57 subtype, so Rem * 256 + Byte stays at or below 14847 and its quotient by 58 fits a byte, which needs the solver to bound a division by a constant but no invariant.
- **range**: Narrowing 32-bit words to bytes in the digest serialization uses mod 256 before conversion, so the result range follows from the mod operator.
- **index**: The RIPEMD-160 word-selection and rotation tables are constant arrays whose element subtypes are 0..15 and 5..15, so indexing the 16-word block and the shift amounts discharge from the declared types.
- **length**: Padding uses one 128-byte buffer and a message-length parameter of subtype 0..119, so the copy loops and the 64-bit length field have static bounds; the 65-, 32- and 21-byte inputs all lie in that range.

## Language surface beyond today's Silver

Integers, integer division, modular types, ranged subtypes, arrays, for loops, procedures, functions, string indexing and string building.

## External effects

- **console output** (allowed): The program prints the computed Base-58 address with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413264 of the [task](https://rosettacode.org/wiki/Bitcoin/public_point_to_address) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
