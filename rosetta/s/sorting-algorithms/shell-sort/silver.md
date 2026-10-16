# Sorting algorithms/Shell sort

**Candidate: proofs likely to discharge automatically.** The only non-static checks are the index J - Gap and the update of J, and the while guard J > Gap written just before them discharges both. The while loop sits in the Main procedure, so it gets no termination check, and elements are only compared and moved, never computed with arithmetic.

Position 195 in the [progression](../../../progression.md#stage-8), in stage 8.

## Approach

Main declares a subtype Index range 1 .. 10, a constrained Integer array type over Index holding the embedded sample data, and a constant gap array (for example 5, 2, 1) that ends in 1. For each gap in a for loop, an inner for loop runs I over Gap + 1 .. 10, saves Temp := A (I), and shifts larger elements with a while loop guarded by J > Gap and then A (J - Gap) > Temp, then stores Temp at A (J). The sorted elements are printed with Put_Line (Integer'Image (A (K))) in a final for loop. About 35 lines.

## Proof obligations to watch

- **index**: The read A (J - Gap) inside the insertion loop sits behind the short-circuit guard J > Gap in the while condition, so J - Gap is at least 1 and at most 9, inside the array's static range.
- **range**: The loop-carried J : Index is updated by J := J - Gap only under the same J > Gap guard, so the result stays within Index's declared range 1 .. 10 without an invariant.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops and 'Image of scalars.

## External effects

- **console output** (allowed): The sorted array (and optionally the unsorted one) is printed one element per line with Put_Line.

Assessed on 2026-10-15 against page revision 414506 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Shell_sort) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
