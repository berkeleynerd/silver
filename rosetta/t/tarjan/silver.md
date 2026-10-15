# Tarjan

**Candidate: proofs plausibly discharge automatically.** Recursive Tarjan converts to an iterative procedure over fixed-size arrays whose indexes and counters are bounded by subtypes and capacity guards, so the checks should discharge without invariants, though many loop-carried stack pointers make the program shape delicate.

Position 729 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The 8-node example graph is an embedded Boolean adjacency matrix, and recursion is replaced by an explicit call-stack array with a per-node next-neighbour cursor, all in one procedure with bounded node-number subtypes. A while loop runs the DFS, pushing nodes onto the Tarjan stack with capacity guards, updating lowlink via guarded min, and popping a component when lowlink equals index. Each component is printed as a line built from the image of its node numbers. About 120 lines.

## Proof obligations to watch

- **index**: The explicit DFS stack and component stack indexes are loop-carried, so each push is preceded by a guard against capacity that rejects with a visible outcome, even though the bound of N pushes holds in practice.
- **range**: The lowlink and index counters are subtypes bounded to 0..N, with min updates using values already of that subtype, so no annotation is needed.
- **termination**: The iterative DFS uses a while loop inside a procedure, which gets no termination check, so no variant is needed.
- **initialization**: All arrays (index, lowlink, on-stack, next-edge pointer, stacks) are filled by aggregates or for loops before the search starts.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each strongly connected component's node numbers to standard output.

Assessed on 2026-10-15 against page revision 414542 of the [task](https://rosettacode.org/wiki/Tarjan) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
