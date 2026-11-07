# Same fringe

**Candidate: proofs plausibly discharge automatically.** Index-based trees with iterative stack-driven traversal need only type-range and pre-push guards, with no recursion, heap or tasks, so no annotation is required; the number of loop-carried indices (stack top, two iterators) makes discharge depend on careful program shape. The task allows any solution, so the concurrency in the Ada version is not required.

Position 729 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Trees are stored in a fixed-capacity array of node records (character value, left and right child indices where 0 means empty), with the five example trees built by assignments into one shared pool. A leaf-stepping procedure uses an explicit bounded stack for iterative in-order traversal and yields the next fringe item as an out parameter plus a found flag. A while loop in a procedure advances both iterators in lockstep and stops at the first mismatch or when one fringe ends first, and a nested for loop over the five trees prints the same/DIFF matrix. About 130 lines.

## Proof obligations to watch

- **index**: Node links and the explicit stack are indexed by a subtype bounded by the fixed node capacity, and each push is guarded by a test that the stack top is below capacity, with a visible error message when the guard fails.
- **overflow**: The stack top and node counters are ranged subtypes that are incremented only after a guard just before the increment, since the loop-carried values are known only by type after the first iteration.
- **termination**: The traversal loops are while loops inside procedures, which get no termination check, so no variant is needed.
- **stack**: Recursion is replaced by an explicit fixed-capacity stack array, so no input-dependent stack depth arises.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each tree in preorder and the same/DIFF result for each pair of the five example trees.

Assessed on 2026-10-15 against page revision 412155 of the [task](https://rosettacode.org/wiki/Same_fringe) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
