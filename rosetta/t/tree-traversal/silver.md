# Tree traversal

**Candidate: proofs plausibly discharge automatically.** The task has no conflicts, since recursion and pointers can be replaced by array-backed nodes and explicit bounded stacks and queues in procedures, and the checks are index and capacity guards on loop-carried tops. Plausible rather than likely because several loop-carried stack and queue indices need careful guards and the postorder state logic is delicate.

Position 823 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The tree is stored in arrays indexed by node number 1..9, holding Left, Right and Value, with 0 meaning no child, and filled with embedded constants. Preorder, inorder and postorder use iterative procedures with an explicit fixed-capacity stack, with postorder using a last-visited marker, and level order uses a fixed-capacity queue, all in while loops inside procedures. Every push, pop and append is guarded by a capacity or emptiness test that rejects on failure, and results are written into a bounded text buffer then printed with Put_Line. About 120 lines.

## Proof obligations to watch

- **index**: Stack and queue tops are loop-carried, so every push and pop is guarded by an explicit capacity or emptiness test that rejects on overflow, and child links use a subtype 0..9 with a guard for 0 before indexing.
- **overflow**: Output counters and stack tops are ranged subtypes bounded by the guards, so increments are guarded just before use.
- **termination**: The iterative traversals are while loops inside procedures, which get no termination check, so no variant is needed.
- **length**: Output lines are built in a fixed-size buffer sized for 9 values plus label, with a guard before each append.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, procedures, string building, 'Image of scalars, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints the four labelled traversal lines to standard output.

Assessed on 2026-10-15 against page revision 411731 of the [task](https://rosettacode.org/wiki/Tree_traversal) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
