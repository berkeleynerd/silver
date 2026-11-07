# Huffman coding

**Candidate: proofs plausibly discharge automatically.** Replacing the pointer tree and priority queue with index arrays and a linear-scan minimum search makes every check follow from ranged subtypes and guards, with only the loop-carried weights, counts and depths needing careful guarding and no annotations.

Position 834 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The program embeds the example string, counts character frequencies in a 256-entry weight array, and builds the tree in fixed arrays (weight, parent, bit, active flag) of capacity 2*256 nodes. A while loop in a procedure repeatedly scans for the two lowest-weight active nodes (deterministic tie-break by lowest index), creates a parent node with guarded weight addition, and finally for each used character walks parent links to the root into a bounded bit buffer, then prints the reversed code as a line. Capacity, weight limit and depth checks reject with a specified outcome rather than altering results. About 130 lines.

## Proof obligations to watch

- **overflow**: Merged-node weights are loop-carried sums, so they are stored in a bounded Weight subtype and a guard before each addition rejects totals above the documented limit (far above the 39-character example).
- **index**: Node count and the min-search indexes are loop-carried, so each is a ranged subtype with a guard before every increment or array access against the fixed node capacity.
- **termination**: The merge loop and the leaf-to-root walks are while loops, which is acceptable only because they sit in procedures, which get no termination check.
- **index**: The code buffer is filled while walking leaf to root, so a guard on depth against the buffer capacity precedes each write and rejects the input if exceeded.
- **initialization**: Parent, weight and active arrays are fully initialized with aggregates before the loops use them.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, string building, for loops, while loops, case statements, procedures and Boolean objects.

## External effects

- **console output** (allowed): The program prints one line per distinct character giving its Huffman code.

Assessed on 2026-10-15 against page revision 414957 of the [task](https://rosettacode.org/wiki/Huffman_coding) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
