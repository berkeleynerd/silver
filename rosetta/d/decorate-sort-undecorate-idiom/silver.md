# Decorate-sort-undecorate idiom

**Candidate: proofs likely to discharge automatically.** All loops are for loops over fixed array ranges and all indexes and slice bounds follow from declared subtypes, so no loop invariant is needed; the new surface is only arrays, records, slicing and unterminated output.

Position 586 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Define a 12-character padded word record with a key field of subtype 1..12, and a constant-sized array of 7 such records filled from the embedded word list with each key set once (decorate). A stable bubble sort using nested for loops compares adjacent keys and swaps whole records (sort), then a final for loop prints Word(1..Len) of each element via Put and Put_Line (undecorate). About 55 lines.

## Proof obligations to watch

- **index**: Adjacent-swap indexes come from for loops over the array's own range and the printed slice Word(1..Len) is bounded by Len's subtype 1..12, so these checks follow from types.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, records, string indexing, for loops, procedures, Put without a newline and while loops.

## External effects

- **console output** (allowed): Prints the sorted words, one per line or as a bracketed list, to standard output.

Assessed on 2026-10-15 against page revision 414734 of the [task](https://rosettacode.org/wiki/Decorate-sort-undecorate_idiom) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
