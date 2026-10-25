# File input/output

**Candidate: proofs likely to discharge automatically.** Every check follows from the buffer's declared capacity, the Length subtype and status guards before the slice write, with no loops or recursion in user code. The needed whole-file read and write operations are new library effects with specified failure outcomes, not Oracle conflicts.

Position 1560 in the [progression](../../../progression.md#stage-35), in stage 35.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The program holds the file contents in a fixed-capacity String buffer (for example 65536 characters) with a Natural length bounded by that capacity, filled by one admitted whole-file read operation that returns a status. If the status is Ok it writes the buffer slice 1..Length to output.txt through an admitted whole-file write operation and checks that status; every failure branch prints a message and sets the failure exit status. No loops are needed because the library operations carry the iteration. About 25 lines.

## Proof obligations to watch

- **length**: The input size is unknown, so the read operation must report the byte count within the buffer capacity or an explicit too-large status, and the slice written is guarded by that status and a Length subtype bounded by the capacity.

## Language surface recorded by this assessment

File input, file output, string building, string indexing, ranged subtypes, exit status and standard error.

## External effects

- **files** (allowed): The program reads the named file input.txt and creates or overwrites output.txt.
- **exit status** (allowed): A failed open, oversized input or failed write must be reported through a failure exit status.
- **console output** (allowed): A failure message names the file that could not be read or written.

Assessed on 2026-10-15 against page revision 415147 of the [task](https://rosettacode.org/wiki/File_input/output) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
