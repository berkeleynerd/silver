# Schieber-Vishkin algorithm

**Candidate: proofs plausibly discharge automatically.** All checks follow from ranged index subtypes, modular label types and guards, and loops sit in procedures, but many loop-carried indices and bit-shift amounts need careful guarding and no annotation is needed. The recursive traversal is rewritten iteratively, so nothing needs a variant.

Position 1306 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Embed a fixed example tree (a Cartesian tree built from the sample array) in constant arrays with a ranged node-index subtype, build child, sibling and parent links in a procedure with a while-loop stack climb, then number nodes in preorder with an iterative traversal and compute the bit labels (beta, alfa, tau, lambda) over modular integers. A branch-free query function computes the LCA with bit tricks, and a main loop over embedded query pairs prints results via Put_Line with 'Image; every array index is a ranged subtype or guarded before use, and oversized input is rejected visibly. About 170 lines.

## Proof obligations to watch

- **index**: Parent, child, sibling, preorder and label lookups index fixed-size arrays with values loaded from arrays, so they discharge only because every stored element has a subtype confined to the node-index range and the preorder counter is guarded against its maximum.
- **overflow**: The preorder counter and shifts or masks of labels are loop-carried, so the counter is a ranged subtype with an explicit guard and the bit labels use a modular type where wraparound is intended and shift amounts are range-limited.
- **termination**: The stack-climbing and traversal while loops live in procedures, which get no termination check, and the query function uses only straight-line code.
- **range**: The fixed tree size limit must be a visible rejection when exceeded, and the shift-count lookup table must be indexed only with guarded nonzero masks.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, modular types, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and case statements.

## External effects

- **console output** (allowed): Prints each query and its lowest-common-ancestor result with Put_Line.

Assessed on 2026-10-15 against page revision 414457 of the [task](https://rosettacode.org/wiki/Schieber-Vishkin_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
