# Find words which contains more than 3 e vowels

**Candidate: proofs likely to discharge automatically.** Every index and counter is bounded by the 64-character buffer or by the capped counter type, and the only loop-carried facts are a capped count and a Boolean flag whose safety follows from their types. Nothing needs an annotation, and the file-read failure and over-long-line cases have explicit rejection outcomes.

Position 1313 in the [progression](../../progression.md#stage-22), in stage 22, which adds file input.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A main procedure opens unixdict.txt through an admitted file-input library operation and loops with a while loop until end of file, reading each line into a fixed 64-character buffer plus a length. For each word a for loop over 1 .. Length classifies each character (lowercased by comparison) as e, another vowel (a, i, o, u) or other, counting e occurrences up to a cap of 4 and setting a Boolean when another vowel appears; the word is printed with Put_Line when the cap is reached and no other vowel was seen. About 45 lines.

## Proof obligations to watch

- **overflow**: The e-count is a loop-carried value, so it is kept in a small ranged subtype and incremented only while below 4, which still decides 'more than three' exactly without changing any result.
- **length**: Lines are read into a fixed 64-character buffer with an explicit length, and a longer line takes a specified outcome (reject the input) so slices and indexes stay in bounds.
- **termination**: The read-until-end-of-file while loop lives in a procedure, which gets no termination check, and the per-word scan is a for loop over the buffer's own range.

## Language surface recorded by this assessment

Characters, string indexing, string building, integers, ranged subtypes, Boolean objects, for loops, while loops, procedures and file input.

## External effects

- **files** (allowed): Reads the dictionary file unixdict.txt line by line, with a specified outcome if it is missing or unreadable.
- **console output** (allowed): Prints each qualifying word with Put_Line.

Assessed on 2026-10-15 against page revision 404093 of the [task](https://rosettacode.org/wiki/Find_words_which_contains_more_than_3_e_vowels) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
