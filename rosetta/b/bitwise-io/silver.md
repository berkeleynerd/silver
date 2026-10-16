# Bitwise IO

**Candidate: proofs plausibly discharge automatically.** All arithmetic is on small bounded byte and bit-count types with guards before each increment, and the loops are for loops or procedure while loops, so checks should discharge without annotations; the main uncertainty is the library file read/write operations that Silver does not yet have.

Position 1434 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A bit writer and bit reader are records holding a fixed-capacity Byte array, a byte position, and a bit-count subtype 0..8, with procedures Write_Bit, Flush (zero-padding the last byte), and Read_Bit that returns an out success flag. The test embeds a short ASCII string, rejects any character with code above 127, writes each character as 7 bits MSB first, flushes, writes the bytes to a file, reads them back through the reader, and compares to the original. Each position and count update is preceded by an explicit capacity or end-of-data guard that leads to a printed failure outcome. About 110 lines.

## Proof obligations to watch

- **overflow**: The bit accumulator is a Byte modular type or an Integer range 0..255 updated with a shift and an OR, so wraparound is defined and the range subtype for the used-bit count 0..8 is guarded by a flush-when-full test before each shift.
- **index**: Loop-carried output and input positions are indexes into fixed-capacity byte arrays and each is guarded by a capacity check just before use, with overflow of capacity giving a visible failure result.
- **range**: Extracting a bit from a byte via division by a power of two and conversion to a 0..1 subtype is safe because the byte type bounds the quotient, and a read past end of data returns a visible failure flag.
- **termination**: Only for loops over fixed ranges are used in functions and any while loop (for example reading until end of file) lives in a procedure, so no variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, modular types, Boolean objects, characters, arrays, for loops, while loops, procedures, functions, records, string indexing, 'Image of scalars, file output, file input and conditional expressions.

## External effects

- **files** (allowed): The packed 7-bit byte sequence is written to a named binary file and read back to test the bit reader.
- **console output** (allowed): The program reports whether the decompressed text matches the original and may print the packed bytes in hexadecimal.

Assessed on 2026-10-15 against page revision 414089 of the [task](https://rosettacode.org/wiki/Bitwise_IO) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
