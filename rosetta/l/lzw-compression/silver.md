# LZW compression

**Candidate: proofs plausibly discharge automatically.** Every check reduces to bounded-array indexing and range-typed codes with capacity guards placed immediately before use, and the loops sit in procedures with no recursion, but several loop-carried counters and the decoder's chain walk need carefully shaped guards.

Position 933 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the task's example string TOBEORNOTTOBEORTOBEORNOT in a constant; store the dictionary as two parallel fixed-capacity arrays (prefix code and last character) with 256 pre-seeded single-character entries, and compress by a for loop over the input that linearly searches the dictionary for the (current code, next character) pair, emitting a code and adding an entry when absent, with a capacity guard that stops adding entries when the table is full. Decompress in a procedure that expands each code by walking the prefix chain into a bounded reverse buffer under a length guard, handling the code-equals-next-entry special case explicitly and rejecting out-of-range codes, then prints the codes and the reconstructed text, which must equal the input. About 110 lines.

## Proof obligations to watch

- **index**: Dictionary lookups, the output code array and the decoder's reverse-expansion buffer are indexed by loop-carried counters, so each use needs a guard just before it (for example a capacity check on the next free entry and on the buffer length) that rejects when full.
- **termination**: The prefix-chain walk in decompression is a while loop, which is acceptable only because it lives in a procedure and is also bounded by an explicit buffer-length guard.
- **range**: Codes are a subtype 0..4095 and the next-entry counter increments in a loop, so the program guards the increment against the capacity limit instead of relying on an invariant.
- **initialization**: The dictionary arrays and the buffers must be fully initialized by loops or aggregates before use, which flow analysis tracks reliably for whole-array aggregate initialization.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, Put without a newline, Boolean objects and conditional expressions.

## External effects

- **console output** (allowed): Prints the compressed code list and the round-tripped text.

Assessed on 2026-10-15 against page revision 414300 of the [task](https://rosettacode.org/wiki/LZW_compression) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
