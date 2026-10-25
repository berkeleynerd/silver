# WiktionaryDumps to words

**Candidate: proofs plausibly discharge automatically.** The line scanning and bounded string extraction are plain guarded index logic in a loop inside a procedure and would likely prove, but the bz2 input and file library operations are not yet available and bounded buffers need careful guards.

Position 1442 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

Read the decompressed XML dump line by line from a named file into a fixed-length line buffer, tracking the current title between title tags and a Boolean for being inside a text element. When a line contains the language header marker such as ==Spanish==, copy the title into a bounded word buffer and write it as one line to the output file, rejecting over-long lines or titles with a specified outcome and stopping at a documented maximum word count. About 120 lines.

## Proof obligations to watch

- **index**: Scanning each line for title and language markers needs guarded index arithmetic into a bounded line buffer, discharged by explicit bounds checks before each access.
- **length**: Lines longer than the buffer and titles longer than the word buffer must be rejected with a visible outcome rather than truncated silently.
- **other**: The real 800MB bz2 dump needs an admitted decompression or streaming operation that does not exist yet, so the program would read a decompressed XML file.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures, file input, file output and further arguments.

## External effects

- **files** (allowed): Reads the named dump file and writes the output word list file.
- **arguments** (allowed): Takes the input and output file names from the command line.

Assessed on 2026-10-15 against page revision 408346 of the [task](https://rosettacode.org/wiki/WiktionaryDumps_to_words) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
