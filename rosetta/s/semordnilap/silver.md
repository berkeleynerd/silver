# Semordnilap

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded array types, capacity guards and for-index ranges, and the only while loop is a binary search in a procedure, but it needs careful shape for the loop-carried bounds and depends on the missing file-input operation.

Position 1356 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Load the file line by line into a bounded array of fixed-width rows (about 26000 words by 32 characters) with a length array, rejecting overlong lines or too many words and checking ascending order. For each word, build its reverse into a buffer with a for loop, skip palindromes, binary-search the earlier words for the reverse in a procedure with a while loop, count each hit once, and print the first five pairs followed by the total. About 130 lines.

## Proof obligations to watch

- **index**: Word storage is a fixed-capacity array of fixed-width character rows plus a length array, so every insertion is guarded by a count check against capacity and a word length check against width, with overflow rejected visibly.
- **index**: Binary search midpoint is computed as Lo + (Hi - Lo) / 2 under subtype ranges and guarded by Lo <= Hi, so the index stays inside 1 .. Count without an invariant.
- **termination**: Binary search uses a while loop, so it lives in a procedure with an out result (no termination check), and the reversed-word comparison uses for loops only.
- **overflow**: The pair counter is bounded by the word capacity subtype, and the loop-carried count is guarded to stay below capacity before each increment.
- **other**: Binary search is only correct on sorted input, so the program verifies sortedness while loading and rejects an unsorted file with a message rather than assuming it.

## Language surface recorded by this assessment

File input, standard input, integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions, Put without a newline and exit status.

## External effects

- **files** (allowed): Reads the unixdict.txt word list from a named file, with a specified outcome when it is missing, unreadable or over capacity.
- **arguments** (allowed): The dictionary file name is taken from the first command-line argument.
- **console output** (allowed): Prints five example pairs and the total number of unique pairs.
- **exit status** (allowed): Rejecting an unreadable or invalid dictionary needs a specified non-zero exit outcome.

Assessed on 2026-10-15 against page revision 413902 of the [task](https://rosettacode.org/wiki/Semordnilap) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
