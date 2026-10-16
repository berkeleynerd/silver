# Anagrams

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed capacities, ranged indexes and guards, and everything runs in procedures, but the hash probing, key comparison and many loop-carried counters need careful shaping, and the external word list requires stdin line reading.

Position 1366 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Read lines from stdin into fixed-capacity arrays (about 26000 words of up to 24 characters, rejecting overflow or non-lowercase input), compute for each word a sorted-letter key by counting sort over the 26 letters, and group words by key through an open-addressing table of record entries with a group count. A second pass finds the maximum group size and prints every group of that size, with words comma-separated using Put, all in procedures with ranged-subtype indexes and guards before each indexed access. About 170 lines.

## Proof obligations to watch

- **index**: Hash-table probing and group lookup use computed indexes, discharged by ranged-subtype index arithmetic with an explicit wrap guard just before each use.
- **length**: Each word is copied into a fixed 24-character buffer with a stored length, guarded by rejecting lines longer than the limit before the copy.
- **overflow**: Word counts, per-group counts and hash accumulators are held in ranged types bounded by the declared capacity, with a capacity guard that rejects excess input.
- **termination**: All reading, probing and grouping loops are while loops inside procedures, so no termination check applies, and the table is kept under-full so probing always finds a slot.
- **initialization**: All arrays of words, keys and counts are fully initialized with aggregates before the read loop.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, Boolean objects, arrays, records, string indexing, string building, for loops, while loops, procedures, functions, standard input, Put without a newline, exit status and integer division.

## External effects

- **standard input** (allowed): The word list (unixdict.txt) is piped in on standard input line by line.
- **console output** (allowed): The largest anagram sets are printed one per line as comma-separated words.
- **exit status** (allowed): Input that exceeds the word count or word length limits, or has non-lowercase characters, is rejected with a nonzero status.

Assessed on 2026-10-15 against page revision 414055 of the [task](https://rosettacode.org/wiki/Anagrams) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
