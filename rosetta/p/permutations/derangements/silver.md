# Permutations/Derangements

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes, fixed array bounds and guards before each access, and the iterative search lives in a procedure so no variant is needed, but the backtracking loop's index bookkeeping requires careful shape without invariants.

Position 1299 in the [progression](../../../progression.md#stage-21), in stage 21.

## Approach

Permutations of 0..n-1 are enumerated by an iterative depth-first search in a procedure using fixed arrays (max 10 items) for the current choice per depth and used flags, with a pruning guard that rejects item i at position i and an in out counter plus a Show flag that prints each full derangement. Subfactorial is a for-loop over a small modular-type array using the two-term recurrence, and a main loop prints the counted-versus-calculated table for n 0..9 and !20 through bounded string building of integer images. About 130 lines.

## Proof obligations to watch

- **index**: The iterative backtracking procedure keeps its depth, candidate item and used-flag indexes in ranged subtypes with explicit guards before every array access, since no invariant relates them across iterations.
- **overflow**: Subfactorial uses a 64-bit modular type with the recurrence !n=(n-1)(!(n-1)+!(n-2)), which is exact up to n=20 and has no overflow check, while counters are 64-bit values bounded by 9! so additions are safe by type range.
- **termination**: The enumeration is a while loop inside a procedure, which gets no termination check, so recursion and function loops are avoided entirely.

## Language surface recorded by this assessment

Integers, ranged subtypes, modular types, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 9 derangements of 4 items and the n=0..9 table of counted versus calculated values, plus !20.

Assessed on 2026-10-15 against page revision 414398 of the [task](https://rosettacode.org/wiki/Permutations/Derangements) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
