# Permutations with some identical elements

**Candidate: proofs likely to discharge automatically.** All checks are index bounds on a fixed 6-element array, guarded by loop conditions on small range-typed positions, with no arithmetic that can overflow and no recursion, so the proofs should discharge without annotations.

Position 522 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Embed the sorted multiset AAABBC... actually AABBBC as a fixed 6-element Character array, print it, then repeatedly call a procedure that applies the standard lexicographic next-permutation step (scan from the right for a<b pair, find the rightmost larger element, swap, reverse the suffix with a for loop) and returns a Boolean saying whether a successor existed. An outer for loop over 1 .. 60 prints the array as a 6-character String via indexed assignment and exits when no successor exists, with all indexes guarded by range-typed positions. About 55 lines.

## Proof obligations to watch

- **index**: The next-permutation scan uses a loop-carried position typed as a small range and tests it against the lower bound in the loop condition before indexing a(i) and a(i+1), so no invariant is needed.
- **termination**: Only procedures contain while loops so no termination check arises, and the outer enumeration is a for loop over 1 .. 60, which bounds the output at the required 60 permutations.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, for loops, while loops and procedures.

## External effects

- **console output** (allowed): Each of the 60 permutations is printed as a line of text with Put_Line.

Assessed on 2026-10-15 against page revision 407666 of the [task](https://rosettacode.org/wiki/Permutations_with_some_identical_elements) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
