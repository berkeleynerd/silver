# Read entire file

**Candidate: proofs plausibly discharge automatically.** Reading a file into a bounded String buffer is just a library call with a status result plus guarded copying, so proofs follow from types and the library contract, but Silver needs a file-input library operation and a documented capacity limit that visibly rejects larger files. Memory-mapping, which needs address overlays, is an optional discussion item and is not required.

Position 1471 in the [progression](../../progression.md#stage-29), in stage 29.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Declare a fixed-capacity String buffer (say 64 KiB) and a length subtype, call an admitted Silver_Files read operation that fills the buffer and returns a length and a status (ok, not found, too large, I/O error), then reject on any non-ok status. On success the program prints the first Length characters of the buffer with Put_Line, using a bounded slice or a for loop; the file name is embedded in the program and the encoding is treated as raw bytes (Latin-1 Character), with the memory-mapping discussion omitted since it cannot be done in Silver. About 35 lines.

## Proof obligations to watch

- **length**: The file may be larger than the fixed buffer, so the library read must report truncation or too-large as a specified outcome and the program rejects it visibly rather than truncating.
- **index**: The copy loop runs over the buffer's own index range up to the reported length, which is bounded by the buffer subtype so indexes discharge.
- **other**: Open, read and close failures such as a missing file or I/O error must be returned as status values by the admitted library operation and handled by an explicit rejection path.
- **termination**: Any chunked read loop lives in a procedure, which gets no termination check, and a for loop over the buffer bound would avoid a while loop entirely.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, string building, file input, Put without a newline and packages.

## External effects

- **files** (allowed): The program opens a named text file and reads its entire contents.
- **console output** (allowed): The loaded contents are echoed to standard output to show the load worked.

Assessed on 2026-10-15 against page revision 413214 of the [task](https://rosettacode.org/wiki/Read_entire_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
