# User defined pipe and redirection operators

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, for-loop indexes and capacity guards, and no recursion or annotation is needed, though the loop-carried buffer counts and substring search need careful shape. Needing file output is an effect Silver lacks today, not a conflict.

Position 1490 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

The 22 scientist records are embedded as a constant array of fixed-width lines held in a record with a length, and each filter (head, tail, grep, sort, uniq, tee) is a procedure moving records between fixed-capacity bounded stream buffers, with the Unix operators replaced by the alternate procedure names since Ada cannot overload the pipe symbol. Records are passed on one at a time where the filter allows and sort buffers only as sort inherently requires, with explicit capacity guards that reject overflow visibly. Tee writes the two named files and the final grep on 'aa' prints the Pioneer line. About 190 lines.

## Proof obligations to watch

- **index**: Substring matching for grep slices a fixed-width line at a computed offset, which is discharged by a for loop bounded by the pattern and line lengths so every slice stays in range.
- **index**: Head, tail, uniq and sort insert into fixed-capacity record arrays with loop-carried counts, which are discharged by count subtypes bounded by the capacity and an explicit capacity guard before each append.
- **termination**: All loops live in procedures or are for loops, and the pipeline stages are procedures with no recursion, so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, unconstrained arrays, string indexing, string ordering, for loops, while loops, procedures, functions, Put without a newline, file output and string building.

## External effects

- **console output** (allowed): The program prints the Pioneer line to standard output.
- **files** (allowed): tee writes ALGOL_pioneers.lst and the_important_scientists.lst as named files.

Assessed on 2026-10-15 against page revision 414567 of the [task](https://rosettacode.org/wiki/User_defined_pipe_and_redirection_operators) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
