# Tree datastructures

**Candidate: proofs plausibly discharge automatically.** Only bounded arrays, bounded string buffers and while loops in procedures are needed, so no annotation is required, but loop-carried depth and buffer positions need explicit guards, which makes the outcome depend on careful program shape. Arbitrary trees are limited to documented node, depth and name capacities, with oversize input rejected.

Position 954 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed the example as a bracketed nest string such as RosettaCode(rocks(code,comparison,wiki),mocks(trolling)) in a bounded buffer, and hold the indent form as arrays of levels and fixed-capacity names with a node count. One procedure scans the nest text with a depth counter to fill the indent arrays; another walks the indent arrays, comparing each level with the previous one to emit open brackets, commas and close brackets into a bounded buffer. The program prints the initial nest, the indent lines, and the rebuilt nest, then compares the two nest strings with String equality. About 170 lines.

## Proof obligations to watch

- **index**: Scanning the nest text and appending to bounded output buffers uses loop-carried positions and counts that must each be guarded against the fixed capacities just before use.
- **range**: The nesting depth counter rises and falls through the loop, so it is declared with a bounded subtype and guarded (reject if above the maximum, ignore a close at depth zero) before every change.
- **length**: Node names are copied into fixed-size name slots with a stored length, and each copy is guarded by the slot capacity and the node-count capacity.
- **termination**: All loops are while or for loops inside procedures, which get no termination check, so no variant is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions and conditional expressions.

## External effects

- **console output** (allowed): The nest form, indent form, restored nest form and comparison result are printed as text lines.

Assessed on 2026-10-15 against page revision 413092 of the [task](https://rosettacode.org/wiki/Tree_datastructures) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
