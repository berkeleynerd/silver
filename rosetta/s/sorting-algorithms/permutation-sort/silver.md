# Sorting algorithms/Permutation sort

**Candidate: proofs plausibly discharge automatically.** All array accesses are bounded by index subtypes or guards and the loops live in procedures, so nothing requires an annotation, but the loop-carried Heap's counters need careful guard placement.

Position 550 in the [progression](../../../progression.md#stage-10), in stage 10.

## Approach

Store the 11 characters of the embedded input in a constrained Character array indexed by a 1..11 subtype, and generate permutations iteratively with Heap's algorithm using a counter array and a while loop in a procedure. After each new permutation, a for loop over 1..10 checks adjacent order with Seq(J) <= Seq(J+1), and on the first sorted one the array is copied into an 11-character String and printed with Put_Line, with a visible fallback message if the generator is exhausted. About 70 lines.

## Proof obligations to watch

- **index**: Heap's-algorithm indices (swap positions and counter entries) are loop-carried, so they are held in a subtype 1..11 or guarded just before each array access.
- **overflow**: Counter entries and the loop index stay inside bounded subtypes with explicit guards before increments, so no wraparound check needs an invariant.
- **termination**: The generation loop is a while loop inside a procedure, which gets no termination check, and it exits when Heap's index passes the end.
- **other**: A reachability fallback prints a visible 'no sorted permutation' outcome if the generator ends without finding one, so no unproven assumption is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures and integer division.

## External effects

- **console output** (allowed): Prints the sorted permutation line with Put_Line.

Assessed on 2026-10-15 against page revision 414503 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Permutation_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
