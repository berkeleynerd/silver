# Find words whose first and last three letters are equal

**Candidate: proofs likely to discharge automatically.** Every check follows from a bounded buffer, a length guard placed just before the indexing, and a for loop over a fixed three-element range, while the while loop lives in a procedure so it needs no variant.

Position 1311 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A procedure opens unixdict.txt through an admitted file-input operation and loops with a while loop, reading each line into a bounded String buffer plus a length in a ranged subtype, rejecting open failures and over-capacity lines with a visible message. For each line with length greater than 5, a for loop over offsets 0 to 2 compares the first three characters with the last three, and the word is printed only if all match. About 45 lines.

## Proof obligations to watch

- **index**: Indexing the last three characters is guarded by testing that the line length exceeds 5 just before the comparison, so Length-2 and the three offsets are in range.
- **length**: Lines are read into a fixed-capacity buffer and a line longer than the capacity gets a specified rejection outcome rather than silent truncation.

## Language surface recorded by this assessment

File input, integers, ranged subtypes, arrays, string indexing, string building, for loops, while loops, procedures, Boolean objects and Put without a newline.

## External effects

- **files** (allowed): The program reads the named dictionary file unixdict.txt line by line, with a specified outcome when it cannot be opened.
- **console output** (allowed): Each matching word is printed on its own line.

Assessed on 2026-10-15 against page revision 406593 of the [task](https://rosettacode.org/wiki/Find_words_whose_first_and_last_three_letters_are_equal) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
