# Visualize a tree

**Candidate: proofs likely to discharge automatically.** All checks follow from declared ranges and for-loop indexes over the array's own range, with no loop-carried values beyond the bounded depth, so no annotations are needed. The task accepts any friendly text output, so an embedded indented tree is faithful.

Position 510 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The tree is embedded as a preorder constant array of nodes, each with a ranged depth and a one-character label. A for loop over the array's own range fills a fixed-length line buffer with spaces up to 2*depth, writes the label, and prints the slice with Put_Line. Depth is a subtype bounded so the buffer index can never exceed the buffer length. About 45 lines.

## Proof obligations to watch

- **index**: The line buffer index and slice bounds are discharged because depth is a ranged subtype whose maximum keeps 2*depth+1 within the fixed buffer length.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, string building and for loops.

## External effects

- **console output** (allowed): The indented tree is printed line by line with Put_Line.

Assessed on 2026-10-15 against page revision 412548 of the [task](https://rosettacode.org/wiki/Visualize_a_tree) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
