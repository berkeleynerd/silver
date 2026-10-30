# Read a specific line from a file

**Candidate: proofs plausibly discharge automatically.** All checks follow from a small counter, a bounded buffer and guards before each store, but the task needs an admitted library file-reading operation that reports failure and over-long lines as specified outcomes, and Silver has none yet. Nothing needs an annotation, and the original Ada exception handlers are replaced by explicit status results.

Position 1454 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program takes the file name from the first argument (or embeds a fixed name), reads lines one at a time through an admitted line-reading operation in a while loop inside a procedure, counting lines in a small ranged counter until the seventh is reached. The seventh line is kept in a fixed-capacity buffer with a length, and after the loop it prints the line, "Line 7 is empty.", "The file contains fewer than 7 lines.", "Line 7 is too long to load." or an open-failure message, each as its own visible branch. About 45 lines.

## Proof obligations to watch

- **index**: Line text goes into a fixed-capacity buffer, and a length guard before each store (reject lines over capacity with a message) keeps the index in range.
- **termination**: The line-reading loop is a while loop inside a procedure, which gets no termination check, so no variant is needed.
- **overflow**: The line counter is a range-typed value capped at 7 by the loop's exit condition, so increments are guarded.
- **other**: The admitted file-read library operation must report open failure and end-of-file as specified outcomes that the program turns into messages.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures, file input, standard input and further arguments.

## External effects

- **files** (allowed): Reads a named file line by line to reach the seventh line.
- **console output** (allowed): Prints the seventh line or a message for a short file, an empty line 7, or an over-long line.

Assessed on 2026-10-15 against page revision 415009 of the [task](https://rosettacode.org/wiki/Read_a_specific_line_from_a_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
