# Function frequency

**Candidate: proofs likely to discharge automatically.** The task permits static analysis of source text, which an ordinary file scan does, so nothing conflicts with the Oracle. Every loop-carried value (word length, table size, counts) can be guarded just before use, and the read loop sits in a procedure, so no annotation is needed.

Position 1330 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A procedure opens the named source file and reads it line by line in a while loop. Each line is scanned with a for loop over its range to collect identifiers, lowercased into a bounded word buffer, and each identifier goes into a fixed-capacity array of records holding a word, its length and a count. The table is searched linearly, and every append, insertion and count increment is guarded against its capacity, with a visible rejection if a capacity is exceeded. Ten selection passes with for loops then print the most frequent entries using 'Image. About 120 lines.

## Proof obligations to watch

- **index**: The current word length and the number of table entries are loop-carried, so each append or insertion is preceded by a guard against the declared capacity, and exceeding it rejects the input with a visible message.
- **overflow**: Each occurrence count increment is guarded by a test against Natural'Last just before it, with a visible rejection if it ever fails.
- **length**: Comparing a scanned word with a stored entry uses slices bounded by length fields whose subtype is 0 .. Max_Word, so the slice bounds follow from the types.
- **other**: Lines longer than the admitted file-reading operation's bounded buffer must be detected and given a specified outcome rather than silently truncated.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions and file input.

## External effects

- **files** (allowed): The program statically analyzes a source file (such as its own source) by reading it line by line.
- **arguments** (allowed): The name of the source file to analyze is taken from the command line, with a default of the program's own source file name.
- **console output** (allowed): The top ten identifiers and their counts are printed one per line.

Assessed on 2026-10-15 against page revision 415002 of the [task](https://rosettacode.org/wiki/Function_frequency) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
