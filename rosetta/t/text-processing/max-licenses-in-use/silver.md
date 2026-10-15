# Text processing/Max licenses in use

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded subtypes plus guards placed just before each operation, and the only loop is a while loop inside a procedure, so nothing needs an annotation. The main gap is the missing admitted file-input operation and bounded line reading, not any proof difficulty.

Position 1362 in the [progression](../../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The log file is read line by line in a while loop within a procedure, with fixed-capacity line buffers. Each line is validated (length, OUT/IN marker at the fixed column), then a count in a bounded subtype is incremented or decremented behind explicit guards. A record array of 19-character timestamps holds the times at the current maximum, reset when a new maximum is found and appended on ties behind a capacity guard, and the result is printed with a bounded text conversion of the count. About 100 lines.

## Proof obligations to watch

- **overflow**: The in-use count is a subtype 0..10000 whose increment is guarded by count < 10000 and whose decrement is guarded by count > 0, so an IN with nothing out is rejected as malformed rather than clamped.
- **index**: The stored max-time list has capacity 10000 and is appended only after a guard on its length, and the line counter is guarded so a longer log is rejected visibly.
- **length**: Each line is checked for length at least 33 and for the OUT or IN marker before the timestamp slice is copied, since the loop-carried state is known only by its type.
- **termination**: The read loop is a while loop inside a procedure, which gets no termination check, so no variant is needed.
- **other**: The program depends on an admitted file-reading library operation with specified end-of-file, open-failure and over-long-line outcomes that does not yet exist.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, string indexing, arrays, records, for loops, while loops, procedures, Put without a newline, 'Image of scalars, file input and exit status.

## External effects

- **files** (allowed): The task requires scanning a saved 10,000-line license log file, so the program reads a named local file line by line.
- **console output** (allowed): The maximum count and the matching timestamps are printed to standard output.
- **arguments** (allowed): The log file name is taken from the first command-line argument.
- **exit status** (allowed): A missing, unreadable or malformed log is rejected with a nonzero exit status.

Assessed on 2026-10-15 against page revision 413945 of the [task](https://rosettacode.org/wiki/Text_processing/Max_licenses_in_use) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
