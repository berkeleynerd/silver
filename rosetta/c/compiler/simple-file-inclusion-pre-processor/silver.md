# Compiler/Simple file inclusion pre processor

**Candidate: proofs plausibly discharge automatically.** Everything is bounded text processing over fixed buffers with an explicit file stack, so no annotations are needed, but the many index and slice guards and the file-library dependency make careful program shape necessary.

Position 1491 in the [progression](../../../progression.md#stage-29), in stage 29.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The program takes input and output file names from the arguments, then processes lines in a procedure with an explicit fixed-depth stack of open input files (say 8 levels) instead of recursion, which gives bounded nested includes. Each line is read into a bounded buffer, trimmed, tested for a leading #include followed by a quoted name, and either replaced by pushing the named file or copied to the output; unopenable files, over-long lines, over-deep nesting and malformed directives each reject with a specified message and nonzero status. About 130 lines.

## Proof obligations to watch

- **index**: Line buffers are fixed-capacity strings, so the directive scan, trim and quote search need guards before each indexed read and slice, and over-long lines must be rejected with a visible outcome.
- **length**: Extracting the quoted file name into a bounded buffer needs the computed slice length checked against the capacity before copying.
- **termination**: The line-reading and scanning loops are while loops, so they must live in procedures (no termination check) and nesting is done by an explicit bounded stack of open files rather than recursion.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, string ordering, text parsing, for loops, while loops, procedures, functions, further arguments, file input, file output, exit status and Put without a newline.

## External effects

- **files** (allowed): Reads the main source file and each included file by name, and writes the combined output file.
- **arguments** (allowed): Takes the input and output file names (and could take a nesting option) from the command line.
- **console output** (allowed): Reports completion or an open-failure message to the console.
- **exit status** (allowed): Signals failure to open a file or an over-deep nesting with a nonzero status.

Assessed on 2026-10-15 against page revision 413670 of the [task](https://rosettacode.org/wiki/Compiler/Simple_file_inclusion_pre_processor) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
