# Substitution cipher

**Candidate: proofs likely to discharge automatically.** All indexing is over fixed-length constant strings and a bounded buffer using for loops inside procedures, so checks follow from static bounds and one size guard; the only gap is that Silver needs file read and write operations with specified failure outcomes.

Position 1421 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Declare constant 52-character Alphabet and Key strings and a fixed-capacity text buffer with a length. A Translate procedure walks the buffer with a for loop, finds each letter's position in the source alphabet with an inner for loop over its range, and replaces it from the target alphabet, leaving non-letters unchanged. Main reads the input file with a status result, rejects oversize or unreadable input, writes the encrypted file, then reads that back and writes the decrypted file. About 70 lines.

## Proof obligations to watch

- **index**: The alphabet lookup uses a for loop over the 52-character alphabet's own range and the key has the same fixed length, so the index checks are static.
- **length**: The input is read into a fixed-capacity buffer with a reported length, and a file larger than the capacity is rejected with a visible message.

## Language surface recorded by this assessment

Integers, characters, ranged subtypes, string indexing, string building, for loops, procedures, functions, Boolean objects, file input and file output.

## External effects

- **files** (allowed): Reads the source file and writes the encrypted file and then the decrypted file through admitted file operations.
- **arguments** (allowed): The first argument selects encode or decode mode.
- **console output** (allowed): Reports usage, rejected input and completion.

Assessed on 2026-10-15 against page revision 414616 of the [task](https://rosettacode.org/wiki/Substitution_cipher) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
