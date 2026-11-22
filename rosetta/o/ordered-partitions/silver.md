# Ordered partitions

**Candidate: proofs plausibly discharge automatically.** Every check is on small bounded index or length types with guards before each array access and append, and the only loops with carried state live in procedures, so no termination check or invariant is needed; the care needed is in the index guards and buffer capacity.

Position 929 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the sizes (2,0,2) in a bounded array of at most 4 blocks with values 0..8, hold the permutation of 1..N in a bounded array, and loop in a procedure with a while loop that advances it by the standard next-permutation algorithm. For each permutation, emit a line only when elements are ascending within every block, which removes duplicates while keeping lexicographic order, and build each line into a bounded text buffer using scalar-image conversion for numbers before Put_Line. About 110 lines.

## Proof obligations to watch

- **index**: Next-permutation scans use K and L as loop-carried indexes, so each access to K+1 or L is guarded by a just-before test and the indexes are subtypes of the array range.
- **length**: Output line text is assembled in a fixed-capacity buffer sized for the maximum 8 elements and 4 blocks, with a capacity guard before each append and a visible rejection if exceeded.
- **overflow**: Block sizes and their sum are bounded by ranged subtypes so the running offset into the permutation cannot overflow.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, procedures, string building, 'Image of scalars, characters and conditional expressions.

## External effects

- **console output** (allowed): Prints the six partitions of (2,0,2) line by line.

Assessed on 2026-10-15 against page revision 414372 of the [task](https://rosettacode.org/wiki/Ordered_partitions) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
