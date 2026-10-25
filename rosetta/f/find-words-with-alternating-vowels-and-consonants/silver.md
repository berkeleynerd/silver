# Find words with alternating vowels and consonants

**Candidate: proofs likely to discharge automatically.** All checks are index and length facts that follow from the for-loop range and the length guard, and the only loop-carried value is a Boolean, so no invariant is needed; the work lies in the file-input library operation, not in proofs.

Position 1315 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Main procedure opens unixdict.txt through an admitted file-input operation and loops with while not at end of file, reading each line into a bounded buffer (say 64 characters) with a length. For each line longer than 9, a for loop over the buffer's valid indexes tracks a Boolean "expected vowel" flag against an Is_Vowel Boolean function on Character, exiting on the first mismatch, and prints the word when the whole word alternates. A missing file or an over-long line is rejected with a specified message. About 45 lines.

## Proof obligations to watch

- **length**: Each line goes into a fixed-capacity buffer through an admitted line-reading operation that reports the length, and over-long lines are rejected with a visible outcome.
- **index**: Character indexing happens in a for loop over 1 .. Length, guarded by Length > 9 so empty lines are never indexed.
- **termination**: The read loop is a while loop inside a procedure, so it gets no termination check, and the per-word scan is a for loop.

## Language surface recorded by this assessment

Boolean objects, characters, integers, ranged subtypes, string indexing, string building, for loops, while loops, procedures, functions and file input.

## External effects

- **files** (allowed): Reads unixdict.txt line by line, with a specified outcome if the file is missing or unreadable.
- **console output** (allowed): Prints each qualifying word with Put_Line.

Assessed on 2026-10-15 against page revision 413620 of the [task](https://rosettacode.org/wiki/Find_words_with_alternating_vowels_and_consonants) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
