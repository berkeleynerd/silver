# Longest common suffix

**Candidate: proofs likely to discharge automatically.** All loops are bounded for loops over ranged subtypes and every index is guarded by a length comparison just before use, so the checks follow from types and guards without any annotation. The new needs are small: records, arrays of records, character indexing, slices and non-terminating Put output.

Position 612 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Each word is a record holding a fixed-capacity String (1 .. 16) and a Length in 0 .. 16, and the test lists are constant arrays of these records embedded in the program with the task's example data. A procedure takes the list and a count, starts with the first word's length as the candidate suffix length, and for each further word uses a bounded for loop comparing characters from the end (guarded by P <= Len of both words) to shrink the length to the true common suffix length. Main prints each list and the resulting suffix via Put and Put_Line with slices of the Data field. About 110 lines.

## Proof obligations to watch

- **index**: Character reads from the end of each word use Data (Len - P + 1), which is discharged by for-loop bounds P in 1 .. K where K is a ranged count never exceeding the word's Len, plus an explicit guard just before the read.
- **range**: The loop-carried common-suffix length is declared with the subtype 0 .. 16 and only ever assigned a value from a guarded for-loop index, so its range check follows from its type.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, Boolean objects, arrays, records, string indexing, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each test case's word list and its longest common suffix to standard output.

Assessed on 2026-10-15 against page revision 408572 of the [task](https://rosettacode.org/wiki/Longest_common_suffix) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
