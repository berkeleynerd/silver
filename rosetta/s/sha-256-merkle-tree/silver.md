# SHA-256 Merkle tree

**Candidate: proofs plausibly discharge automatically.** Every check follows from modular word arithmetic, constant loop bounds and a ranged hash count with guards, with no annotations needed, but SHA-256 round code and the file-reading effect make the shape careful rather than routine. The task genuinely needs binary file input (the digest is defined on title.png), so it depends on an admitted file-reading library operation.

Position 1342 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program reads the file named by the first argument into fixed 1024-byte block buffers, SHA-256 hashes each block (and later each 64-byte concatenated pair) using a modular 32-bit word type with constant round-constant arrays and for-loop compression, and stores the 32-byte hashes in a bounded array. A while loop in a procedure repeatedly pairs adjacent hashes, hashing each pair and carrying an odd last hash up unchanged, until one remains, then writes it as 64 hex characters via Put_Line. Files that cannot be read or exceed the capacity are rejected with a printed message. About 230 lines.

## Proof obligations to watch

- **index**: Pairing indexes 2*i-1 and 2*i in the level-reduction loop are guarded by comparing against the current hash count, and the count is a ranged subtype bounded by the fixed capacity.
- **overflow**: SHA-256 word arithmetic uses a 32-bit modular type that wraps by definition, while the 64-bit bit-length and byte offsets are kept in ranges bounded by the block capacity.
- **termination**: The while loop that halves the hash count lives in a procedure, which gets no termination check, so no variant is needed.
- **length**: Files longer than the fixed capacity (blocks times 1024 bytes) must be rejected with a visible message, which keeps the block count in range.
- **initialization**: Hash state, schedule and block buffers are fully assigned by aggregates or for loops before use, though flow analysis of arrays filled in loops may need care.

## Language surface recorded by this assessment

Modular types, ranged subtypes, characters, arrays, multidimensional arrays, for loops, while loops, procedures, functions, string building, integers, integer division, Boolean objects and file input.

## External effects

- **files** (allowed): Reads the binary title.png file in 1024-byte blocks.
- **arguments** (allowed): The first command-line argument names the file to hash.
- **console output** (allowed): Prints the hexadecimal root digest, or a rejection message for an unreadable or oversized file.

Assessed on 2026-10-15 against page revision 414455 of the [task](https://rosettacode.org/wiki/SHA-256_Merkle_tree) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
