# Sorting algorithms/Bubble sort

**Candidate: proofs likely to discharge automatically.** Every check follows from static array bounds and for-loop ranges, the swap involves no arithmetic on elements, and the unannotated while-style outer loop sits in a procedure where no termination proof is demanded, so it should discharge automatically.

Position 200 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

The program embeds a constant 9-element Integer array (5,4,6,3,7,2,8,1,9) in a fixed-bounds array type, and a Sort procedure copies it in place using a swap with a temporary and a Boolean Changed flag. An outer loop with exit when not Changed wraps an inner for loop over Index range First .. Last - 1 comparing A(J) and A(J + 1) and swapping, and Main prints each element with Put_Line of its 'Image after sorting. All indices come from the array's static bounds, so no guards beyond the comparison are required. About 45 lines.

## Proof obligations to watch

- **termination**: The outer repeat-until-no-swap loop is a while/exit loop inside a procedure, so it gets no termination check, and the inner for loop terminates by construction.
- **index**: The inner loop runs J over a subtype range ending one before the array's last index so J + 1 stays in bounds by static range, with no loop-carried index.
- **overflow**: Element values are a bounded integer subtype and only compared and swapped, never added, and the only arithmetic is J + 1 on a small index subtype.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The sorted integers are printed as text lines.

Assessed on 2026-10-15 against page revision 415490 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Bubble_sort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
