# Bioinformatics/Global alignment

**Candidate: proofs plausibly discharge automatically.** Every array access is bounded by declared capacities and guards on stored lengths, with no recursion, so checks follow from types and local guards, but several loop-carried offsets and the while-loop permutation need careful shaping.

Position 850 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

Each sequence is a record holding a Length and a Character array of capacity 100, with the four examples embedded as aggregates in an array of at most 13 sequences. Procedures remove duplicates and contained sequences using for loops with guarded comparison, then enumerate orderings with an iterative Heap's algorithm in a while loop, merging each ordering by a longest-overlap function into a 1200-character bounded buffer and keeping the shortest. A reporting procedure counts A, C, G and T with a case statement and prints the sequence, its length and the counts via 'Image. About 230 lines.

## Proof obligations to watch

- **index**: Overlap and substring scans index two bounded buffers with loop-carried offsets, so each access needs a guard on offset plus length against the buffer's stored length just before use.
- **length**: Appending a non-overlapping tail to the candidate must be guarded by a check that the new length fits the 1200-character capacity, with a visible rejection otherwise (the true total of the examples is at most about 1170).
- **overflow**: Length sums and the best-length minimum are held in subtypes bounded by the capacity, so additions stay within range once guarded.
- **termination**: Heap's iterative permutation uses a while loop with loop-carried index state, which is acceptable only in a procedure (no termination check) and with its swap indexes typed by the sequence-count subtype.
- **other**: Exhaustive permutation of the roughly nine surviving strings in the last example is about 362880 candidates, which is a runtime cost rather than a proof obligation, and a subset DP would avoid it at the price of more indexed arithmetic.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions and integer division.

## External effects

- **console output** (allowed): Prints each superstring, its length and its A, C, G, T counts with Put_Line.

Assessed on 2026-10-15 against page revision 412093 of the [task](https://rosettacode.org/wiki/Bioinformatics/Global_alignment) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
