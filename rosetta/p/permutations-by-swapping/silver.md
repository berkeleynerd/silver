# Permutations by swapping

**Candidate: proofs likely to discharge automatically.** Every check follows from the subtype ranges of the indices and counters, and each increment is guarded by the comparison just before it, so the loop needs no invariant; the while loop sits in a procedure, so no termination check arises.

Position 207 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

The program holds the three items in a fixed array of a small index subtype, runs an iterative Heap's algorithm (counter array and a while loop) in a procedure, and swaps exactly two items per step while flipping a Boolean sign. After each swap it prints the array with 'Image and Put and the sign as +1 or -1, with the starting state printed first. About 55 lines.

## Proof obligations to watch

- **index**: Heap's counters and the loop index live in small ranged subtypes, and each increment is guarded by the comparison just before it, so the swap indices and increments stay within the array and subtype bounds.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints each permutation of three items and its sign to standard output.

Assessed on 2026-10-15 against page revision 414397 of the [task](https://rosettacode.org/wiki/Permutations_by_swapping) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
