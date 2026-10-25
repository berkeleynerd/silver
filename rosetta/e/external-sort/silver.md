# External sort

**Candidate: proofs plausibly discharge automatically.** Everything is bounded arrays, ranged integers and procedure loops, so checks follow from types and guards, but the multi-file I/O with failure handling and a k-way merge with several loop-carried indexes needs careful shape and an admitted file library.

Position 1429 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

The program generates a deterministic pseudo-random list of non-negative integers into an input file as fixed-width text, then reads it in chunks into a fixed-size array, sorts each chunk by insertion sort in a procedure, and writes each as a run file. It then does a k-way merge by keeping the current head of each run in a fixed array and repeatedly selecting the minimum with a for loop, writing to the output file, with all file results checked and rejected visibly on failure. All loops are in procedures, and the sort and merge use for loops over array ranges and guarded while loops. About 170 lines.

## Proof obligations to watch

- **index**: The run buffer and the k-way merge head arrays are fixed-size arrays indexed by for-loop variables over their own ranges or by guarded counters, so indexes discharge.
- **overflow**: Counters and values live in declared ranged subtypes such as a non-negative integer range up to 2**31-1 with guards before any increment, so overflow checks follow from types.
- **termination**: Insertion sort over a run uses nested for loops and the merge uses while loops, all inside procedures, so no termination check applies.
- **other**: File open, read and write failures and malformed numbers in the input file must have a visible rejection outcome via admitted file library operations with specified failure results.
- **length**: Number-to-text and fixed-width text conversions must fit bounded buffers, discharged by fixed field width sized for the integer range.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, string building, 'Image of scalars, text parsing, file input, file output, Put without a newline and integer division.

## External effects

- **files** (allowed): Writes an input file of fixed-length integers, run files, temporary subfiles and a final merged sorted output file, and reads them back.
- **console output** (allowed): Prints the input and sorted output contents for checking.

Assessed on 2026-10-15 against page revision 414195 of the [task](https://rosettacode.org/wiki/External_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
