# JSON pointer

**Candidate: proofs likely to discharge automatically.** Every check follows from declared ranges on node indexes and lengths, for loops over static arrays and pointer ranges, and explicit guards before buffer appends and digit accumulation, so no annotation is needed and outlook is likely.

Position 1181 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

The example document is embedded as a constant array of node records (kind enumeration Object/Array/Text, parent index, key in a fixed buffer with length, and the node's JSON text in a fixed buffer with length), plus the full document text for the root. A Resolve procedure takes each pointer string, rejects it if it is non-empty and does not start with '/', then walks its characters in a for loop, decoding ~0 and ~1 into a bounded token buffer (rejecting an invalid escape) and, at each '/' or at the end, picks the matching child by a for loop over the node table: by key equality for objects, or by guarded digit parsing and child counting for arrays. Any failed lookup, over-long token or out-of-range index prints a specific error message; otherwise the current node's stored JSON text is printed. About 170 lines.

## Proof obligations to watch

- **index**: Appending a decoded character to the fixed token buffer is preceded by a guard on the token length, and an over-long token is reported as an error.
- **overflow**: Accumulating an array-index token's digits is guarded by checking the value is below a small bound before multiplying by 10, and an out-of-bound value is reported as an error.
- **range**: The current node, the token length and stored key or text lengths are declared range subtypes, so slices such as Key (1 .. Key_Len) and node lookups stay in bounds after each loop iteration without invariants.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, records, unconstrained arrays, string indexing, string building, for loops, procedures and functions.

## External effects

- **console output** (allowed): Each test pointer is printed with its resolved JSON value or an error message.

Assessed on 2026-10-15 against page revision 412121 of the [task](https://rosettacode.org/wiki/JSON_pointer) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
