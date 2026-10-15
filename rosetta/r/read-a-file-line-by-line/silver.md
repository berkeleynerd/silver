# Read a file line by line

**Candidate: proofs plausibly discharge automatically.** The program is a simple read-and-echo loop whose checks follow from a bounded buffer and library contracts, with no loop-carried arithmetic. The plausible rating reflects the not-yet-existing file-input library and the over-long-line and open-failure handling that must be specified.

Position 1331 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program has a Main procedure that opens a fixed, embedded file name through an admitted bounded line-reading library. It loops with a while loop until the library reports end of file, reading each line into a fixed-capacity String buffer with a returned length, and echoes it with Put_Line. It guards the open call, rejecting with a visible message if the file cannot be opened, and treats over-long lines as a specified rejection. About 30 lines.

## Proof obligations to watch

- **length**: Lines longer than the fixed-capacity buffer must have a specified outcome (reject or documented truncation), and the guard has to come from the library's bounded read contract so the length check discharges.
- **index**: Indexing into the line buffer discharges only if the library returns a length within the buffer's declared range, or if for loops run over the buffer's own range.
- **termination**: The read-until-end-of-file loop must be a while loop inside a procedure, since procedures get no termination check and functions would.
- **other**: The program depends on an admitted file-reading library with specified failure outcomes for a missing or unreadable file and for end of file, which Silver does not yet have.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, procedures, while loops, for loops, string building, file input and standard input.

## External effects

- **files** (allowed): The program must open a named file for reading and read it line by line, with a specified outcome if it cannot be opened.
- **console output** (allowed): Each line read is echoed to standard output with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414893 of the [task](https://rosettacode.org/wiki/Read_a_file_line_by_line) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
