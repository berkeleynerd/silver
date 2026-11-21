# Sorting algorithms/Heapsort

**Candidate: proofs likely to discharge automatically.** Every index and arithmetic check follows from bounded index subtypes plus the loop condition and 'and then' guards directly before each access, and loops sit in procedures so no variants are needed. No annotation, recursion or heap use is required.

Position 223 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

A fixed-size constrained Integer array with embedded sample data is sorted in place by a Sift_Down procedure and a Heapsort procedure that use while loops with root, child, start and end indices declared in bounded integer subtypes. Sift_Down checks root*2+1 <= last in the loop condition and child+1 <= last with 'and then' before indexing, and exits via the loop condition or an exit when. Main prints the array with Put and Integer'Image before and after sorting. About 70 lines.

## Proof obligations to watch

- **index**: Sift-down index arithmetic is loop-carried, but root and child are declared in the array's index subtype and every use of root*2+1 and child+1 is preceded by the loop condition or an 'and then' guard against the last heap index.
- **range**: Heapify's start counter reaches -1, so it is declared in a subtype that includes -1 and the loop guard keeps the decrement in range.
- **overflow**: Integer elements are only compared and swapped, never added, and index arithmetic is bounded by the small index subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the array before and after sorting with Put_Line and Put.

Assessed on 2026-10-15 against page revision 414499 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Heapsort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
