# Sorting algorithms/Selection sort

**Candidate: proofs likely to discharge automatically.** The selection-sort candidate admitted using existing fixed arrays, bounded scalar indexes, counted loops and Integer Image output, including negative and duplicate data. This is admission evidence only; sorted execution output and final application proof/build evidence were not measured. The original surface mapping is retained for separate coverage reconciliation; these observations add no delivered sample or supported task mapping in this batch.

Position 111 in the [progression](../../../progression.md#stage-4), in stage 4.

## Approach

The planning candidate performs selection sort in Main over a fixed initialized Integer array containing negative and duplicate values. Nested counted loops track the minimum with a bounded mutable scalar index and exchange through a scalar temporary; a final loop prints Integer Images. No array-valued parameter or separate sorting procedure is required. The measured result is admission only. About 45 lines.

## Proof obligations to watch

- **index**: The mutable minimum index has the fixed array index range; counted scan indexes and scalar index bounds cover every read and swap destination.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, Put without a newline, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the sorted array as text lines via Silver_IO.

Initially assessed on 2026-10-15 against page revision 414505 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Selection_sort) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-18 by Codex through targeted source review; see the [review record](../../../../docs/bounded-string-building-samples.md).
