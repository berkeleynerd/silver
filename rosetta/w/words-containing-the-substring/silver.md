# Words containing "the" substring

**Candidate: proofs likely to discharge automatically.** Every check is a loop-index or guard-based bound on a small fixed buffer and the while loop sits in a procedure, so no annotation is needed; the only new ingredients are bounded line reading from a file and character indexing.

Position 1312 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A procedure opens unixdict.txt via an admitted file-reading library, reads each line into a bounded 40-character buffer with a returned length in a while loop, and an explicit failure branch handles an unopenable file or over-long line. For each line with length above 11, a for loop over start positions 1 .. Length-2 compares three characters to 't','h','e'; matches are printed with Put_Line and counted in a range-guarded Natural counter, and a final count line is printed. About 45 lines.

## Proof obligations to watch

- **index**: The substring scan indexes Line(I..I+2) only for I in 1 .. Len-2 after a guard Len > 11, so bounds follow from the loop range and the admitted line reader's Length postcondition.
- **overflow**: The found-word counter is incremented only under an explicit guard against its declared capacity, with an overflow outcome of stopping and reporting rather than wrapping.
- **length**: Lines longer than the fixed 40-character buffer are reported by the library reader as a specified outcome (reject or truncate-flag) and handled by an explicit branch rather than silently dropped.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, Put without a newline, file input and Boolean objects.

## External effects

- **files** (allowed): Reads the dictionary file unixdict.txt line by line, with a specified outcome when it cannot be opened.
- **console output** (allowed): Prints each found word and a final count to standard output.

Assessed on 2026-10-15 against page revision 412243 of the [task](https://rosettacode.org/wiki/Words_containing_%22the%22_substring) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
