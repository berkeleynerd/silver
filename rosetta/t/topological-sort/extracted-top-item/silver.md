# Topological sort/Extracted top item

**Candidate: proofs plausibly discharge automatically.** All checks follow from enumeration-indexed arrays and bounded counters with explicit capacity guards, and the recursion-free DFS sits in a procedure so no variants are needed. It is plausible rather than likely because the stack and output counters are loop-carried values that need guards before each use.

Position 1183 in the [progression](../../../progression.md#stage-19), in stage 19.

## Approach

Represent the 18 files as an enumeration type and the dependencies as an 18x18 Boolean matrix filled by explicit assignments (self-dependencies left false). Top levels come from nested for loops testing for a dependency row and no dependent column. Each compile order is an iterative depth-first post-order in a procedure with an explicit stack of (file, next-child) cursors, visited flags set at push, and a bounded order array, then printed with 'Image and Put. About 110 lines.

## Proof obligations to watch

- **index**: The explicit DFS stack and output-order array are indexed by loop-carried counters, so each push and append is preceded by a capacity guard (stack top below 18, count below 18) whose failure path is a visible rejection.
- **termination**: The DFS loop lives in a procedure, so no termination check arises, and marking each file visited when pushed bounds the work and stack depth by 18 even if the data had a cycle.
- **overflow**: Counters and child cursors are subtypes bounded by 0..18 and are incremented only under guards, so range checks discharge from types and tests just before use.

## Language surface recorded by this assessment

Enumerations, ranged subtypes, Boolean objects, arrays, multidimensional arrays, records, for loops, while loops, procedures, integers, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the top-level files and the compile orders for top1 and top2.

Assessed on 2026-10-15 against page revision 400753 of the [task](https://rosettacode.org/wiki/Topological_sort/Extracted_top_item) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
