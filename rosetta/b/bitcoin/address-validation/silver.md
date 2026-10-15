# Bitcoin/address validation

**Candidate: proofs likely to discharge automatically.** Every check comes from byte and carry subtypes, from modular arithmetic that cannot overflow, or from static for-loop bounds. There are no while loops or recursion, so nothing needs a variant or invariant.

Position 1294 in the [progression](../../../progression.md#stage-22), in stage 22.

## Approach

Main reads the address with First_Or_Default, defaulting to the task's example. It rejects with a message any argument that is empty, longer than 35 characters or contains a non-base58 character, using a constant Character-indexed digit table. It then decodes the address into a 25-element byte array with a multiply-by-58 carry loop, rejecting it if a carry is left over. The program computes a single-block SHA-256 twice over arrays of Unsigned_32-style modular words, using constant round tables and for loops only. It reports the address valid only when byte 1 is zero and bytes 22..25 match the first four digest bytes. About 160 lines.

## Proof obligations to watch

- **overflow**: The base58 decode keeps the carry in a 0..255 subtype and computes Temp := Carry + Byte * 58 (at most 15045) fresh in each inner iteration, so every bound follows from types without an invariant.
- **range**: Assigning Temp / 256 to the carry and Temp mod 256 to a byte, and converting digest words to bytes with mod 256 on the modular type, discharge from the just-computed values.
- **index**: The SHA-256 message schedule reads W(I-2), W(I-7), W(I-15) and W(I-16) for I in 16..63, which follows from the static loop bounds, and the argument is scanned with a for loop over its own 'Range.

## Language surface beyond today's Silver

Integers, integer division, modular types, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, for loops, procedures and functions.

## External effects

- **arguments** (allowed): The address to validate comes from the first command-line argument, defaulting to the task's example address.
- **console output** (allowed): The program prints whether the address is valid, or why it was rejected.

Assessed on 2026-10-15 against page revision 413263 of the [task](https://rosettacode.org/wiki/Bitcoin/address_validation) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
