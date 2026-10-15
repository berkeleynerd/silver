# Find words which contain the most consonants

**Candidate: proofs plausibly discharge automatically.** Every check follows from small declared ranges, fixed buffers and for loops over the buffer, with only the loop-carried counters needing guards, and line reading happens in a procedure so no variants are needed. The remaining work is an admitted file-reading operation and careful guard placement.

Position 1353 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Open the dictionary and, in a first pass, read each line into a bounded 64-character buffer and, for words longer than 10 letters, use a 256-entry Boolean table to mark each consonant and discard the word on a repeat, tracking the largest distinct-consonant count. A second pass over the file prints each qualifying word whose count equals that maximum, so no word storage is needed. A missing file or an over-long line yields a specified rejection message and failure status rather than a silent change of result. About 70 lines.

## Proof obligations to watch

- **range**: The consonant counter is a loop-carried value, so each increment is guarded by a comparison against its type's upper bound, which exceeds the longest allowed word and so never fires on valid input.
- **length**: Each line is read into a fixed 64-character buffer with a length, and over-long lines get a specified rejection outcome instead of truncation, so indexes stay within the buffer.
- **termination**: The line-reading while loops sit in a procedure, which gets no termination check, and the per-character loops are for loops.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures, file input and exit status.

## External effects

- **files** (allowed): The program reads unixdict.txt line by line, twice, through an admitted file-reading operation with a specified outcome when the file is missing or unreadable.
- **console output** (allowed): The words with the most consonants are printed one per line.
- **exit status** (allowed): A missing file or over-long line is reported with a failure status.

Assessed on 2026-10-15 against page revision 413621 of the [task](https://rosettacode.org/wiki/Find_words_which_contain_the_most_consonants) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
