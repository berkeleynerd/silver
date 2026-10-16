# Find words which contain all the vowels

**Candidate: proofs likely to discharge automatically.** Every check follows from loop ranges, a bounded buffer with a library-provided length, and tallies capped by explicit guards, so no annotation is needed. The only new needs are file reading and ordinary loops, character, and case constructs.

Position 1325 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Main opens unixdict.txt through an admitted library reader and loops with a while loop until end of file, reading each line into a fixed 80-character buffer with a Length; a line exceeding the capacity is rejected with a visible outcome. For each line longer than 10 characters, a for loop over its indices uses a case on the Character to update five 0..2 tallies (a, e, i, o, u) with guarded saturating increments, and the word is printed with Put_Line when all five tallies equal 1. About 60 lines.

## Proof obligations to watch

- **index**: The for loop runs over 1 .. Length of a fixed-capacity line buffer whose length is bounded by the library read operation, so every Line (I) access follows from the loop range and the Length subtype.
- **overflow**: Per-vowel tallies are 0..2 subtype counters incremented only under an explicit guard that the tally is below 2, so the check discharges without an invariant while still distinguishing zero, one and more than one.
- **length**: A line longer than the buffer capacity has a specified outcome of being reported as rejected rather than truncated, so printing the word as Line (1 .. Length) is always in range.
- **termination**: The read-until-end-of-file while loop lives in the Main procedure, which gets no termination check, and the inner loops are for loops.

## Language surface recorded by this assessment

File input, while loops, for loops, characters, string indexing, string building, ranged subtypes, integers, Boolean objects, procedures, case statements and arrays.

## External effects

- **files** (allowed): The program reads the named dictionary file unixdict.txt line by line through an admitted file-input operation with specified open-failure and end-of-file outcomes.
- **console output** (allowed): Each qualifying word is printed on its own line with Put_Line.

Assessed on 2026-10-15 against page revision 415550 of the [task](https://rosettacode.org/wiki/Find_words_which_contain_all_the_vowels) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
