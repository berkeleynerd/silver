# Fixed length records

**Candidate: proofs likely to discharge automatically.** Every check follows from the 1..80 index subtype, a fixed record capacity guard and for loops over the array range, so the only new need is admitted library operations for fixed-size binary file reads and writes. The optional Forth block bonus is omitted.

Position 1425 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Use a subtype Column of Integer range 1 .. 80 and a Record_Text String (1 .. 80), with a fixed-capacity table of at most 100 records. A procedure reads records through an admitted binary file-read operation in a while loop guarded by a count below capacity, then a for loop over Column reverses each record by indexing Rec (81 - I), and a second procedure writes each result as 80 bytes and echoes it to the console. Over-capacity or short-record input is rejected with a visible outcome. About 55 lines.

## Proof obligations to watch

- **index**: The reversed index 81 - I and the record-table index are bounded by the 1..80 subtype and by a guard that rejects input once the fixed record capacity is full.
- **length**: A file whose size is not a multiple of 80 bytes is rejected with a specified outcome by the admitted read operation, so no padding is silently invented.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, for loops, while loops, procedures, Put without a newline, file input and file output.

## External effects

- **files** (allowed): Reads 80-byte records from infile.dat and writes reversed 80-byte records to outfile.dat as raw bytes without terminators.
- **console output** (allowed): Echoes the input and output records as text lines to show the result.

Assessed on 2026-10-15 against page revision 414214 of the [task](https://rosettacode.org/wiki/Fixed_length_records) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
