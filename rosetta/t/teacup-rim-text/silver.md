# Teacup rim text

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed-capacity bounds, for-loop indexes and guards before each index or append, and no annotation is needed, but the line reader, rotation building and capacity handling demand careful program shape. The big missing pieces are file input, records and arrays, and string building rather than anything proof-hostile.

Position 1494 in the [progression](../../progression.md#stage-29), in stage 29.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Read the dictionary file line by line in a procedure into a fixed-capacity table of records (length plus a fixed-size character buffer), keeping only words longer than two characters, and reject over-long words or table overflow with a visible outcome. For each word, build each rotation in a bounded buffer with for loops and look it up by linear scan over the table, requiring all rotations to be present, to differ from the word and to not all be identical letters. Print a set only when the word is the smallest of its rotations, which avoids permutations, using character-wise comparison. About 130 lines.

## Proof obligations to watch

- **index**: Rotating a word and appending to the bounded word table needs guards on length and table count before each index, which are explicit tests placed just before use.
- **length**: Words longer than the fixed buffer or dictionaries exceeding the table capacity must be rejected or skipped with a visible, specified outcome rather than truncated silently.
- **overflow**: Loop-carried counters are bounded by subtype ranges tied to the table capacity, so increments are guarded by capacity tests.
- **termination**: The line-reading while loop lives in a procedure, and all search loops are for loops, so no variant is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, string ordering, for loops, while loops, procedures, functions, file input and Put without a newline.

## External effects

- **files** (allowed): Reads the Unixdict word list from a named file.
- **console output** (allowed): Prints one line per teacup set of rim words.
- **arguments** (allowed): Optionally takes the dictionary path from the first argument, with a specified rejection if it is missing or unreadable.

Assessed on 2026-10-15 against page revision 413941 of the [task](https://rosettacode.org/wiki/Teacup_rim_text) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
