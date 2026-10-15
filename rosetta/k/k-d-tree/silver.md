# K-d tree

**Candidate: proofs plausibly discharge automatically.** Nothing needs an annotation because recursion and pointers are replaced by index arrays and explicit stacks inside procedures, but the many loop-carried indices and stack pointers each need careful guards, so discharge depends on program shape.

Position 1118 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Points are stored in fixed arrays of integer coordinates (1000-point capacity, a record or 2-d array) with a deterministic linear congruential generator for the random set, and the tree is held as arrays of left and right child indices with 0 meaning none. Build and nearest-neighbour search are procedures using bounded explicit stacks and while loops instead of recursion, with median selection by a bounded for-loop sort per range, and every push, pop and child index is guarded. The program runs both data sets and prints the query point, found point, distance and visited count. About 230 lines.

## Proof obligations to watch

- **index**: The explicit work stack and node-index arrays need a guard before every push, pop and child lookup, since the tree depth is only bounded by the fixed capacity and not by an invariant.
- **overflow**: Squared distances over bounded integer coordinates (for example 0..999999 in 3-d) stay far below the 64-bit range, so the loop-carried best-distance and visited counter are bounded by their declared subtypes.
- **floating point**: Only the final square root of a bounded non-negative integer distance is floating point, kept to a range-guarded conversion.
- **termination**: Tree building and nearest search run as while loops in procedures over an explicit stack, which get no termination check, whereas any function must avoid while loops and recursion.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, floating point, floating-point images, 'Image of scalars, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, Boolean objects, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the searched point, found point, distance and visited-node count for both data sets.

Assessed on 2026-10-15 against page revision 414282 of the [task](https://rosettacode.org/wiki/K-d_tree) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
