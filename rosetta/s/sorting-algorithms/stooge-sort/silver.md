# Sorting algorithms/Stooge sort

**Candidate: proofs plausibly discharge automatically.** Every array index and stack push can be guarded just before use with values drawn from bounded subtypes, so no annotation is needed, but the loop-carried frame indices and stack pointer make discharge depend on careful program shape. Avoiding recursion keeps stack depth a fixed documented limit rather than input-dependent.

Position 913 in the [progression](../../../progression.md#stage-15), in stage 15.

## Approach

Store the 15 embedded integers in a constrained array of a bounded Integer subtype and sort in place in a procedure. Replace recursion with an explicit fixed-capacity stack of (i, j, stage) frames, with each frame performing the compare-and-swap, computing t = (j-i+1)/3, and pushing the three sub-ranges, guarded so indices stay within the array range and stack overflow is rejected. Print results with Put and Integer'Image, separating by commas, then a final newline. About 70 lines.

## Proof obligations to watch

- **stack**: The recursive form would have input-dependent depth, so the program uses an explicit fixed-size frame stack in a while loop inside a procedure, with a guard that rejects on overflow.
- **index**: Frame indices and the computed i+t, j-t bounds are loop-carried values with no invariant, so each is held in a subtype bounded to the array range and guarded just before each array access.
- **overflow**: The stack pointer increments inside a while loop and is discharged only by a guard against the stack capacity before each push.
- **termination**: Termination is not checked for procedures, so the while loop needs no variant, but the work must stay in a procedure rather than a function.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the sorted 15-element array as comma-separated integers.

Assessed on 2026-10-15 against page revision 414507 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Stooge_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
