# Append a record to the end of a text file

**Candidate: proofs plausibly discharge automatically.** All arithmetic and indexing follow from bounded field lengths and buffer guards, so no annotation is needed, but the line builder's loop-carried length and the file library's specified failure outcomes require careful shape. The task has no Oracle conflicts and needs file operations Silver lacks today.

Position 1425 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Define a record type with fixed-capacity String fields and length components, and embed the three records as constants in an array. A procedure formats each record into a bounded line buffer with guarded appends, writes the first two lines through a file-output library operation, then reopens in append mode to write the third. A read-back procedure reads lines and echoes them, rejecting visibly on any I/O failure. About 110 lines.

## Proof obligations to watch

- **length**: Joining fields into a line uses a fixed 256-character buffer with a running length, so each append needs a guard on remaining capacity, and an overflow yields a visible rejection.
- **overflow**: The running length in the line builder is a loop-carried value that discharges only through a guard before each append or a type range capped at the buffer size.
- **range**: UID and GID are small ranged integers, so converting them to digit text needs a bounded digit-extraction loop shaped carefully.
- **termination**: Any digit-extraction or read-back while loop must live in a procedure, since functions cannot carry loop variants.
- **other**: The file library must specify behavior and failure outcomes for create, append and open failures so every I/O error path has a visible result.

## Language surface recorded by this assessment

Records, arrays, ranged subtypes, integers, 'Image of scalars, string building, string indexing, for loops, while loops, procedures, functions, file input, file output and Boolean objects.

## External effects

- **files** (allowed): Creates the passwd-format file, reopens it in append mode to add the third record, then reads it back.
- **console output** (allowed): Prints the 'Appended record: ...' line and the file contents.

Assessed on 2026-10-15 against page revision 414058 of the [task](https://rosettacode.org/wiki/Append_a_record_to_the_end_of_a_text_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
