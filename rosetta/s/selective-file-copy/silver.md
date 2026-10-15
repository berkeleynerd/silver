# Selective file copy

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed record widths, a length guard before slicing, and digit validation before conversion, with only the file-library effects missing from Silver today. Discharge depends on careful program shape around the parse and the bounded output buffer but needs no annotations.

Position 1449 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

A record type holds fields a (5 chars), b (10 chars), a signed integer c (digits plus sign) and d (20 chars), and a procedure loops over lines read from the input file with a library read-line operation that reports end of file. Each line is length-guarded, the digit field is validated and converted with explicit range guards, and the output line is assembled in a bounded buffer from a, the image of c, and a run of X characters, then written to the output file. Invalid or short records and file failures lead to a specified rejection rather than a silent skip. About 70 lines.

## Proof obligations to watch

- **index**: Field slices of each fixed-width record are only taken after a guard that the line length is at least the record width, and a short line gets a visible rejection outcome.
- **range**: The four-digit count and its sign convert to a subtype of -9999..9999 only after each character is checked as a digit, and a non-digit rejects the record.
- **length**: Each output line is built in a fixed-capacity buffer sized for the 5 + 5 + 6-character fields, so the concatenation length is statically bounded.
- **termination**: The read-until-end-of-file loop is a while loop inside a procedure, which receives no termination check.
- **other**: File open, read and write failures must surface as specified outcomes from the admitted file library operations rather than exceptions.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, records, arrays, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, file input, file output and further arguments.

## External effects

- **files** (allowed): Reads fixed-width input records from a named file and writes the selected, converted fields to an output file.
- **arguments** (allowed): The input and output file names are taken from the command line, with defaults, so the file operations have specified names.

Assessed on 2026-10-15 against page revision 374982 of the [task](https://rosettacode.org/wiki/Selective_file_copy) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
