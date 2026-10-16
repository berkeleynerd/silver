# Greatest subsequential sum

**Candidate: proofs plausibly discharge automatically.** All checks are bounded by declared element ranges and for-loop indexes, with only the loop-carried running sum needing a guard, so no annotation is required but the program shape must be careful.

Position 63 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

Embed the example sequence as a constant array of 11 elements of a bounded integer subtype, then run a nested for-loop scan in a main procedure keeping the best sum (initially 0, empty) and its Start/Finish indexes, updating only on strictly greater sums. A guard before each addition rejects sums beyond a documented limit, and the result is printed by a for loop over the recorded range (or an explicit empty-sequence message) followed by the sum. About 45 lines.

## Proof obligations to watch

- **overflow**: The running sum is a loop-carried value that GNATprove knows only by its type after the first iteration, so the program declares element values in a small range, uses a wide sum type, and adds an explicit guard before each addition that rejects (visibly) any sum outside a documented bound.
- **initialization**: Start and end indexes are set to an empty-subsequence marker before the loops and updated only on improvement, so nothing is read uninitialized and the all-negative case yields the empty result.
- **index**: Slice bounds are printed with a for loop over the recorded Start..Finish indexes that lie in the array's own index subtype, so index checks follow from types.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, Put without a newline and procedures.

## External effects

- **console output** (allowed): The program prints the elements of the maximizing subsequence and its sum to standard output.

Assessed on 2026-10-15 against page revision 414240 of the [task](https://rosettacode.org/wiki/Greatest_subsequential_sum) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
