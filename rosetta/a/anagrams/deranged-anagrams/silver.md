# Anagrams/Deranged anagrams

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, subtype ranges and guards before use, and there are no recursion, functions with while loops or annotations, but the quadratic nested loops over a large fixed-capacity table with loop-carried best-length state need careful shaping.

Position 1363 in the [progression](../../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Store words in a fixed-capacity array of records (padded 24-character buffer, length, 26-entry letter-count array) filled by a while loop in a procedure that reads lines, rejecting any line that is too long, non-lowercase, or beyond capacity. Then nested for loops over word pairs, skipping pairs not longer than the current best, compare lengths and count arrays and call a for-loop function that checks no position has equal characters, recording the best pair indexes. Print the pair, or a specified message if none is found. About 110 lines.

## Proof obligations to watch

- **index**: Letter-count indexing from Character is guarded by an explicit a-to-z check before use, and word and line indexes are bounded by fixed-capacity array ranges.
- **overflow**: Letter counts and the best-length value are loop-carried but stay within small declared subtype ranges, with a capacity guard before each increment.
- **length**: Each line is copied into a fixed-length buffer only after a length guard, and over-long lines or too many words are rejected visibly.
- **termination**: The read loop is a while loop inside a procedure, so it has no termination check, and all functions use only for loops.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string indexing, string building, for loops, while loops, procedures, functions, file input, Put without a newline and exit status.

## External effects

- **files** (allowed): Reads the word list file unixdict.txt line by line, with specified failure outcomes for a missing or unreadable file.
- **console output** (allowed): Prints the longest deranged anagram pair, or a message when none exists.
- **exit status** (allowed): Invalid or oversized word list input is rejected with a nonzero status.

Assessed on 2026-10-15 against page revision 413971 of the [task](https://rosettacode.org/wiki/Anagrams/Deranged_anagrams) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
