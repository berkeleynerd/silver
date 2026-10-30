# Read a file character by character/UTF8

**Candidate: proofs plausibly discharge automatically.** Decoding UTF-8 is bounded integer arithmetic on bytes in a fixed buffer with explicit guards and a procedure-based loop, so every check follows from types and local guards. The only novelty is an admitted file-read operation, and invalid UTF-8 gets a specified rejection outcome.

Position 1322 in the [progression](../../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program reads the named file once into a fixed-capacity byte array with a count (rejecting a missing, unreadable or oversized file), then a procedure Next_Code_Point takes the buffer, an in out position and returns an out code point plus a status of Ok, End_Of_File or Invalid. The main loop is a while loop in a procedure that calls it until End_Of_File, printing each code point, and a case on the lead byte picks the sequence length with guards on remaining bytes, continuation ranges, overlong forms and surrogates before arithmetic. About 90 lines.

## Proof obligations to watch

- **index**: Each continuation byte read is guarded by a test that the position plus the sequence length does not exceed the byte count, so truncated sequences are rejected visibly.
- **range**: Decoded values are assembled on a code point subtype bounded to 16#10FFFF#, with overlong, surrogate and out-of-range results checked explicitly and rejected.
- **overflow**: Accumulating across up to four bytes stays within Integer because each partial value is bounded by byte ranges and the factors are literals.
- **other**: File contents must come from an admitted library read into a bounded buffer with documented capacity, and oversized files are rejected rather than truncated.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, 'Image of scalars, case statements, for loops, while loops, procedures, functions, Put without a newline and file input.

## External effects

- **files** (allowed): Reads the bytes of one named input file through an admitted library operation that reports open or read failure and a size limit.
- **console output** (allowed): Prints each decoded code point and a specified rejection message for malformed input.

Assessed on 2026-10-15 against page revision 414434 of the [task](https://rosettacode.org/wiki/Read_a_file_character_by_character/UTF8) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
