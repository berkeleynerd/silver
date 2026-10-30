# Stream merge

**Candidate: proofs likely to discharge automatically.** All checks follow from bounded buffer types, a Has_Item guard before every comparison, and a while loop confined to a procedure, so no annotation is needed once Silver gains file reading, string ordering and extra arguments.

Position 1474 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Each stream is a record holding an open admitted file reader, a fixed-capacity line buffer with a ranged length, and an Has_Item flag; a procedure Fetch refills the buffer or clears the flag at end of file, rejecting over-long lines. A while loop in a procedure runs while either stream has an item, choosing the smaller buffered line (or the only available one) by guarded string comparison, printing it with Put_Line and refetching from that stream. Arguments are validated first (two readable file names), and the N-stream variant would be the same loop over an array of such records with a for loop selecting the minimum. About 110 lines.

## Proof obligations to watch

- **length**: Each line is read into a fixed-capacity buffer with a length field, and a line longer than the capacity is rejected with a visible outcome, so slice and comparison bounds follow from the length subtype.
- **index**: Comparing buffered lines uses only the prefix 1 .. Length of each buffer, which is bounded by the declared capacity, and the minimum-selection loop runs over the array's own range.

## Language surface recorded by this assessment

Records, Boolean objects, ranged subtypes, integers, procedures, while loops, string ordering, string building, string indexing, file input, further arguments, exit status, arrays and for loops.

## External effects

- **arguments** (allowed): The two input file names come from the command line.
- **files** (allowed): Each input stream is a named file read line by line without loading it whole.
- **console output** (allowed): The merged sorted lines are written to standard output.
- **exit status** (allowed): An unreadable file, missing argument or over-long line is rejected with a failure status.

Assessed on 2026-10-15 against page revision 414520 of the [task](https://rosettacode.org/wiki/Stream_merge) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
