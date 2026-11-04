# Faces from a mesh

**Candidate: proofs plausibly discharge automatically.** Everything is bounded array and for-loop work in procedures with small ranged types, so checks follow from types and guards, but the loop-carried used-flags, rotation indexing and invalid-input paths need careful shaping. No annotation-only facts, recursion or heap are needed.

Position 631 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Faces are fixed-capacity arrays of a ranged vertex subtype with an explicit count, and edges are a record of two vertices in a fixed array with a used-flag array. Perimeter equality checks counts, then tries every rotation in both directions with for loops and a guarded mod index, while edge-to-perimeter chaining starts from the first edge and repeatedly scans for an unused edge touching the last vertex, printing "Invalid edge format" if none is found or the cycle closes early. All data is embedded, and results are printed with Put and Integer'Image. About 170 lines.

## Proof obligations to watch

- **index**: Rotation offsets and reversed positions are computed with mod over a ranged count, and each index is guarded or typed to lie within 1..Max_Edges.
- **termination**: The edge-chaining search is a procedure using for loops bounded by the edge count, so no function needs a variant.
- **overflow**: Vertex numbers use a small ranged subtype and indices are bounded, so the additions and mod arithmetic stay in range.
- **other**: Malformed edge sets (unsorted ends, dangling or premature cycle closure as in face H) must report a visible invalid outcome, and tracking used edges through loop-carried flags needs guards before each use.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the equality results and the four perimeter lists, using Put and Put_Line.

Assessed on 2026-10-15 against page revision 414196 of the [task](https://rosettacode.org/wiki/Faces_from_a_mesh) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
