# The ISAAC cipher

**Candidate: proofs likely to discharge automatically.** Everything is fixed-size 32-bit modular arithmetic over 256-element arrays with for loops, so wraparound never raises checks and indices are bounded by types or mod 256, needing no invariants. The only care is the Caesar mod-95 range and the Character conversion, which are covered by simple bounded subtypes.

Position 1285 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Embed the key and message as String constants, hold the 256-word mm and randrsl arrays and the aa/bb/cc state as local variables of Main, and implement Isaac, Mix, Rand_Init and Next_Random as nested procedures over an Interfaces.Unsigned_32 modular type with shifts and xor, using for loops only (the 8-wide init pass loops over 32 blocks). Each cipher byte is made by a fixed-length loop over the 19-character message, XORing or Caesar-shifting with Rand mod 95 + 32, and hex digits are looked up in a "0123456789ABCDEF" constant into a fixed-length output String. The program reseeds, decrypts the same way, compares with the original by String equality, and prints all lines. About 170 lines.

## Proof obligations to watch

- **index**: State-array indices derived from data (x/4 mod 256) discharge because the index type is a 256-value modular type or the value is reduced by mod 256 before conversion, and the step-8 loop uses a for loop over 0..31 with i = 8*j so i+7 is statically at most 255.
- **range**: Caesar-shift arithmetic and Character'Val conversions are kept within 0..94 by computing on a bounded Integer subtype and applying mod 95 after adding a multiple of 95 to keep the operand non-negative, so the 32+n result is provably a printable Character.
- **initialization**: All 256-element arrays and the message buffers are initialized with (others => 0) or fixed-length literals before the loops read them, so flow analysis passes.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, characters, arrays, string indexing, string building, for loops, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): Prints the message, key, hex ciphertexts and decrypted plaintexts with Put_Line.

Assessed on 2026-10-15 against page revision 402980 of the [task](https://rosettacode.org/wiki/The_ISAAC_cipher) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
