# Brzozowski algebraic method

**Candidate: proofs plausibly discharge automatically.** Everything reduces to bounded arrays, for loops and explicit-stack while loops in procedures with capacity guards, so no annotation is needed, but many loop-carried indices and buffer positions require careful guarding.

Position 1199 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Expressions live in a fixed-capacity node pool (arrays of kind, left, right and character) where children always have lower indices, with the 3x3 example matrix and final-state array embedded; the Brzozowski loop uses for loops over the matrix indices that allocate Star, Concat and Union nodes with capacity guards. Simplification is a bottom-up for-loop pass over node indices applying the identity, zero, star and duplicate-union rules using canonical ids for equality, and printing is a while-loop procedure with an explicit stack that appends into a bounded String buffer before Put_Line. About 300 lines.

## Proof obligations to watch

- **index**: Node-pool allocation, explicit-stack pushes and output-buffer writes are each guarded by a capacity test that rejects with a visible message instead of overrunning.
- **length**: The raw expression expands to a large tree string, so the output buffer is sized for it and every append is guarded by remaining capacity with a specified overflow outcome.
- **termination**: Printing and simplification are iterative while loops in procedures (no termination check), using an explicit stack and a bottom-up pass over children-before-parent node indices instead of recursion.
- **overflow**: Loop-carried counters (node count, stack top, output position) are subtypes bounded by the pool and buffer capacities, with a guard before each increment.
- **other**: The fixpoint repetition of simplification is replaced by a fixed bounded number of for-loop passes with hash-consed node ids so equality is an index comparison, which must still produce the same final result as the task's fixpoint.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The raw and simplified regular expressions are printed to standard output.

Assessed on 2026-10-15 against page revision 377556 of the [task](https://rosettacode.org/wiki/Brzozowski_algebraic_method) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
