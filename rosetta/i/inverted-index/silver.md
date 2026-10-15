# Inverted index

**Candidate: proofs plausibly discharge automatically.** The program is bounded loops over fixed-capacity arrays with guards before each index, so it likely proves without annotations, but tokenizing, table capacity limits and loop-carried counters make it depend on careful program shape. It also needs a large new surface (file and stdin input, strings, arrays, records).

Position 1495 in the [progression](../../progression.md#stage-30), in stage 30.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Keep a fixed-capacity table of distinct words (bounded String buffers with lengths), each with a Boolean array marking which of a small fixed number of files contain it. A procedure reads each named file line by line via an admitted file library, tokenizes letters into words with guarded scan indexes, and inserts them with a linear search, reporting a visible message when a capacity is exceeded; a search loop reads query lines from stdin, looks up each word, ANDs the file marks, and prints the matching file names or a not-found message until an empty line. About 170 lines.

## Proof obligations to watch

- **index**: Word tokenizing over bounded line buffers needs scan positions guarded just before each indexed access, since loop-carried positions have only type ranges.
- **length**: Words, lines, file names and the word table have fixed capacities, and over-long input must give a specified rejection or skip outcome instead of silent truncation.
- **termination**: All scanning and search loops live in procedures or are for loops, so no variant is needed, provided the tokenizer is not written as a while loop inside a function.
- **initialization**: Fixed-capacity word and posting tables must be fully initialized before use, and count variables must stay within the capacity range via guards.
- **other**: File-read failure (missing or unreadable file) must be reported as a visible outcome through the admitted file library rather than an exception handler.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string indexing, string building, string ordering, text parsing, for loops, while loops, procedures, functions, Put without a newline, standard input, file input and conditional expressions.

## External effects

- **standard input** (allowed): Reads the file-name line and each search query line interactively.
- **files** (allowed): Reads the named text files to build the index.
- **console output** (allowed): Prompts and lists matching file names.

Assessed on 2026-10-15 against page revision 414271 of the [task](https://rosettacode.org/wiki/Inverted_index) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
